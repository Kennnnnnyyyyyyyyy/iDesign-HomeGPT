import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_designer_jasper/features/auth/providers/auth_provider.dart';

class AuthNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final repo = ref.read(authRepositoryProvider);
    final uid = await repo.getOrCreateAnonymousUser();
    return uid;
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, String>(
  () => AuthNotifier(),
);
