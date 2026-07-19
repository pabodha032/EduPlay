import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'home_screen.dart';
import '../games/games_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _screens = const [HomeScreen(), GamesScreen(), ProfileScreen()];

  final _items = const [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.videogame_asset_rounded, label: 'Games'),
    (icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            gradient: AppColors.navBarGradient,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.colored(AppColors.blueDark),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final selected = i == _index;
              final item = _items[i];
              return GestureDetector(
                onTap: () => setState(() => _index = i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white.withValues(alpha: 0.22) : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.icon, color: Colors.white, size: 24),
                      if (selected) ...[
                        const SizedBox(height: 2),
                        Text(item.label, style: AppText.bodyMuted.copyWith(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
