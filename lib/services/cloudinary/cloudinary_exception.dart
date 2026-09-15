class CloudinaryException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final String? cloudinaryMessage;
  final Object? cause;

  const CloudinaryException({
    required this.message,
    this.code,
    this.statusCode,
    this.cloudinaryMessage,
    this.cause,
  });

  @override
  String toString() {
    final parts = <String>[message];
    if (code != null && code!.isNotEmpty) parts.add('code=$code');
    if (statusCode != null) parts.add('status=$statusCode');
    if (cloudinaryMessage != null && cloudinaryMessage!.isNotEmpty) {
      parts.add('details=$cloudinaryMessage');
    }
    return 'CloudinaryException(${parts.join(', ')})';
  }
}
