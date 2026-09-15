import 'package:cross_file/cross_file.dart';

enum CloudinaryResourceType {
  image,
  video,
  raw,
}

enum CloudinaryMediaKind {
  image,
  video,
  model3d,
  file,
}

class CloudinaryUploadOptions {
  final String? folder;
  final String? publicId;
  final List<String> tags;
  final Map<String, String> context;
  final bool useFilename;
  final String? filenameOverride;
  final bool uniqueFilename;
  final int? maxBytes;
  final bool compressImage;
  final int imageQuality;
  final int? imageMaxWidth;
  final int? imageMaxHeight;
  final bool keepExif;
  final bool autoOrient;

  const CloudinaryUploadOptions({
    this.folder,
    this.publicId,
    this.tags = const [],
    this.context = const {},
    this.useFilename = true,
    this.filenameOverride,
    this.uniqueFilename = true,
    this.maxBytes,
    this.compressImage = true,
    this.imageQuality = 82,
    this.imageMaxWidth = 2200,
    this.imageMaxHeight = 2200,
    this.keepExif = false,
    this.autoOrient = true,
  });

  CloudinaryUploadOptions copyWith({
    String? folder,
    String? publicId,
    List<String>? tags,
    Map<String, String>? context,
    bool? useFilename,
    String? filenameOverride,
    bool? uniqueFilename,
    int? maxBytes,
    bool? compressImage,
    int? imageQuality,
    int? imageMaxWidth,
    int? imageMaxHeight,
    bool? keepExif,
    bool? autoOrient,
  }) {
    return CloudinaryUploadOptions(
      folder: folder ?? this.folder,
      publicId: publicId ?? this.publicId,
      tags: tags ?? this.tags,
      context: context ?? this.context,
      useFilename: useFilename ?? this.useFilename,
      filenameOverride: filenameOverride ?? this.filenameOverride,
      uniqueFilename: uniqueFilename ?? this.uniqueFilename,
      maxBytes: maxBytes ?? this.maxBytes,
      compressImage: compressImage ?? this.compressImage,
      imageQuality: imageQuality ?? this.imageQuality,
      imageMaxWidth: imageMaxWidth ?? this.imageMaxWidth,
      imageMaxHeight: imageMaxHeight ?? this.imageMaxHeight,
      keepExif: keepExif ?? this.keepExif,
      autoOrient: autoOrient ?? this.autoOrient,
    );
  }
}

class CloudinaryUploadResult {
  final String assetId;
  final String publicId;
  final String version;
  final String resourceType;
  final String format;
  final String secureUrl;
  final String url;
  final String? assetFolder;
  final String? originalFilename;
  final int bytes;
  final int? width;
  final int? height;
  final int? duration;
  final String? createdAt;
  final XFile sourceFile;
  final CloudinaryMediaKind mediaKind;

  const CloudinaryUploadResult({
    required this.assetId,
    required this.publicId,
    required this.version,
    required this.resourceType,
    required this.format,
    required this.secureUrl,
    required this.url,
    required this.bytes,
    required this.sourceFile,
    required this.mediaKind,
    this.assetFolder,
    this.originalFilename,
    this.width,
    this.height,
    this.duration,
    this.createdAt,
  });

  bool get isImage => mediaKind == CloudinaryMediaKind.image;
  bool get isVideo => mediaKind == CloudinaryMediaKind.video;
  bool get is3d => mediaKind == CloudinaryMediaKind.model3d;

  factory CloudinaryUploadResult.fromMap(
    Map<String, dynamic> map, {
    required XFile sourceFile,
    required CloudinaryMediaKind mediaKind,
  }) {
    return CloudinaryUploadResult(
      assetId: map['asset_id']?.toString() ?? '',
      publicId: map['public_id']?.toString() ?? '',
      version: map['version']?.toString() ?? '',
      resourceType: map['resource_type']?.toString() ?? '',
      format: map['format']?.toString() ?? '',
      secureUrl: map['secure_url']?.toString() ?? '',
      url: map['url']?.toString() ?? '',
      assetFolder: map['asset_folder']?.toString(),
      originalFilename: map['original_filename']?.toString(),
      bytes: _toInt(map['bytes']),
      width: _toNullableInt(map['width']),
      height: _toNullableInt(map['height']),
      duration: _toNullableInt(map['duration']),
      createdAt: map['created_at']?.toString(),
      sourceFile: sourceFile,
      mediaKind: mediaKind,
    );
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
