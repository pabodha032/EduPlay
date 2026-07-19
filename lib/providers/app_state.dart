import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  final _service = SupabaseService.instance;

  String? name;
  String? email;
  String role = 'student';
  int streakDays = 0;
  bool loadingProfile = false;

  bool get isLoggedIn => _service.isLoggedIn;
  bool get isTeacher => role == 'teacher';

  final Map<String, Map<int, int>> _progressCache = {};

  Future<void> loadProfile() async {
    loadingProfile = true;
    notifyListeners();
    try {
      final profile =
          await _service.bumpStreakIfNewDay() ?? await _service.fetchProfile();
      if (profile != null) {
        name = profile['name'] as String?;
        email = profile['email'] as String?;
        streakDays = profile['streak_days'] as int? ?? 0;
        role = profile['role'] as String? ?? 'student';
      }
    } finally {
      loadingProfile = false;
      notifyListeners();
    }
  }

  Future<String?> register(
      {required String name,
      required String email,
      required String password,
      String role = 'student'}) async {
    try {
      await _service.register(
          name: name, email: email, password: password, role: role);
      return null;
    } catch (e) {
      debugPrint('❌ REGISTER ERROR: $e');
      return _friendlyError(e);
    }
  }

  Future<String?> login(
      {required String email, required String password}) async {
    try {
      await _service.login(email: email, password: password);
      await loadProfile();
      return null;
    } catch (e) {
      debugPrint('❌ LOGIN ERROR: $e');
      return _friendlyError(e);
    }
  }

  Future<void> logout() async {
    await _service.logout();
    name = null;
    email = null;
    role = 'student';
    streakDays = 0;
    _progressCache.clear();
    notifyListeners();
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('Invalid login credentials')) {
      return 'Incorrect email or password.';
    }
    if (msg.contains('User already registered')) {
      return 'An account with this email already exists.';
    }
    if (msg.contains('Password should be')) {
      return 'Password must be at least 6 characters.';
    }
    if (msg.contains('Email not confirmed')) {
      return 'Please confirm your email before logging in.';
    }
    if (msg.contains('429') || msg.toLowerCase().contains('rate limit')) {
      return 'Too many attempts — please wait a few minutes and try again.';
    }
    if (msg.contains('Database error saving new user')) {
      return 'Server error creating your profile. Check that sql/trigger.sql was run in Supabase.';
    }
    if (msg.contains('SocketException') || msg.contains('Failed host lookup')) {
      return 'No internet connection. Please check your network and try again.';
    }
    return 'Something went wrong. Please try again.';
  }

  Future<Map<int, int>> progressFor(String category,
      {bool forceRefresh = false}) async {
    if (!forceRefresh && _progressCache.containsKey(category)) {
      return _progressCache[category]!;
    }
    final data = await _service.fetchProgress(category);
    _progressCache[category] = data;
    return data;
  }

  Future<List<GameLevel>> levelsFor(GameCategory category,
      {bool forceRefresh = false}) async {
    final stars = await progressFor(category.id, forceRefresh: forceRefresh);
    final highestCompleted =
        stars.keys.isEmpty ? 0 : stars.keys.reduce((a, b) => a > b ? a : b);

    return List.generate(category.totalLevels, (i) {
      final n = i + 1;
      LevelStatus status;
      if (stars.containsKey(n)) {
        status = LevelStatus.completed;
      } else if (n == highestCompleted + 1) {
        status = LevelStatus.unlocked;
      } else {
        status = LevelStatus.locked;
      }
      final difficulty = n <= 10 ? 'Easy' : (n <= 20 ? 'Medium' : 'Hard');
      return GameLevel(
          number: n,
          difficulty: difficulty,
          starsEarned: stars[n] ?? 0,
          status: status);
    });
  }

  Future<void> saveLevelResult(
      {required String category,
      required int levelNumber,
      required int stars}) async {
    await _service.saveLevelResult(
        category: category, levelNumber: levelNumber, stars: stars);
    await progressFor(category, forceRefresh: true);
    notifyListeners();
  }

  Future<List<StudentSummary>> fetchStudentSummaries() async {
    final students = await _service.fetchAllStudents();
    final allProgress = await _service.fetchAllProgress();

    return students.map((s) {
      final uid = s['id'] as String;
      final rowsForStudent = allProgress.where((p) => p['user_id'] == uid);

      final byCategory = <String, int>{};
      var stars = 0;
      for (final row in rowsForStudent) {
        final cat = row['category'] as String;
        byCategory[cat] = (byCategory[cat] ?? 0) + 1;
        stars += (row['stars_earned'] as int? ?? 0);
      }

      return StudentSummary(
        id: uid,
        name: s['name'] as String? ?? 'Unnamed',
        email: s['email'] as String? ?? '',
        streakDays: s['streak_days'] as int? ?? 0,
        completedLevelsByCategory: byCategory,
        totalStars: stars,
      );
    }).toList();
  }
}
