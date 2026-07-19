import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_state.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import 'level_map_screen.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: Text('Games', style: AppText.h1)),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.contentGradient),
        child: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.95,
        ),
        itemCount: GameCategory.all.length,
        itemBuilder: (context, i) {
          final cat = GameCategory.all[i];
          return FutureBuilder<Map<int, int>>(
            future: app.progressFor(cat.id),
            builder: (context, snapshot) {
              final completed = snapshot.data?.length ?? 0;
              return CategoryCard(
                category: cat,
                completedLevels: completed,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LevelMapScreen(category: cat))),
              ).animate(delay: (i * 50).ms).fadeIn().scale(begin: const Offset(0.9, 0.9));
            },
          );
        },
        ),
      ),
    );
  }
}
