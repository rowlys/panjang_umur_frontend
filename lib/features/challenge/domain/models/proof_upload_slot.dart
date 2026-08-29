/// A one-time, time-limited permission to upload one file to object storage.
/// `imageId` is what you send back to `submit()` once the upload succeeds —
/// it's how the backend knows which uploaded object belongs to this submission.
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
