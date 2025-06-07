import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A pure Dart function that extracts the `output` image URL from a Replicate-style response.
String? extractOutputUrlFromResponse(String responseBody) {
  try {
    final data = jsonDecode(responseBody);

    // Replicate sometimes returns a list of strings instead of a single string
    final output = data['output'];

    if (output is String) {
      return output;
    } else if (output is List && output.isNotEmpty && output.first is String) {
      return output.first;
    }

    print('⚠️ Output field format not recognized: $output');
    return null;
  } catch (e) {
    print('❌ Failed to parse Replicate output: $e');
    return null;
  }
}

/// A Riverpod provider that exposes the function
final replicateOutputParserProvider = Provider<Function(String)>(
  (ref) => extractOutputUrlFromResponse,
);
