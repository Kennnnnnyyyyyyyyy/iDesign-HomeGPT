import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedExteriorImageProvider = StateProvider<File?>((ref) => null);
final selectedBuildingTypeProvider = StateProvider<String?>((ref) => null);
final selectedExteriorStyleProvider = StateProvider<String?>((ref) => null);
final selectedPaletteProvider = StateProvider<String?>((ref) => null);
