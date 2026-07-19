import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/app_state.dart';
import '../../widgets/common_widgets.dart';
import '../splash_screen.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  late Future<List<StudentSummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<AppState>().fetchStudentSummaries();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = context.read<AppState>().fetchStudentSummaries();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.contentGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Teacher Dashboard', style: AppText.h1),
                          Text('Hello, ${app.name ?? '...'} 👋', style: AppText.bodyMuted),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await context.read<AppState>().logout();
                        if (!context.mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const SplashScreen()), (r) => false);
                      },
                      icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: FutureBuilder<List<StudentSummary>>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final students = snapshot.data!;
                      if (students.isEmpty) {
                        return ListView(
                          padding: const EdgeInsets.all(20),
                          children: [
                            const SizedBox(height: 40),
                            Center(child: Text('No students registered yet.', style: AppText.body)),
                          ],
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        itemCount: students.length,
                        itemBuilder: (context, i) {
                          final s = students[i];
                          return _StudentCard(student: s).animate(delay: (i * 60).ms).fadeIn().slideY(begin: 0.08, end: 0);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final StudentSummary student;
  const _StudentCard({required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 22, backgroundColor: AppColors.blue.withValues(alpha: 0.15), child: const Text('🐘', style: TextStyle(fontSize: 20))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name, style: AppText.body.copyWith(fontWeight: FontWeight.w700)),
                      Text(student.email, style: AppText.bodyMuted.copyWith(fontSize: 12)),
                    ],
                  ),
                ),
                StatPill(emoji: '🔥', value: '${student.streakDays}d', color: AppColors.orange),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _MiniStat(label: 'Levels Done', value: '${student.totalLevelsCompleted}')),
                const SizedBox(width: 10),
                Expanded(child: _MiniStat(label: 'Total Stars', value: '${student.totalStars} ⭐')),
              ],
            ),
            if (student.completedLevelsByCategory.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: student.completedLevelsByCategory.entries.map((e) {
                  final cat = GameCategory.all.firstWhere((c) => c.id == e.key, orElse: () => GameCategory.all.first);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: cat.color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(AppRadius.pill)),
                    child: Text('${cat.emoji} ${cat.title}: ${e.value}', style: AppText.bodyMuted.copyWith(fontSize: 12, color: cat.color, fontWeight: FontWeight.w700)),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(AppRadius.sm)),
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(value, style: AppText.h2.copyWith(fontSize: 16)),
          Text(label, style: AppText.bodyMuted.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}
