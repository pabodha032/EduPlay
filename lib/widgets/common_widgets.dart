import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class BouncyButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final Gradient gradient;
  final IconData? icon;
  final double height;
  final double? width;
  final bool loading;

  const BouncyButton({
    super.key,
    required this.label,
    required this.onTap,
    this.gradient = AppColors.primaryButtonGradient,
    this.icon,
    this.height = 58,
    this.width,
    this.loading = false,
  });

  @override
  State<BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<BouncyButton> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null || widget.loading;
    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _scale = 0.95),
      onTapUp: disabled ? null : (_) => setState(() => _scale = 1),
      onTapCancel: disabled ? null : () => setState(() => _scale = 1),
      onTap: disabled ? null : widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Opacity(
          opacity: disabled && widget.loading == false ? 0.6 : 1,
          child: Container(
            height: widget.height,
            width: widget.width,
            padding: const EdgeInsets.symmetric(horizontal: 28),
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              boxShadow: AppShadows.colored(
                  (widget.gradient as LinearGradient).colors.first),
            ),
            child: Row(
              mainAxisSize:
                  widget.width == null ? MainAxisSize.min : MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.loading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.4, color: Colors.white),
                  )
                else ...[
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                  ],
                  Text(widget.label, style: AppText.button),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StatPill extends StatelessWidget {
  final String emoji;
  final String value;
  final Color color;

  const StatPill(
      {super.key,
      required this.emoji,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(value,
              style: AppText.body.copyWith(
                  fontSize: 14, color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final GameCategory category;
  final int completedLevels;
  final VoidCallback onTap;

  const CategoryCard(
      {super.key,
      required this.category,
      required this.onTap,
      this.completedLevels = 0});

  @override
  Widget build(BuildContext context) {
    final progress = category.totalLevels == 0
        ? 0.0
        : completedLevels / category.totalLevels;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              category.color.withValues(alpha: 0.80),
              category.color.withValues(alpha: 0.40)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.soft,
        ),
        padding: const EdgeInsets.all(14),
        child: Stack(
          children: [
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Opacity(
                    opacity: 0.9,
                    child: Text(category.emoji,
                        style: const TextStyle(fontSize: 56)),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: category.color,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppShadows.colored(category.color)),
                  child: Text(category.emoji,
                      style: const TextStyle(fontSize: 18)),
                ),
                const Spacer(),
                Text(category.title,
                    style: AppText.h2.copyWith(fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.6),
                    valueColor: AlwaysStoppedAnimation(category.color),
                  ),
                ),
                const SizedBox(height: 4),
                Text('$completedLevels/${category.totalLevels} levels',
                    style: AppText.bodyMuted.copyWith(fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FloatingClouds extends StatefulWidget {
  final int count;
  final String imagePath;
  final double opacity;
  final double minSize;
  final double maxSize;

  const FloatingClouds({
    super.key,
    this.count = 4,
    this.imagePath = 'assets/cloud1.png',
    this.opacity = 0.55,
    this.minSize = 80,
    this.maxSize = 100,
  });

  @override
  State<FloatingClouds> createState() => _FloatingCloudsState();
}

class _FloatingCloudsState extends State<FloatingClouds>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            children: List.generate(widget.count, (i) {
              final t = (_controller.value + i / widget.count) % 1.0;
              final top = 30.0 + i * 70.0;
              final width = MediaQuery.of(context).size.width;
              final left = -120 + t * (width + 240);
              final size =
                  widget.minSize + (i % 2) * (widget.maxSize - widget.minSize);

              return Positioned(
                top: top,
                left: left,
                child: Opacity(
                  opacity: widget.opacity,
                  child: Image.asset(
                    widget.imagePath,
                    width: size,
                    height: size,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.cloud,
                        size: size,
                        color: Colors.white,
                      );
                    },
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
// --------------------------------------

class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? labelColor;

  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
          //: color ?? Theme.of(context).cardColor,
          color: color ?? const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.soft),
      child: child,
    );
  }
}
