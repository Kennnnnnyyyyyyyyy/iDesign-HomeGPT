import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:interior_designer_jasper/core/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabase = Supabase.instance.client;
  final storage = ref.read(secureStorageProvider);
  return AuthRepository(supabase, storage);
});
