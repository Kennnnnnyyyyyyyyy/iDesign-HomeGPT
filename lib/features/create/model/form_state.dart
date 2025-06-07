class CreateFormState {
  final dynamic image; // File or asset path
  final String room;
  final String style;
  final String palette;
  final String? imageUrl; // ✅ After uploading to Supabase

  const CreateFormState({
    this.image,
    this.room = '',
    this.style = '',
    this.palette = '',
    this.imageUrl,
  });

  CreateFormState copyWith({
    dynamic image,
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
