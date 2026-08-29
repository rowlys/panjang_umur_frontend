/// A one-time, time-limited permission to upload one file to object storage.
class ProofUploadSlot {
  final String uploadUrl;
  final String imageId;

  ProofUploadSlot({required this.uploadUrl, required this.imageId});

  factory ProofUploadSlot.fromJson(Map<String, dynamic> json) {
    return ProofUploadSlot(
      uploadUrl: json['uploadURL'] as String,
      imageId: json['imageID'] as String,
    );
  }
}
