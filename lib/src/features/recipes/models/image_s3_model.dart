class UploadImageResponse {
  final String imageUrl;
  final String originalFileName;

  UploadImageResponse({
    required this.imageUrl,
    required this.originalFileName,
  });

  factory UploadImageResponse.fromJson(Map<String, dynamic> json) {
    return UploadImageResponse(
      imageUrl: json['imageUrl'],
      originalFileName: json['originalFileName'],
    );
  }
}