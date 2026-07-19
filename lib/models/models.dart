import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GameCategory {
  final String id;
  final String title;
  final String emoji;
  final Color color;
  final int totalLevels;

  const GameCategory({
    required this.id,
    required this.title,
    required this.emoji,
    required this.color,
    this.totalLevels = 30,
  });

  static const List<GameCategory> all = [
    GameCategory(
        id: 'math', title: 'Mathematics', emoji: '➕', color: AppColors.blue),
    GameCategory(
        id: 'english', title: 'English', emoji: '📚', color: AppColors.green),
    GameCategory(
        id: 'sinhala', title: 'Sinhala', emoji: 'අ', color: AppColors.orange),
    GameCategory(
        id: 'science', title: 'Science', emoji: '🔬', color: Color(0xFF9B7BFF)),
  ];
}

enum LevelStatus { locked, unlocked, completed }

class GameLevel {
  final int number;
  final String difficulty;
  final int starsEarned;
  final LevelStatus status;

  const GameLevel({
    required this.number,
    required this.difficulty,
    this.starsEarned = 0,
    this.status = LevelStatus.locked,
  });
}

class QuizQuestion {
  final String id;
  final String category;
  final String difficulty;
  final int? levelNumber;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const QuizQuestion({
    required this.id,
    required this.category,
    required this.difficulty,
    this.levelNumber,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'].toString(),
      category: map['category'] as String,
      difficulty: map['difficulty'] as String? ?? 'Easy',
      levelNumber: map['level_number'] as int?,
      prompt: map['prompt'] as String,
      options: List<String>.from(map['options'] as List),
      correctIndex: map['correct_index'] as int,
      explanation: map['explanation'] as String? ?? '',
    );
  }
}

class StudentSummary {
  final String id;
  final String name;
  final String email;
  final int streakDays;
  final Map<String, int> completedLevelsByCategory;
  final int totalStars;

  const StudentSummary({
    required this.id,
    required this.name,
    required this.email,
    required this.streakDays,
    required this.completedLevelsByCategory,
    required this.totalStars,
  });

  int get totalLevelsCompleted =>
      completedLevelsByCategory.values.fold(0, (a, b) => a + b);
}
