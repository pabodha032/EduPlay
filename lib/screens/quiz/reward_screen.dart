import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import 'quiz_screen.dart';

class RewardScreen extends StatefulWidget {
  final GameCategory category;
  final GameLevel level;
  final int stars;
  final int correctCount;
  final int totalQuestions;

  const RewardScreen({
    super.key,
    required this.category,
    required this.level,
    required this.stars,
    required this.correctCount,
    required this.totalQuestions,
  });

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2))..play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(decoration: const BoxDecoration(gradient: AppColors.skyGradient)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 96)).animate().scale(duration: 600.ms, curve: Curves.elasticOut).then().shake(duration: 500.ms),
                  const SizedBox(height: 12),
                  Text('Level ${widget.level.number} Complete!', style: AppText.h1.copyWith(color: Colors.white)),
                  const SizedBox(height: 6),
                  Text('${widget.correctCount}/${widget.totalQuestions} correct', style: AppText.body.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final filled = i < widget.stars;
                      return Icon(Icons.star_rounded, size: 56, color: filled ? AppColors.star : Colors.white.withValues(alpha: 0.35))
                          .animate(delay: (300 + i * 150).ms)
                          .scale(curve: Curves.elasticOut);
                    }),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: BouncyButton(
                          label: 'Replay',
                          icon: Icons.replay_rounded,
                          width: double.infinity,
                          gradient: const LinearGradient(colors: [Colors.white70, Colors.white38]),
                          onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => QuizScreen(category: widget.category, level: widget.level))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: BouncyButton(
                          label: 'Continue',
                          icon: Icons.arrow_forward_rounded,
                          width: double.infinity,
                          gradient: AppColors.successGradient,
                          onTap: () => Navigator.popUntil(context, (r) => r.isFirst),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 650.ms),
                ],
              ),
            ),
          ),
          ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 30,
            gravity: 0.25,
            colors: const [AppColors.blue, AppColors.green, AppColors.yellow, AppColors.orange, Colors.white],
          ),
        ],
      ),
    );
  }
}
