import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'auth/auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce;

  @override
  void initState() {
    super.initState();
    _bounce =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
              decoration: const BoxDecoration(gradient: AppColors.skyGradient)),
          const FloatingClouds(count: 5),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  AnimatedBuilder(
                    animation: _bounce,
                    builder: (context, child) {
                      final dy = -12 * _bounce.value;
                      return Transform.translate(
                          offset: Offset(0, dy), child: child);
                    },
                    child: Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.soft,
                        image: const DecorationImage(
                          image: AssetImage('assets/one.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      alignment: Alignment.center,
                    ),
                  ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 28),
                  Text(
                    'EduPlay',
                    style: AppText.display.copyWith(
                      fontSize: 44,
                      color: Colors.white,
                      shadows: [
                        const Shadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 3))
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 10),
                  Text(
                    'Learn While You Play',
                    style: AppText.body
                        .copyWith(color: Colors.white.withValues(alpha: 0.95)),
                  ).animate().fadeIn(delay: 400.ms),
                  const Spacer(flex: 3),
                  BouncyButton(
                    label: 'Start',
                    icon: Icons.play_arrow_rounded,
                    width: double.infinity,
                    gradient: AppColors.sunsetGradient,
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const AuthScreen(),
                          transitionsBuilder: (_, anim, __, child) =>
                              FadeTransition(opacity: anim, child: child),
                          transitionDuration: const Duration(milliseconds: 500),
                        ),
                      );
                    },
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.4, end: 0),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
