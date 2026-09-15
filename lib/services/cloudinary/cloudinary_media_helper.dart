import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'cloudinary_exception.dart';
import 'cloudinary_models.dart';

class CloudinaryMediaHelper {
  CloudinaryMediaHelper._();

  static const imageExtensions = {
    'jpg', 'jpeg', 'png', 'webp', 'heic', 'heif',
  };

  static const videoExtensions = {
    'mp4', 'mov', 'm4v', 'webm', 'avi', 'mkv', '3gp',
  };

  static const model3dExtensions = {
    'glb', 'gltf', 'gltz', 'obj', 'fbx', 'usdz', 'ply', '3ds', 'zip',
  };

  static String extensionOf(String name) {
    final clean = name.split('?').first.split('#').first.trim();
    final dot = clean.lastIndexOf('.');
    if (dot < 0 || dot == clean.length - 1) return '';
    return clean.substring(dot + 1).toLowerCase();
  }

  static String fileNameWithoutExtension(String name) {
    final clean = name.split('?').first.split('#').first.trim();
    final lastSlash = clean.lastIndexOf(RegExp(r'[/\\]'));
    final base = lastSlash >= 0 ? clean.substring(lastSlash + 1) : clean;
    final dot = base.lastIndexOf('.');
    return dot > 0 ? base.substring(0, dot) : base;
  }

  static String mimeTypeOf(String name) {
    switch (extensionOf(name)) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      case 'heif':
        return 'image/heif';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'm4v':
        return 'video/x-m4v';
      case 'webm':
        return 'video/webm';
      case 'avi':
        return 'video/x-msvideo';
      case 'mkv':
        return 'video/x-matroska';
      case '3gp':
        return 'video/3gpp';
      case 'glb':
        return 'model/gltf-binary';
      case 'gltf':
        return 'model/gltf+json';
      case 'gltz':
        return 'model/gltf+zip';
      case 'obj':
        return 'text/plain';
      case 'fbx':
        return 'application/octet-stream';
      case 'usdz':
        return 'model/vnd.usdz+zip';
      case 'ply':
        return 'application/octet-stream';
      case '3ds':
      case 'zip':
        return 'application/zip';
      default:
        return 'application/octet-stream';
    }
  }

  static CloudinaryMediaKind kindFromExtension(String name) {
    final ext = extensionOf(name);
    if (imageExtensions.contains(ext)) return CloudinaryMediaKind.image;
    if (videoExtensions.contains(ext)) return CloudinaryMediaKind.video;
    if (model3dExtensions.contains(ext)) return CloudinaryMediaKind.model3d;
    return CloudinaryMediaKind.file;
  }

  static CloudinaryResourceType resourceTypeFor(
    CloudinaryMediaKind kind,
  ) {
    switch (kind) {
      case CloudinaryMediaKind.image:
        return CloudinaryResourceType.image;
      case CloudinaryMediaKind.video:
        return CloudinaryResourceType.video;
      case CloudinaryMediaKind.model3d:
        // Cloudinary treats 3D models as image assets for 3D delivery
        // and transformations.
        return CloudinaryResourceType.image;
      case CloudinaryMediaKind.file:
        return CloudinaryResourceType.raw;
    }
  }

  static Future<Uint8List> compressImage(
    Uint8List source, {
    int quality = 82,
    int? maxWidth = 2200,
    int? maxHeight = 2200,
    bool keepExif = false,
    bool autoOrient = true,
  }) async {
    try {
      final compressed = await FlutterImageCompress.compressWithList(
        source,
        minWidth: maxWidth ?? 1,
        minHeight: maxHeight ?? 1,
        quality: quality.clamp(1, 100),
        format: CompressFormat.jpeg,
        keepExif: keepExif,
        autoCorrectionAngle: autoOrient,
      );

      if (compressed.isEmpty) {
        throw const CloudinaryException(
          message: 'Image compression returned an empty file.',
          code: 'compression_empty',
        );
      }

      return compressed;
    } on CloudinaryException {
      rethrow;
    } on UnsupportedError catch (e) {
      throw CloudinaryException(
        message: 'Image compression is not supported on this platform.',
        code: 'compression_unsupported',
        cause: e,
      );
    } catch (e) {
      throw CloudinaryException(
        message: 'Unable to compress the image.',
        code: 'compression_failed',
        cause: e,
      );
    }
  }

  static Future<XFile> compressedImageFile(
    XFile source, {
    int quality = 82,
    int? maxWidth = 2200,
    int? maxHeight = 2200,
    bool keepExif = false,
    bool autoOrient = true,
  }) async {
    final bytes = await source.readAsBytes();
    final compressed = await compressImage(
      bytes,
      quality: quality,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      keepExif: keepExif,
      autoOrient: autoOrient,
    );

    final baseName = fileNameWithoutExtension(source.name);

    return XFile.fromData(
      compressed,
      name: '${baseName}_compressed.jpg',
      mimeType: 'image/jpeg',
    );
  }

  static Future<XFile> prepareImage(
    XFile source,
    CloudinaryUploadOptions options,
  ) async {
    if (!options.compressImage) return source;

    return compressedImageFile(
      source,
      quality: options.imageQuality,
      maxWidth: options.imageMaxWidth,
      maxHeight: options.imageMaxHeight,
      keepExif: options.keepExif,
      autoOrient: options.autoOrient,
    );
  }

  static void validateExtension(
    XFile file, {
    required CloudinaryMediaKind kind,
  }) {
    final ext = extensionOf(file.name);
    if (ext.isEmpty) {
      throw const CloudinaryException(
        message: 'The selected file has no recognizable extension.',
        code: 'extension_missing',
      );
    }

    final allowed = switch (kind) {
      CloudinaryMediaKind.image => imageExtensions,
      CloudinaryMediaKind.video => videoExtensions,
      CloudinaryMediaKind.model3d => model3dExtensions,
      CloudinaryMediaKind.file => null,
    };

    if (allowed != null && !allowed.contains(ext)) {
      throw CloudinaryException(
        message: 'Unsupported ${kind.name} file format: .$ext',
        code: 'extension_not_allowed',
      );
    }
  }

  static Future<void> validateSize(
    XFile file, {
    int? maxBytes,
  }) async {
    if (maxBytes == null) return;

    final bytes = await file.length();
    if (bytes > maxBytes) {
      throw CloudinaryException(
        message: 'File is too large. Maximum allowed is '
            '${formatBytes(maxBytes)}.',
        code: 'file_too_large',
      );
    }
  }

  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
