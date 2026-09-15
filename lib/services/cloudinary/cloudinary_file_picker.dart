import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';

import 'cloudinary_media_helper.dart';
import 'cloudinary_models.dart';

class CloudinaryFilePicker {
  CloudinaryFilePicker._();

  // ==========================================================
  // IMAGES
  // ==========================================================

  static Future<List<XFile>> pickImages({bool multiple = true}) async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: CloudinaryMediaHelper.imageExtensions.toList(),
    );

    if (!multiple && files.isNotEmpty) {
      return [files.first.xFile];
    }

    return files.map((file) => file.xFile).toList();
  }

  // ==========================================================
  // VIDEO
  // ==========================================================

  static Future<XFile?> pickVideo() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: CloudinaryMediaHelper.videoExtensions.toList(),
    );

    return file?.xFile;
  }

  // ==========================================================
  // GLB / GLTF
  // ==========================================================

  static Future<XFile?> pickGlb() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['glb', 'gltf', 'gltz'],
    );

    return file?.xFile;
  }

  // ==========================================================
  // USDZ
  // ==========================================================

  static Future<XFile?> pickUsdZ() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['usdz'],
    );

    return file?.xFile;
  }

  // ==========================================================
  // ANY FILE
  // ==========================================================

  static Future<List<XFile>> pickAnyFiles({bool multiple = true}) async {
    final files = await FilePicker.pickFiles(type: FileType.any);

    if (!multiple && files.isNotEmpty) {
      return [files.first.xFile];
    }

    return files.map((file) => file.xFile).toList();
  }

  // ==========================================================
  // MEDIA TYPE
  // ==========================================================

  static CloudinaryMediaKind kindOf(XFile file) {
    return CloudinaryMediaHelper.kindFromExtension(file.name);
  }
}
