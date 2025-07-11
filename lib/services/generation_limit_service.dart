import 'package:shared_preferences/shared_preferences.dart';

class GenerationLimitService {
  static const String _countKey = 'generation_count';
  static const String _dateKey = 'generation_date';

  Future<int> getGenerationCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastDate = prefs.getString(_dateKey);

    if (lastDate != today) {
      await prefs.setString(_dateKey, today);
      await prefs.setInt(_countKey, 0);
      return 0;
    }
    return prefs.getInt(_countKey) ?? 0;
  }

  Future<void> incrementGenerationCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = await getGenerationCount();
    await prefs.setInt(_countKey, count + 1);
  }

  Future<void> resetGenerationCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_countKey, 0);
  }
}
