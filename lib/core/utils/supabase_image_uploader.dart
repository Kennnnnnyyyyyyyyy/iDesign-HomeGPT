import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseImageUploader {
  static Future<Map<String, String>?> upload({
    required dynamic image,
    String folder = 'uploads',
    int retries = 3,
  }) async {
    final supabase = Supabase.instance.client;

    try {
      String fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$folder/$fileName';

      if (image is File) {
        await supabase.storage
            .from('temp-image')
            .upload(
              path,
              image,
              fileOptions: const FileOptions(contentType: 'image/jpeg'),
            );
      } else if (image is Uint8List) {
        await supabase.storage
            .from('temp-image')
            .uploadBinary(
              path,
              image,
              fileOptions: const FileOptions(contentType: 'image/png'),
            );
      } else {
        throw Exception('Unsupported image type');
      }

      final publicUrl = supabase.storage.from('temp-image').getPublicUrl(path);
      return {'publicUrl': publicUrl, 'filePath': '/$path'};
    } catch (e) {
      print('❌ Supabase upload error: $e');
      return null;
    }
  }
}
