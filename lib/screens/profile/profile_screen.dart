import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/common_widgets.dart';
import '../splash_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.contentGradient),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.skyGradient),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.soft,
                      ),
                      alignment: Alignment.center,
                      child: const Text('🐘', style: TextStyle(fontSize: 56)),
                    ).animate().scale(curve: Curves.elasticOut),
                    const SizedBox(height: 12),
                    Text(app.name ?? '...',
                        style: AppText.h1.copyWith(color: Colors.white)),
                    Text(app.email ?? '',
                        style: AppText.body.copyWith(
                            color: Colors.white.withValues(alpha: 0.9))),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    SoftCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          StatPill(
                              emoji: '🔥',
                              value: '${app.streakDays} day streak',
                              color: AppColors.orange)
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SoftCard(
                      child: Column(
                        children: [
                          _InfoRow(label: 'Name', value: app.name ?? '-'),
                          _InfoRow(
                              label: 'Email',
                              value: app.email ?? '-',
                              isLast: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    BouncyButton(
                      label: 'Log Out',
                      icon: Icons.logout_rounded,
                      width: double.infinity,
                      gradient: const LinearGradient(
                          colors: [AppColors.error, Color(0xFFCC4A4A)]),
                      onTap: () async {
                        await context.read<AppState>().logout();
                        if (!context.mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const SplashScreen()),
                            (r) => false);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _InfoRow(
      {required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppText.bodyMuted),
              Flexible(
                  child: Text(value,
                      style: AppText.body.copyWith(fontWeight: FontWeight.w700),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
        if (!isLast) Divider(color: AppColors.textDark.withValues(alpha: 0.08)),
      ],
    );
  }
}
