// model
class CreateDesignInput {
  final Object? image;
  final String room;
  final String style;
  final String palette;

  CreateDesignInput({
    required this.image,
    required this.room,
    required this.style,
    required this.palette,
  });

  String toPrompt() {
    return "Design a $style $room with a $palette palette using this image";
  }
}
