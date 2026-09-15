import 'dart:async';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart';

import 'cloudinary_config.dart';
import 'cloudinary_exception.dart';
import 'cloudinary_media_helper.dart';
import 'cloudinary_models.dart';

class CloudinaryService {
  CloudinaryService({
    required CloudinaryConfig config,
    Dio? dio,
  }) : _config = config,
       _dio = dio ?? Dio();

  final CloudinaryConfig _config;
  final Dio _dio;

  // ---------------------------------------------------------------------------
  // IMAGE UPLOADS
  // ---------------------------------------------------------------------------

  Future<CloudinaryUploadResult> uploadImage(
    XFile file, {
    CloudinaryUploadOptions options = const CloudinaryUploadOptions(),
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) {
    return upload(
      file,
      kind: CloudinaryMediaKind.image,
      options: options,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
    );
  }

  Future<List<CloudinaryUploadResult>> uploadImages(
    List<XFile> files, {
    CloudinaryUploadOptions options = const CloudinaryUploadOptions(),
    void Function(int index, int total)? onFileStart,
    void Function(int index, int total, CloudinaryUploadResult result)?
        onFileComplete,
    ProgressCallback? onCurrentFileProgress,
    CancelToken? cancelToken,
  }) async {
    if (files.isEmpty) return const [];

    final results = <CloudinaryUploadResult>[];

    for (var i = 0; i < files.length; i++) {
      onFileStart?.call(i, files.length);
      final result = await uploadImage(
        files[i],
        options: options,
        onSendProgress: onCurrentFileProgress,
        cancelToken: cancelToken,
      );
      results.add(result);
      onFileComplete?.call(i, files.length, result);
    }

    return results;
  }

  // ---------------------------------------------------------------------------
  // VIDEO UPLOAD
  // ---------------------------------------------------------------------------

  Future<CloudinaryUploadResult> uploadVideo(
    XFile file, {
    CloudinaryUploadOptions options = const CloudinaryUploadOptions(
      compressImage: false,
      maxBytes: 500 * 1024 * 1024,
    ),
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) {
    return upload(
      file,
      kind: CloudinaryMediaKind.video,
      options: options,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
    );
  }

  // ---------------------------------------------------------------------------
  // 3D UPLOAD
  // ---------------------------------------------------------------------------

  Future<CloudinaryUploadResult> upload3dModel(
    XFile file, {
    CloudinaryUploadOptions options = const CloudinaryUploadOptions(
      compressImage: false,
      maxBytes: 100 * 1024 * 1024,
    ),
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) {
    return upload(
      file,
      kind: CloudinaryMediaKind.model3d,
      options: options,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
    );
  }

  // Alias with normal Dart casing for callers that prefer model3D.
  Future<CloudinaryUploadResult> uploadModel3D(
    XFile file, {
    CloudinaryUploadOptions options = const CloudinaryUploadOptions(
      compressImage: false,
      maxBytes: 100 * 1024 * 1024,
    ),
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) {
    return upload3dModel(
      file,
      options: options,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
    );
  }

  // ---------------------------------------------------------------------------
  // GENERIC UPLOAD
  // ---------------------------------------------------------------------------

  Future<CloudinaryUploadResult> upload(
    XFile originalFile, {
    required CloudinaryMediaKind kind,
    CloudinaryUploadOptions options = const CloudinaryUploadOptions(),
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      CloudinaryMediaHelper.validateExtension(
        originalFile,
        kind: kind,
      );

      await CloudinaryMediaHelper.validateSize(
        originalFile,
        maxBytes: options.maxBytes,
      );

      final preparedFile = kind == CloudinaryMediaKind.image
          ? await CloudinaryMediaHelper.prepareImage(
              originalFile,
              options,
            )
          : originalFile;

      final bytes = await _readBytesSafely(preparedFile);

      // A compressed image can change its size, so validate again after
      // preparation as well.
      if (options.maxBytes != null && bytes.length > options.maxBytes!) {
        throw CloudinaryException(
          message: 'Prepared file is still too large. Maximum allowed is '
              '${CloudinaryMediaHelper.formatBytes(options.maxBytes!)}.',
          code: 'prepared_file_too_large',
        );
      }

      final resourceType = CloudinaryMediaHelper.resourceTypeFor(kind);
      final formData = FormData();

      formData.fields.add(
        MapEntry('upload_preset', _config.unsignedUploadPreset),
      );

      // These parameters are permitted for unsigned requests. Additional
      // restrictions should be configured in the Cloudinary upload preset.
      if (options.folder != null && options.folder!.trim().isNotEmpty) {
        formData.fields.add(
          MapEntry('folder', _cleanPath(options.folder!)),
        );
      }

      if (options.publicId != null && options.publicId!.trim().isNotEmpty) {
        formData.fields.add(
          MapEntry('public_id', _cleanPublicId(options.publicId!)),
        );
      }

      if (options.tags.isNotEmpty) {
        formData.fields.add(
          MapEntry('tags', options.tags.where((e) => e.trim().isNotEmpty).join(',')),
        );
      }

      if (options.context.isNotEmpty) {
        final contextPairs = options.context.entries
            .where(
              (entry) =>
                  entry.key.trim().isNotEmpty && entry.value.trim().isNotEmpty,
            )
            .map((entry) => '${_escapeContext(entry.key)}=${_escapeContext(entry.value)}')
            .join('|');

        if (contextPairs.isNotEmpty) {
          formData.fields.add(MapEntry('context', contextPairs));
        }
      }

      // `use_filename` and `unique_filename` are intentionally not sent
      // here because Cloudinary restricts client-supplied unsigned parameters.
      // Configure those behaviors in the unsigned upload preset instead.

      final mimeType = CloudinaryMediaHelper.mimeTypeOf(
        preparedFile.name,
      );

      formData.files.add(
        MapEntry(
          'file',
          MultipartFile.fromBytes(
            bytes,
            filename: _safeFilename(preparedFile.name),
            contentType: DioMediaType.parse(mimeType),
          ),
        ),
      );

      final response = await _dio.post<Map<String, dynamic>>(
        _config.uploadUri(resourceType.name).toString(),
        data: formData,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        options: Options(
          contentType: 'multipart/form-data',
          responseType: ResponseType.json,
        ),
      );

      final payload = _mapFromResponse(response.data);

      if (payload['error'] is Map) {
        throw CloudinaryException(
          message: 'Cloudinary rejected the upload.',
          code: 'cloudinary_rejected',
          statusCode: response.statusCode,
          cloudinaryMessage:
              Map<String, dynamic>.from(payload['error'] as Map)['message']
                  ?.toString(),
        );
      }

      final result = CloudinaryUploadResult.fromMap(
        payload,
        sourceFile: preparedFile,
        mediaKind: kind,
      );

      if (result.secureUrl.isEmpty || result.publicId.isEmpty) {
        throw CloudinaryException(
          message: 'Cloudinary returned an incomplete upload response.',
          code: 'invalid_response',
          statusCode: response.statusCode,
        );
      }

      return result;
    } on CloudinaryException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw CloudinaryException(
        message: 'Unable to upload the file to Cloudinary.',
        code: 'upload_failed',
        cause: e,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // DELIVERY HELPERS
  // ---------------------------------------------------------------------------

  String secureDeliveryUrl({
    required String publicId,
    CloudinaryResourceType resourceType = CloudinaryResourceType.image,
    String? format,
    String? transformation,
  }) {
    final cleanId = publicId.trim().replaceFirst(RegExp(r'^/+'), '');
    if (cleanId.isEmpty) {
      throw const CloudinaryException(
        message: 'Public ID is required to build a Cloudinary URL.',
        code: 'public_id_missing',
      );
    }

    final resourceSegment = switch (resourceType) {
      CloudinaryResourceType.image => 'image',
      CloudinaryResourceType.video => 'video',
      CloudinaryResourceType.raw => 'raw',
    };

    final encodedParts = cleanId
        .split('/')
        .map(Uri.encodeComponent)
        .join('/');

    final transformationPart = transformation == null || transformation.isEmpty
        ? ''
        : '${transformation.trim()}/';

    final extension = format == null || format.trim().isEmpty
        ? ''
        : '.${format.trim().replaceFirst('.', '')}';

    return 'https://res.cloudinary.com/${Uri.encodeComponent(_config.cloudName)}'
        '/$resourceSegment/upload/${transformationPart}$encodedParts$extension';
  }

  String imageUrl(
    String publicId, {
    int? width,
    int? height,
    int? quality,
    String crop = 'limit',
    String format = 'auto',
  }) {
    final transformations = <String>[];

    if (width != null || height != null) {
      final dimensions = [
        if (width != null) 'w_$width',
        if (height != null) 'h_$height',
        'c_$crop',
      ].join(',');
      transformations.add(dimensions);
    }

    transformations.add('q_${quality ?? 'auto'}');
    transformations.add('f_$format');

    return secureDeliveryUrl(
      publicId: publicId,
      resourceType: CloudinaryResourceType.image,
      transformation: transformations.join('/'),
    );
  }

  String videoUrl(
    String publicId, {
    String format = 'auto',
  }) {
    return secureDeliveryUrl(
      publicId: publicId,
      resourceType: CloudinaryResourceType.video,
      format: format,
    );
  }

  String model3dUrl(
    String publicId, {
    String format = 'glb',
  }) {
    return secureDeliveryUrl(
      publicId: publicId,
      resourceType: CloudinaryResourceType.image,
      format: format,
    );
  }

  String model3dUsdZUrl(String publicId) {
    return model3dUrl(publicId, format: 'usdz');
  }

  // ---------------------------------------------------------------------------
  // VALIDATION / UTILITY
  // ---------------------------------------------------------------------------

  Future<Uint8List> compressImageBytes(
    Uint8List source, {
    int quality = 82,
    int? maxWidth = 2200,
    int? maxHeight = 2200,
    bool keepExif = false,
    bool autoOrient = true,
  }) {
    return CloudinaryMediaHelper.compressImage(
      source,
      quality: quality,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      keepExif: keepExif,
      autoOrient: autoOrient,
    );
  }

  Future<Uint8List> readBytes(XFile file) {
    return _readBytesSafely(file);
  }

  String extensionOf(String name) {
    return CloudinaryMediaHelper.extensionOf(name);
  }

  String mimeTypeOf(String name) {
    return CloudinaryMediaHelper.mimeTypeOf(name);
  }

  CloudinaryMediaKind detectMediaKind(String name) {
    return CloudinaryMediaHelper.kindFromExtension(name);
  }

  Future<void> validateFile(
    XFile file, {
    required CloudinaryMediaKind kind,
    int? maxBytes,
  }) async {
    CloudinaryMediaHelper.validateExtension(file, kind: kind);
    await CloudinaryMediaHelper.validateSize(file, maxBytes: maxBytes);
  }

  Future<CloudinaryUploadResult> uploadBytes({
    required Uint8List bytes,
    required String filename,
    required CloudinaryMediaKind kind,
    CloudinaryUploadOptions options = const CloudinaryUploadOptions(),
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) {
    final file = XFile.fromData(
      bytes,
      name: filename,
      mimeType: CloudinaryMediaHelper.mimeTypeOf(filename),
    );

    return upload(
      file,
      kind: kind,
      options: options,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
    );
  }

  void cancel(CancelToken token) {
    if (!token.isCancelled) token.cancel('Upload cancelled by user.');
  }

  // ---------------------------------------------------------------------------
  // INTERNALS
  // ---------------------------------------------------------------------------

  Future<Uint8List> _readBytesSafely(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw const CloudinaryException(
          message: 'The selected file is empty.',
          code: 'file_empty',
        );
      }
      return bytes;
    } on CloudinaryException {
      rethrow;
    } catch (e) {
      throw CloudinaryException(
        message: 'Unable to read the selected file.',
        code: 'file_read_failed',
        cause: e,
      );
    }
  }

  Map<String, dynamic> _mapFromResponse(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    throw const CloudinaryException(
      message: 'Cloudinary returned an invalid response.',
      code: 'invalid_response',
    );
  }

  CloudinaryException _mapDioException(DioException error) {
    if (CancelToken.isCancel(error)) {
      return CloudinaryException(
        message: 'Upload cancelled.',
        code: 'cancelled',
        cause: error,
      );
    }

    final responseData = error.response?.data;
    String? cloudinaryMessage;

    if (responseData is Map) {
      final responseMap = Map<String, dynamic>.from(responseData);
      final nestedError = responseMap['error'];
      if (nestedError is Map) {
        cloudinaryMessage =
            Map<String, dynamic>.from(nestedError)['message']?.toString();
      }
      cloudinaryMessage ??= responseMap['message']?.toString();
    }

    final headerError = error.response?.headers.value('x-cld-error');
    cloudinaryMessage ??= headerError;

    final statusCode = error.response?.statusCode;

    if (statusCode == 400) {
      return CloudinaryException(
        message: 'Cloudinary rejected the upload request. Check the upload '
            'preset and file type.',
        code: 'bad_request',
        statusCode: statusCode,
        cloudinaryMessage: cloudinaryMessage,
        cause: error,
      );
    }

    if (statusCode == 401 || statusCode == 403) {
      return CloudinaryException(
        message: 'Cloudinary upload authorization failed. Check the unsigned '
            'upload preset configuration.',
        code: 'unauthorized',
        statusCode: statusCode,
        cloudinaryMessage: cloudinaryMessage,
        cause: error,
      );
    }

    if (statusCode == 413) {
      return CloudinaryException(
        message: 'The selected file is too large for this upload request.',
        code: 'payload_too_large',
        statusCode: statusCode,
        cloudinaryMessage: cloudinaryMessage,
        cause: error,
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return CloudinaryException(
        message: 'Cloudinary is temporarily unavailable. Please try again.',
        code: 'server_error',
        statusCode: statusCode,
        cloudinaryMessage: cloudinaryMessage,
        cause: error,
      );
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return CloudinaryException(
        message: 'The upload timed out. Check your internet connection and try again.',
        code: 'timeout',
        statusCode: statusCode,
        cloudinaryMessage: cloudinaryMessage,
        cause: error,
      );
    }

    return CloudinaryException(
      message: 'Cloudinary upload failed. Please try again.',
      code: 'network_error',
      statusCode: statusCode,
      cloudinaryMessage: cloudinaryMessage,
      cause: error,
    );
  }

  String _cleanPath(String value) {
    return value.trim().replaceAll(RegExp(r'^/+|/+$'), '');
  }

  String _cleanPublicId(String value) {
    return value.trim().replaceFirst(RegExp(r'^/+'), '');
  }

  String _safeFilename(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'upload';

    return trimmed.replaceAll(RegExp(r'[\\/:*?"<>|]+'), '_');
  }

  String _escapeContext(String value) {
    return value
        .replaceAll(r'\\', r'\\\\')
        .replaceAll('|', r'\\|')
        .replaceAll('=', r'\\=');
  }
}
