class CloudinaryConfig {
  final String cloudName;
  final String unsignedUploadPreset;
  final String apiBaseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;

  const CloudinaryConfig({
    required this.cloudName,
    required this.unsignedUploadPreset,
    this.apiBaseUrl = 'https://api.cloudinary.com/v1_1',
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(minutes: 5),
    this.sendTimeout = const Duration(minutes: 10),
  });

  factory CloudinaryConfig.fromEnvironment() {
    const cloudName = String.fromEnvironment('CLOUDINARY_CLOUD_NAME');
    const preset = String.fromEnvironment('CLOUDINARY_UNSIGNED_PRESET');

    if (cloudName.isEmpty || preset.isEmpty) {
      throw const CloudinaryConfigException(
        'Cloudinary configuration is missing. Supply '
        'CLOUDINARY_CLOUD_NAME and CLOUDINARY_UNSIGNED_PRESET.',
      );
    }

    return const CloudinaryConfig(
      cloudName: cloudName,
      unsignedUploadPreset: preset,
    );
  }

  Uri uploadUri(String resourceType) {
    return Uri.parse(
      '$apiBaseUrl/$cloudName/$resourceType/upload',
    );
  }
}

class CloudinaryConfigException implements Exception {
  final String message;

  const CloudinaryConfigException(this.message);

  @override
  String toString() => 'CloudinaryConfigException($message)';
}
