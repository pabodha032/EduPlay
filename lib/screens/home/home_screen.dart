import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_state.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import '../games/level_map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final displayName = app.name ?? '...';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.contentGradient),
        child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.skyGradient),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text('Hello, $displayName 👋', style: AppText.h1.copyWith(color: Colors.white))),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: const Text('🐘', style: TextStyle(fontSize: 24)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SoftCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            StatPill(emoji: '🔥', value: '${app.streakDays} day streak', color: AppColors.orange),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 4),
            sliver: SliverToBoxAdapter(child: Text('Choose a Subject', style: AppText.h2)),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.95,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final cat = GameCategory.all[i];
                  return FutureBuilder<Map<int, int>>(
                    future: app.progressFor(cat.id),
                    builder: (context, snapshot) {
                      final completed = snapshot.data?.length ?? 0;
                      return CategoryCard(
                        category: cat,
                        completedLevels: completed,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LevelMapScreen(category: cat))),
                      ).animate(delay: (i * 60).ms).fadeIn().slideY(begin: 0.1, end: 0);
                    },
                  );
                },
                childCount: GameCategory.all.length,
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
