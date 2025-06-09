import 'dart:io';
import 'package:image/image.dart' as img;

/// Fixes HEIC/iPhone photo color (sRGB) and orientation
Future<File> fixImageColorProfile(File file) async {
  final bytes = await file.readAsBytes();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return file;

  final fixedImage = img.bakeOrientation(decoded); // Fix EXIF rotation
  final jpg = img.encodeJpg(fixedImage, quality: 95); // Convert to sRGB
  return file.writeAsBytes(jpg, flush: true);
}
