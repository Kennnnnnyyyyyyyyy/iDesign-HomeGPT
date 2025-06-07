import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final replicateOutputParserProvider = Provider<String? Function(String)>((ref) {
  return (String responseBody) {
    final json = jsonDecode(responseBody);

    final outputUrl = json['replicateOutputUrl'];
    if (outputUrl is String && outputUrl.isNotEmpty) {
      return outputUrl;
    }

    return null;
  };
});
