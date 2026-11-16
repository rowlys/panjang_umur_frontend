import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

/// Crops a picture to a square and returns a compact JPEG.
class AvatarCropScreen extends StatefulWidget {
  final Uint8List imageBytes;

  const AvatarCropScreen({super.key, required this.imageBytes});

  @override
  State<AvatarCropScreen> createState() => _AvatarCropScreenState();
}

/// Runs off the UI isolate on mobile so a large photo does not jank the crop
/// screen while it is being resized and encoded.
Uint8List? _encodeAvatar(Uint8List croppedImage) {
  final decoded = img.decodeImage(croppedImage);
  if (decoded == null) return null;

  const outputSize = 512;
  final resized = img.copyResize(
    decoded,
    width: outputSize,
    height: outputSize,
    interpolation: img.Interpolation.average,
  );
  return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
}

class _AvatarCropScreenState extends State<AvatarCropScreen> {
  final _controller = CropController();
  bool _isCropping = false;

  void _crop() {
    if (_isCropping) return;
    setState(() => _isCropping = true);
    _controller.crop();
  }

  Future<void> _handleCropped(CropResult result) async {
    if (!mounted) return;

    switch (result) {
      case CropSuccess(:final croppedImage):
        final avatar = await compute(_encodeAvatar, croppedImage);
        if (!mounted) return;

        if (avatar == null) {
          _showError();
          return;
        }
        Navigator.of(context).pop(avatar);
      case CropFailure():
        _showError();
    }
  }

  void _showError() {
    if (!mounted) return;
    setState(() => _isCropping = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not crop that photo. Try another one.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Crop photo'),
        actions: [
          TextButton(
            onPressed: _isCropping ? null : _crop,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: _isCropping
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Done'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Crop(
                image: widget.imageBytes,
                controller: _controller,
                onCropped: _handleCropped,
                aspectRatio: 1,
                interactive: true,
                fixCropRect: true,
                baseColor: Colors.black,
                maskColor: Colors.black.withValues(alpha: 0.55),
                radius: 8,
                cornerDotBuilder: (size, edgeAlignment) => const SizedBox.shrink(),
                progressIndicator: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Pinch to zoom, drag to move. The photo will be saved as a square.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
