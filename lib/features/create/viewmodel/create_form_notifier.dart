import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// -------- State Class --------
class CreateFormState {
  final Object? image;
  final String room;
  final String style;
  final String palette;
  final String? imageUrl;

  const CreateFormState({
    this.image,
    this.room = 'Living Room',
    this.style = 'Modern',
    this.palette = 'Surprise Me',
    this.imageUrl,
  });

  CreateFormState copyWith({
    Object? image,
    String? room,
    String? style,
    String? palette,
    String? imageUrl,
  }) {
    return CreateFormState(
      image: image ?? this.image,
      room: room ?? this.room,
      style: style ?? this.style,
      palette: palette ?? this.palette,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

// -------- Notifier Class --------
class CreateFormNotifier extends StateNotifier<CreateFormState> {
  CreateFormNotifier() : super(const CreateFormState());

  void setImage(Object? image) => state = state.copyWith(image: image);
  void setRoom(String room) => state = state.copyWith(room: room);
  void setStyle(String style) => state = state.copyWith(style: style);
  void setPalette(String palette) => state = state.copyWith(palette: palette);
  void setImageUrl(String url) => state = state.copyWith(imageUrl: url);

  /// ✅ RESET FUNCTION
  void reset() => state = const CreateFormState();

  String getPrompt() {
    final palette =
        state.palette.trim().toLowerCase() == 'surprise me'
            ? 'any color'
            : state.palette.toLowerCase();

    return '''
Generate a ${state.style} style ${state.room.toLowerCase()} interior design using a $palette color palette.
'''.trim();
  }

  /// Image Upload Logic
  Future<Map<String, String>?> uploadImageToSupabase({int retries = 3}) async {
    final image = state.image;

    if (image == null) {
      print('⚠️ No image selected.');
      return null;
    }

    final supabase = Supabase.instance.client;

    if (image is File) {
      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = 'uploads/$fileName';

      for (int attempt = 0; attempt < retries; attempt++) {
        try {
          print("📤 Uploading file attempt ${attempt + 1}...");
          await supabase.storage
              .from('temp-image')
              .upload(
                storagePath,
                image,
                fileOptions: const FileOptions(
                  upsert: true,
                  contentType: 'image/jpeg',
                ),
              );

          final publicUrl = supabase.storage
              .from('temp-image')
              .getPublicUrl(storagePath);
          print('✅ Upload successful:\nURL: $publicUrl\nPath: /$storagePath');
          setImageUrl(publicUrl);
          return {'publicUrl': publicUrl, 'filePath': '/$storagePath'};
        } catch (e) {
          print('❌ Upload attempt ${attempt + 1} failed: $e');
          if (attempt == retries - 1) return null;
          await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
        }
      }
    } else if (image is String && image.startsWith('assets/')) {
      try {
        print("📤 Uploading asset image...");
        final byteData = await rootBundle.load(image);
        final bytes = byteData.buffer.asUint8List();
        final fileName = 'asset_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final storagePath = 'uploads/$fileName';

        await supabase.storage
            .from('temp-image')
            .uploadBinary(
              storagePath,
              bytes,
              fileOptions: const FileOptions(contentType: 'image/jpeg'),
            );

        final publicUrl = supabase.storage
            .from('temp-image')
            .getPublicUrl(storagePath);
        print(
          '✅ Asset upload successful:\nURL: $publicUrl\nPath: /$storagePath',
        );
        setImageUrl(publicUrl);
        return {'publicUrl': publicUrl, 'filePath': '/$storagePath'};
      } catch (e) {
        print('❌ Asset upload failed: $e');
        return null;
      }
    } else if (image is String && image.startsWith('http')) {
      print('🌐 Using hosted image URL directly:\n$image');
      setImageUrl(image);
      return {'publicUrl': image, 'filePath': ''};
    }

    print('❌ Unsupported image type. Value: $image');
    return null;
  }
}

// -------- Provider --------
final createFormProvider =
    StateNotifierProvider<CreateFormNotifier, CreateFormState>(
      (ref) => CreateFormNotifier(),
    );
