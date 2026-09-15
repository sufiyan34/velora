import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../services/cloudinary/cloudinary_exception.dart';
import '../services/cloudinary/cloudinary_file_picker.dart';
import '../services/cloudinary/cloudinary_models.dart';
import '../services/cloudinary/cloudinary_service.dart';

class CloudinaryMediaController extends GetxController {
  CloudinaryMediaController({required CloudinaryService service})
    : _service = service;

  final CloudinaryService _service;

  // ==========================================================
  // STATE
  // ==========================================================

  final RxBool isUploading = false.obs;
  final RxDouble progress = 0.0.obs;

  final RxInt currentIndex = 0.obs;
  final RxInt totalFiles = 0.obs;

  final RxString currentFileName = ''.obs;
  final RxString errorMessage = ''.obs;

  final RxList<CloudinaryUploadResult> uploaded =
      <CloudinaryUploadResult>[].obs;

  CancelToken? _cancelToken;

  bool get hasError => errorMessage.value.isNotEmpty;

  bool get canCancel => isUploading.value && _cancelToken != null;

  String get progressPercent => '${(progress.value * 100).round()}%';

  // ==========================================================
  // PICK + UPLOAD IMAGES
  // ==========================================================

  Future<List<CloudinaryUploadResult>> pickAndUploadImages({
    String folder = 'velora/products/images',
    int maxFiles = 10,
  }) async {
    final files = await CloudinaryFilePicker.pickImages(multiple: true);

    if (files.isEmpty) {
      return const [];
    }

    final limited = files.take(maxFiles).toList(growable: false);

    return uploadImages(limited, folder: folder);
  }

  // ==========================================================
  // PICK + UPLOAD VIDEO
  // ==========================================================

  Future<CloudinaryUploadResult?> pickAndUploadVideo({
    String folder = 'velora/products/videos',
  }) async {
    final file = await CloudinaryFilePicker.pickVideo();

    if (file == null) {
      return null;
    }

    return uploadVideo(file, folder: folder);
  }

  // ==========================================================
  // PICK + UPLOAD GLB
  // ==========================================================

  Future<CloudinaryUploadResult?> pickAndUploadGlb({
    String folder = 'velora/products/3d',
  }) async {
    final file = await CloudinaryFilePicker.pickGlb();

    if (file == null) {
      return null;
    }

    return upload3dModel(file, folder: folder);
  }

  // ==========================================================
  // PICK + UPLOAD USDZ
  // ==========================================================

  Future<CloudinaryUploadResult?> pickAndUploadUsdZ({
    String folder = 'velora/products/3d',
  }) async {
    final file = await CloudinaryFilePicker.pickUsdZ();

    if (file == null) {
      return null;
    }

    return upload3dModel(file, folder: folder);
  }

  // ==========================================================
  // OLD GENERIC 3D PICKER
  // ==========================================================

  Future<CloudinaryUploadResult?> pickAndUpload3dModel({
    String folder = 'velora/products/3d',
  }) async {
    return pickAndUploadGlb(folder: folder);
  }

  // ==========================================================
  // UPLOAD IMAGES
  // ==========================================================

  Future<List<CloudinaryUploadResult>> uploadImages(
    List<XFile> files, {
    String folder = 'velora/products/images',
    int imageQuality = 82,
    int maxWidth = 2200,
    int maxHeight = 2200,
  }) async {
    if (files.isEmpty) {
      return const [];
    }

    return _runBatch(
      files,
      uploader: (file, onProgress) {
        return _service.uploadImage(
          file,
          options: CloudinaryUploadOptions(
            folder: folder,
            maxBytes: 15 * 1024 * 1024,
            compressImage: true,
            imageQuality: imageQuality,
            imageMaxWidth: maxWidth,
            imageMaxHeight: maxHeight,
            keepExif: false,
            autoOrient: true,
          ),
          onSendProgress: onProgress,
          cancelToken: _cancelToken,
        );
      },
    );
  }

  // ==========================================================
  // UPLOAD VIDEO
  // ==========================================================

  Future<CloudinaryUploadResult> uploadVideo(
    XFile file, {
    String folder = 'velora/products/videos',
  }) async {
    return _runSingle(
      file,
      uploader: (selected, onProgress) {
        return _service.uploadVideo(
          selected,
          options: CloudinaryUploadOptions(
            folder: folder,
            maxBytes: 500 * 1024 * 1024,
            compressImage: false,
          ),
          onSendProgress: onProgress,
          cancelToken: _cancelToken,
        );
      },
    );
  }

  // ==========================================================
  // UPLOAD 3D
  // ==========================================================

