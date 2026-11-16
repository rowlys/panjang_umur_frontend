/// A one-time, time-limited permission to upload one avatar image.
class AvatarUploadSlot {
  final String uploadUrl;
  final String imageId;

  AvatarUploadSlot({required this.uploadUrl, required this.imageId});

  factory AvatarUploadSlot.fromJson(Map<String, dynamic> json) {
    return AvatarUploadSlot(
      uploadUrl: json['uploadURL'] as String,
      imageId: json['imageID'] as String,
    );
  }
}
