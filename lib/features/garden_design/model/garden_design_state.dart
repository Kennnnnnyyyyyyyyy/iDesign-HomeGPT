import 'dart:io';
import 'package:flutter/material.dart';

class GardenDesignState {
  final File? imageFile;
  final String? assetPath;
  final String? style;
  final String? palette;
  final bool isLoading;
  final String? outputUrl;

  GardenDesignState({
    this.imageFile,
    this.assetPath,
    this.style,
    this.palette,
    this.isLoading = false,
    this.outputUrl,
  });

  GardenDesignState copyWith({
    File? imageFile,
    String? assetPath,
    String? style,
    String? palette,
    bool? isLoading,
    String? outputUrl,
  }) {
    return GardenDesignState(
      imageFile: imageFile ?? this.imageFile,
      assetPath: assetPath ?? this.assetPath,
      style: style ?? this.style,
      palette: palette ?? this.palette,
      isLoading: isLoading ?? this.isLoading,
      outputUrl: outputUrl ?? this.outputUrl,
    );
  }
}
