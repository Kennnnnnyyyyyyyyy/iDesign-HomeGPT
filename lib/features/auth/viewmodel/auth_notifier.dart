import 'package:flutter_riverpod/flutter_riverpod.dart'
    show AsyncNotifier, AsyncNotifierProvider;
import 'package:interior_designer_jasper/core/repositories/auth_repository.dart';

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
