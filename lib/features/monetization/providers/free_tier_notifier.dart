import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_designer_jasper/core/services/entitlement_service.dart';
import 'package:interior_designer_jasper/core/services/generation_limit_service.dart';

class FreeTierNotifier extends AsyncNotifier<int> {
  final _generationLimitService = GenerationLimitService();
  final _entitlementService = EntitlementService();

  static const int freeDailyLimit = 10;

  @override
  Future<int> build() async {
    // Fetch today's generation count
    final count = await _generationLimitService.getTodayGenerationCount();
    return count;
  }

  /// Check if user is allowed to generate
  Future<bool> canGenerate() async {
    final hasPremium = await _entitlementService.hasPremium();

    if (hasPremium) {
      return true; // Unlimited access
    }

    final countToday = await _generationLimitService.getTodayGenerationCount();
    return countToday < freeDailyLimit;
  }
}

final freeTierNotifierProvider = AsyncNotifierProvider<FreeTierNotifier, int>(
  () => FreeTierNotifier(),
);
