import 'dart:isolate';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

Future<Uint8List?> convertCameraImageToJpeg(
    List<Uint8List> planes, List<int> bytesPerRow, List<int?> bytesPerPixel,
    int width, int height, ImageFormatGroup formatGroup, InputImageRotation rotation) async {
  return await Isolate.run(() {
    try {
      img.Image? imgImage;
      if (formatGroup == ImageFormatGroup.nv21) {
        imgImage = _convertNv21(planes, bytesPerRow, bytesPerPixel, width, height);
      } else if (formatGroup == ImageFormatGroup.bgra8888) {
        imgImage = _convertBgra8888(planes, width, height);
      }

      if (imgImage == null) return null;

      // Resize image to drastically reduce network payload
      // Insightface det_size is 160x160, so 320 is plenty of detail
      imgImage = img.copyResize(imgImage, width: 320);

      // Handle rotation
      if (rotation == InputImageRotation.rotation90deg) {
        imgImage = img.copyRotate(imgImage, angle: 90);
      } else if (rotation == InputImageRotation.rotation180deg) {
        imgImage = img.copyRotate(imgImage, angle: 180);
      } else if (rotation == InputImageRotation.rotation270deg) {
        imgImage = img.copyRotate(imgImage, angle: 270);
      }

      return img.encodeJpg(imgImage, quality: 70);
    } catch (e) {
      debugPrint('Error converting image: $e');
      return null;
    }
  });
}

img.Image? _convertNv21(List<Uint8List> planes, List<int> bytesPerRow, List<int?> bytesPerPixel, int width, int height) {
  final img.Image imgImage = img.Image(width: width, height: height);

  if (planes.length == 1) {
    // Single plane NV21
    final Uint8List bytes = planes[0];
    final int ySize = width * height;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int yIndex = y * width + x;
        final int uvIndex = ySize + (y ~/ 2) * width + (x ~/ 2) * 2;

        final int yp = bytes[yIndex];
        final int vp = bytes[uvIndex];
        final int up = bytes[uvIndex + 1];

        int r = (yp + vp * 1436 / 1024 - 179).round();
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round();
        int b = (yp + up * 1814 / 1024 - 227).round();

        imgImage.setPixelRgb(x, y, r.clamp(0, 255), g.clamp(0, 255), b.clamp(0, 255));
      }
    }
  } else {
    // Multi-plane YUV
    final Uint8List yBuffer = planes[0];
    final Uint8List vuBuffer = planes[1];
    
    final int yRowStride = bytesPerRow[0];
    final int uvRowStride = bytesPerRow[1];
    final int uvPixelStride = bytesPerPixel[1] ?? 2;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvX = x ~/ 2;
        final int uvY = y ~/ 2;
        final int yIndex = y * yRowStride + x;
        final int uvIndex = uvY * uvRowStride + uvX * uvPixelStride;

        final int yp = yBuffer[yIndex];
        final int vp = vuBuffer[uvIndex];
        final int up = vuBuffer[uvIndex + 1];

        int r = (yp + vp * 1436 / 1024 - 179).round();
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round();
        int b = (yp + up * 1814 / 1024 - 227).round();

        imgImage.setPixelRgb(x, y, r.clamp(0, 255), g.clamp(0, 255), b.clamp(0, 255));
      }
    }
  }

  return imgImage;
}

img.Image? _convertBgra8888(List<Uint8List> planes, int width, int height) {
  return img.Image.fromBytes(
    width: width,
    height: height,
    bytes: planes[0].buffer,
    order: img.ChannelOrder.bgra,
  );
}
