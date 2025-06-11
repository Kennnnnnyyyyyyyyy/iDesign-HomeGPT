import 'package:supabase_flutter/supabase_flutter.dart';

class GenerationLimitService {
  static const int freeDailyLimit = 10;

  Future<int> getTodayGenerationCount() async {
    final supabase = Supabase.instance.client;
    final uid = supabase.auth.currentUser?.id;

    if (uid == null) return 0;

    final now = DateTime.now().toUtc();
    final todayStart = DateTime.utc(now.year, now.month, now.day);

    final response = await supabase
        .from('ai_designs')
        .select('id')
        .eq('supabase_uid', uid)
        .gte('created_at', todayStart.toIso8601String());

    final designsToday = List<Map<String, dynamic>>.from(response);
    final countToday = designsToday.length;

    print('🎯 User generated $countToday designs today.');
    return countToday;
  }
}
