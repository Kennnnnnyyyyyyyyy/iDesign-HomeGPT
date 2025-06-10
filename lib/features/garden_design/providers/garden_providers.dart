import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stores the selected garden style (e.g., "Modern", "Zen", etc.)
final selectedGardenStyleProvider = StateProvider<String?>((ref) => null);

/// Stores the selected garden palette (e.g., "Warm", "Cool", etc.)
final selectedGardenPaletteProvider = StateProvider<String?>((ref) => null);
