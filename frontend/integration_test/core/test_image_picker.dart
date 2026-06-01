import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:io';

import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

class TestImagePicker {
  TestImagePicker._();

  static Future<XFile> createTempPngFile({String? fileName}) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final paint = ui.Paint()..color = const ui.Color(0xFF2ECC71);
    canvas.drawRect(const ui.Rect.fromLTWH(0, 0, 64, 64), paint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(64, 64);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData?.buffer.asUint8List();
    if (bytes == null || bytes.isEmpty) {
      throw StateError('Failed to generate test PNG image bytes.');
    }

    final directory = await Directory.systemTemp.createTemp('e2e_media_');
    final pngFile = File(
      '${directory.path}${Platform.pathSeparator}${fileName ?? 'e2e_post_image.png'}',
    );

    await pngFile.writeAsBytes(bytes, flush: true);
    return XFile(pngFile.path, mimeType: 'image/png');
  }

  static Future<void> installGalleryImagePicker({String? fileName}) async {
    final file = await createTempPngFile(fileName: fileName);
    ImagePickerPlatform.instance = _FakeImagePickerPlatform([file]);
  }

}

class _FakeImagePickerPlatform extends ImagePickerPlatform {
  _FakeImagePickerPlatform(this._pickedImages);

  final List<XFile> _pickedImages;

  @override
  Future<XFile?> getImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    if (_pickedImages.isEmpty) {
      return null;
    }

    return _pickedImages.first;
  }

  @override
  Future<List<XFile>?> getMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    return List<XFile>.unmodifiable(_pickedImages);
  }

  @override
  Future<List<XFile>> getMedia({required MediaOptions options}) async {
    return List<XFile>.unmodifiable(_pickedImages);
  }

  @override
  Future<XFile?> getVideo({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) async {
    return null;
  }

  @override
  Future<List<XFile>> getMultiVideoWithOptions({
    MultiVideoPickerOptions options = const MultiVideoPickerOptions(),
  }) async {
    return <XFile>[];
  }

  @override
  Future<LostDataResponse> getLostData() async {
    return LostDataResponse.empty();
  }

  @override
  bool supportsImageSource(ImageSource source) {
    return source == ImageSource.gallery || source == ImageSource.camera;
  }
}
