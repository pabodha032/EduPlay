import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  SupabaseClient get _client => Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> register(
      {required String name,
      required String email,
      required String password,
      String role = 'student'}) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'role': role},
    );
  }

  Future<void> login({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }

  Future<Map<String, dynamic>?> fetchProfile() async {
    final uid = currentUser?.id;
    if (uid == null) return null;
    final row =
        await _client.from('profiles').select().eq('id', uid).maybeSingle();
    return row;
  }

  Future<Map<String, dynamic>?> bumpStreakIfNewDay() async {
    final uid = currentUser?.id;
    if (uid == null) return null;
    final profile = await fetchProfile();
    if (profile == null) return null;

    final todayStr = DateTime.now().toIso8601String().split('T').first;
    final lastActive = profile['last_active_date'] as String?;

    if (lastActive == todayStr) return profile;

    final newStreak = (profile['streak_days'] as int? ?? 0) + 1;
    final updated = await _client
        .from('profiles')
        .update({'streak_days': newStreak, 'last_active_date': todayStr})
        .eq('id', uid)
        .select()
        .single();
    return updated;
  }

  Future<List<QuizQuestion>> fetchQuestions(String category) async {
    final rows =
        await _client.from('questions').select().eq('category', category);
    return (rows as List)
        .map((r) => QuizQuestion.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  Future<Map<int, int>> fetchProgress(String category) async {
    final uid = currentUser?.id;
    if (uid == null) return {};
    final rows = await _client
        .from('user_progress')
        .select('level_number, stars_earned')
        .eq('user_id', uid)
        .eq('category', category);
    return {
      for (final r in rows as List)
        r['level_number'] as int: r['stars_earned'] as int
    };
  }

  Future<void> saveLevelResult(
      {required String category,
      required int levelNumber,
      required int stars}) async {
    final uid = currentUser?.id;
    if (uid == null) return;

    final existing = await _client
        .from('user_progress')
        .select('stars_earned')
        .eq('user_id', uid)
        .eq('category', category)
        .eq('level_number', levelNumber)
        .maybeSingle();

    if (existing != null && (existing['stars_earned'] as int) >= stars) {
      return;
    }

    await _client.from('user_progress').upsert({
      'user_id': uid,
      'category': category,
      'level_number': levelNumber,
      'stars_earned': stars,
      'completed_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,category,level_number');
  }

  Future<List<Map<String, dynamic>>> fetchAllStudents() async {
    final rows = await _client
        .from('profiles')
        .select()
        .eq('role', 'student')
        .order('name');
    return List<Map<String, dynamic>>.from(rows as List);
  }

  Future<List<Map<String, dynamic>>> fetchAllProgress() async {
    final rows = await _client.from('user_progress').select();
    return List<Map<String, dynamic>>.from(rows as List);
  }
}