  Future<CloudinaryUploadResult> upload3dModel(
    XFile file, {
    String folder = 'velora/products/3d',
  }) async {
    final extension = _extension(file.name);

    const allowed = {'glb', 'gltf', 'gltz', 'usdz'};

    if (!allowed.contains(extension)) {
      throw const CloudinaryException(
        message: 'Unsupported 3D model. Please use GLB, GLTF, GLTZ, or USDZ.',
        code: 'unsupported_3d_format',
      );
    }

    return _runSingle(
      file,
      uploader: (selected, onProgress) {
        return _service.uploadModel3D(
          selected,
          options: CloudinaryUploadOptions(
            folder: folder,
            maxBytes: 100 * 1024 * 1024,
            compressImage: false,
          ),
          onSendProgress: onProgress,
          cancelToken: _cancelToken,
        );
      },
    );
  }

  // ==========================================================
  // SINGLE UPLOAD
  // ==========================================================

  Future<CloudinaryUploadResult> _runSingle(
    XFile file, {
    required Future<CloudinaryUploadResult> Function(
      XFile file,
      ProgressCallback onProgress,
    )
    uploader,
  }) async {
    if (isUploading.value) {
      throw const CloudinaryException(
        message: 'Another upload is already in progress.',
        code: 'upload_in_progress',
      );
    }

    _prepareUpload(total: 1);

    currentFileName.value = file.name;

    try {
      final result = await uploader(file, _onProgress);

      uploaded.add(result);

      return result;
    } catch (error) {
      _handleError(error);
      rethrow;
    } finally {
      _finishUpload();
    }
  }

  // ==========================================================
  // BATCH UPLOAD
  // ==========================================================

  Future<List<CloudinaryUploadResult>> _runBatch(
    List<XFile> files, {
    required Future<CloudinaryUploadResult> Function(
      XFile file,
      ProgressCallback onProgress,
    )
    uploader,
  }) async {
    if (files.isEmpty) {
      return const [];
    }

    if (isUploading.value) {
      throw const CloudinaryException(
        message: 'Another upload is already in progress.',
        code: 'upload_in_progress',
      );
    }

    _prepareUpload(total: files.length);

    final results = <CloudinaryUploadResult>[];

    try {
      for (var i = 0; i < files.length; i++) {
        currentIndex.value = i;
        currentFileName.value = files[i].name;
        progress.value = 0;

        final result = await uploader(files[i], _onProgress);

        results.add(result);
        uploaded.add(result);
      }

      return results;
    } catch (error) {
      _handleError(error);
      rethrow;
    } finally {
      _finishUpload();
    }
  }

  // ==========================================================
  // UPLOAD STATE
  // ==========================================================

  void _prepareUpload({required int total}) {
    errorMessage.value = '';

    isUploading.value = true;
    progress.value = 0;

    currentIndex.value = 0;
    totalFiles.value = total;
    currentFileName.value = '';

    _cancelToken?.cancel('Starting a new upload.');

    _cancelToken = CancelToken();
  }

  void _finishUpload() {
    isUploading.value = false;
    progress.value = 0;

    totalFiles.value = 0;
    currentIndex.value = 0;

    currentFileName.value = '';

    _cancelToken = null;
  }

  void _onProgress(int sent, int total) {
    if (total <= 0) {
      progress.value = 0;
      return;
    }

    progress.value = (sent / total).clamp(0.0, 1.0);
  }

  // ==========================================================
  // CANCEL
  // ==========================================================

  void cancelUpload() {
    final token = _cancelToken;

    if (token == null || token.isCancelled) {
      return;
    }

    token.cancel('Upload cancelled by user.');
  }

  // ==========================================================
  // RESULTS / ERRORS
  // ==========================================================

  void clearResults() {
    uploaded.clear();
    errorMessage.value = '';
  }

  void clearError() {
    errorMessage.value = '';
  }

  void _handleError(Object error) {
    if (error is DioException && CancelToken.isCancel(error)) {
      errorMessage.value = 'Upload cancelled.';
      return;
    }

    if (error is CloudinaryException) {
      errorMessage.value = error.message;
      return;
    }

    errorMessage.value = 'Unable to upload the selected file.';
  }

  String _extension(String name) {
    final index = name.lastIndexOf('.');

    if (index == -1 || index == name.length - 1) {
      return '';
    }

    return name.substring(index + 1).toLowerCase().trim();
  }

  @override
  void onClose() {
    _cancelToken?.cancel('Controller closed.');

    _cancelToken = null;

    super.onClose();
  }
}
