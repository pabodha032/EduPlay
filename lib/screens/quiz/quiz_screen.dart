import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/app_state.dart';
import '../../services/supabase_service.dart';
import '../../widgets/common_widgets.dart';
import 'reward_screen.dart';

class QuizScreen extends StatefulWidget {
  final GameCategory category;
  final GameLevel level;

  const QuizScreen({super.key, required this.category, required this.level});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuizQuestion> _questions = [];
  bool _loading = true;
  String? _loadError;

  int _questionIndex = 0;
  int? _selected;
  bool _answered = false;
  bool _hintUsed = false;
  int _correctCount = 0;
  int _lives = 5;
  int _timeLeft = 30;
  Timer? _timer;
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 1));
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final bank =
          await SupabaseService.instance.fetchQuestions(widget.category.id);
      if (bank.isEmpty) {
        setState(() {
          _loading = false;
          _loadError =
              'No questions found yet for ${widget.category.title}. Add some rows to the "questions" table.';
        });
        return;
      }

      final levelMatches = bank
          .where((q) => q.levelNumber == widget.level.number)
          .toList()
        ..shuffle(Random(widget.level.number));

      final usedIds = levelMatches.map((q) => q.id).toSet();
      final tierFillers = bank
          .where((q) =>
              q.difficulty == widget.level.difficulty &&
              !usedIds.contains(q.id))
          .toList()
        ..shuffle(Random(widget.level.number + 1000));

      var combined = [...levelMatches, ...tierFillers];

      if (combined.length < 5) {
        final usedIds2 = combined.map((q) => q.id).toSet();
        final rest = bank.where((q) => !usedIds2.contains(q.id)).toList()
          ..shuffle(Random(widget.level.number + 2000));
        combined = [...combined, ...rest];
      }

      setState(() {
        _questions = combined.length > 5 ? combined.sublist(0, 5) : combined;
        _loading = false;
      });
      _startTimer();
    } catch (e) {
      setState(() {
        _loading = false;
        _loadError =
            'Could not load questions. Check your connection and try again.';
      });
    }
  }

  void _startTimer() {
    _timeLeft = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) {
        t.cancel();
        if (!_answered) _selectAnswer(-1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confetti.dispose();
    super.dispose();
  }

  QuizQuestion get _question => _questions[_questionIndex];

  void _selectAnswer(int index) {
    if (_answered) return;
    _timer?.cancel();
    final correct = index == _question.correctIndex;
    setState(() {
      _selected = index;
      _answered = true;
      if (correct) {
        _correctCount++;
      } else if (_lives > 0) {
        _lives--;
      }
    });
    if (correct) _confetti.play();
  }

  Future<void> _next() async {
    if (_questionIndex + 1 < _questions.length) {
      setState(() {
        _questionIndex++;
        _selected = null;
        _answered = false;
        _hintUsed = false;
      });
      _startTimer();
    } else {
      final stars = _correctCount >= 5
          ? 3
          : (_correctCount >= 3 ? 2 : (_correctCount >= 1 ? 1 : 0));
      try {
        await context.read<AppState>().saveLevelResult(
            category: widget.category.id,
            levelNumber: widget.level.number,
            stars: stars);
      } catch (e) {
        debugPrint('❌ SAVE PROGRESS ERROR: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Could not save your progress. Check your connection.'),
                backgroundColor: AppColors.error),
          );
        }
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RewardScreen(
              category: widget.category,
              level: widget.level,
              stars: stars,
              correctCount: _correctCount,
              totalQuestions: _questions.length),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(
            leading: BackButton(onPressed: () => Navigator.pop(context))),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
              child: Text(_loadError!,
                  textAlign: TextAlign.center, style: AppText.body)),
        ),
      );
    }

    final q = _question;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded)),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          child: LinearProgressIndicator(
                            value: (_questionIndex + (_answered ? 1 : 0)) /
                                _questions.length,
                            minHeight: 10,
                            backgroundColor: Colors.grey.withValues(alpha: 0.2),
                            valueColor:
                                AlwaysStoppedAnimation(widget.category.color),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Row(
                        children: List.generate(
                            5,
                            (i) => Icon(Icons.favorite_rounded,
                                size: 18,
                                color: i < _lives
                                    ? AppColors.heart
                                    : Colors.grey.withValues(alpha: 0.25))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          'Question ${_questionIndex + 1}/${_questions.length}',
                          style: AppText.bodyMuted),
                      Row(
                        children: [
                          Icon(Icons.timer_rounded,
                              size: 16,
                              color: _timeLeft <= 10
                                  ? AppColors.error
                                  : AppColors.muted),
                          const SizedBox(width: 4),
                          Text('$_timeLeft s',
                              style: AppText.bodyMuted.copyWith(
                                  color: _timeLeft <= 10
                                      ? AppColors.error
                                      : AppColors.muted)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SoftCard(
                              child: Text(q.prompt,
                                  textAlign: TextAlign.center,
                                  style: AppText.h2)),
                          const SizedBox(height: 24),
                          ...List.generate(
                              q.options.length,
                              (i) => _AnswerButton(
                                    text: q.options[i],
                                    index: i,
                                    selected: _selected,
                                    correctIndex: q.correctIndex,
                                    answered: _answered,
                                    onTap: () => _selectAnswer(i),
                                  )),
                          if (_answered)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: SoftCard(
                                color: (_selected == q.correctIndex
                                        ? AppColors.success
                                        : AppColors.error)
                                    .withValues(alpha: 0.12),
                                child: Row(
                                  children: [
                                    Icon(
                                        _selected == q.correctIndex
                                            ? Icons.celebration_rounded
                                            : Icons.info_rounded,
                                        color: _selected == q.correctIndex
                                            ? AppColors.success
                                            : AppColors.error),
                                    const SizedBox(width: 10),
                                    Expanded(
                                        child: Text(
                                            _selected == q.correctIndex
                                                ? 'Great job! 🎉'
                                                : q.explanation,
                                            style: AppText.body
                                                .copyWith(fontSize: 14))),
                                  ],
                                ),
                              ),
                            ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (!_answered) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _hintUsed
                                ? null
                                : () => setState(() => _hintUsed = true),
                            icon: const Icon(Icons.lightbulb_rounded),
                            label: const Text('Hint'),
                            style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.pill))),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _selectAnswer(-1),
                            icon: const Icon(Icons.skip_next_rounded),
                            label: const Text('Skip'),
                            style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.pill))),
                          ),
                        ),
                      ] else
                        Expanded(
                          child: BouncyButton(
                            label: _questionIndex + 1 == _questions.length
                                ? 'Finish'
                                : 'Next',
                            width: double.infinity,
                            gradient: AppColors.successGradient,
                            onTap: _next,
                          ),
                        ),
                    ],
                  ),
                  if (_hintUsed && !_answered)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        '💡 It is not "${q.options[(q.correctIndex + 1) % q.options.length]}"',
                        style: AppText.bodyMuted.copyWith(
                            color: const Color.fromARGB(255, 217, 80, 38)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 24,
              gravity: 0.3,
              colors: const [
                AppColors.blue,
                AppColors.green,
                AppColors.yellow,
                AppColors.orange
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String text;
  final int index;
  final int? selected;
  final int correctIndex;
  final bool answered;
  final VoidCallback onTap;

  const _AnswerButton(
      {required this.text,
      required this.index,
      required this.selected,
      required this.correctIndex,
      required this.answered,
      required this.onTap});

  static const _palette = [
    AppColors.blue,
    AppColors.green,
    AppColors.orange,
    Color(0xFF9B7BFF)
  ];

  @override
  Widget build(BuildContext context) {
    Color bg = _palette[index % _palette.length];

    if (answered) {
      if (index == correctIndex) {
        bg = AppColors.success;
      } else if (index == selected) {
        bg = AppColors.error;
      } else {
        bg = Colors.grey.withValues(alpha: 0.25);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: answered ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: answered ? [] : AppShadows.colored(bg)),
          child: Row(
            children: [
              Expanded(
                child: Text(text,
                    style: AppText.body.copyWith(
                        color: answered &&
                                index != correctIndex &&
                                index != selected
                            ? AppColors.textDark
                            : Colors.white,
                        fontWeight: FontWeight.w700)),
              ),
              if (answered && index == correctIndex)
                const Icon(Icons.check_circle_rounded, color: Colors.white),
              if (answered && index == selected && index != correctIndex)
                const Icon(Icons.cancel_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
