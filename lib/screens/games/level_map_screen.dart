import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/app_state.dart';
import '../quiz/quiz_screen.dart';

class LevelMapScreen extends StatelessWidget {
  final GameCategory category;
  const LevelMapScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: category.color,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(category.title, style: AppText.h1.copyWith(color: Colors.white, fontSize: 20)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [category.color, category.color.withValues(alpha: 0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                alignment: Alignment.center,
                child: Text(category.emoji, style: const TextStyle(fontSize: 64)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<List<GameLevel>>(
              future: app.levelsFor(category, forceRefresh: true),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final levels = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: levels.length,
                    itemBuilder: (context, i) {
                      final level = levels[i];
                      return _LevelTile(level: level, color: category.color, category: category)
                          .animate(delay: (i * 20).ms)
                          .fadeIn()
                          .scale(begin: const Offset(0.85, 0.85));
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  final GameLevel level;
  final Color color;
  final GameCategory category;

  const _LevelTile({required this.level, required this.color, required this.category});

  @override
  Widget build(BuildContext context) {
    final locked = level.status == LevelStatus.locked;
    final completed = level.status == LevelStatus.completed;

    return GestureDetector(
      onTap: locked
          ? null
          : () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(category: category, level: level)));
            },
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: locked ? Colors.grey.withValues(alpha: 0.18) : color.withValues(alpha: completed ? 1 : 0.85),
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: locked ? [] : AppShadows.colored(color),
              ),
              alignment: Alignment.center,
              child: locked ? const Icon(Icons.lock_rounded, color: AppColors.muted) : Text('${level.number}', style: AppText.h2.copyWith(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 4),
          if (!locked)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final filled = i < level.starsEarned;
                return Icon(Icons.star_rounded, size: 14, color: filled ? AppColors.star : Colors.grey.withValues(alpha: 0.3));
              }),
            ),
        ],
      ),
    );
  }
}
