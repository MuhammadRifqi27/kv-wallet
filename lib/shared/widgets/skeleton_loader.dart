import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Reusable skeleton-loading primitives — see
/// docs/plan-dev/skeleton-loading-plan.txt for the full design rationale
/// (why hand-rolled pulse instead of a shimmer package, why one shared
/// [SkeletonShimmer] per layout block instead of one per box, the
/// per-page rollout plan, etc.). Three pieces:
/// - [SkeletonShimmer]: the animated ancestor every skeleton block needs.
/// - [SkeletonBox]: the shape primitive, reads the animation from its
///   nearest [SkeletonShimmer] ancestor.
/// - [SkeletonListTile] / [skeletonListTiles]: a ready-made composite for
///   the icon+2-lines+trailing list-row shape repeated across most of the
///   app's list pages.

/// Drives a single pulsing color animation shared by every descendant
/// [SkeletonBox] — one [AnimationController] per layout block instead of
/// one per box. Exposes the current animation via [InheritedNotifier] so
/// [SkeletonBox] just reads it, no manual value-passing needed.
class SkeletonShimmer extends StatefulWidget {
  const SkeletonShimmer({super.key, required this.child});

  final Widget child;

  static Animation<double> of(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<_SkeletonShimmerScope>();
    assert(
      inherited != null,
      'SkeletonBox must be built under a SkeletonShimmer ancestor — wrap '
      'the skeleton layout in SkeletonShimmer(child: ...).',
    );
    return inherited!.animation;
  }

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect the system "reduce motion" accessibility setting — render a
    // static box instead of running the pulse. See
    // docs/plan-dev/skeleton-loading-plan.txt BAGIAN 2.1 / BAGIAN 5 #3.
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      _controller?.dispose();
      _controller = null;
    } else {
      _controller ??= AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return _SkeletonShimmerScope(
      animation: controller ?? const AlwaysStoppedAnimation(0),
      child: widget.child,
    );
  }
}

class _SkeletonShimmerScope extends InheritedNotifier<Animation<double>> {
  const _SkeletonShimmerScope({
    required Animation<double> animation,
    required super.child,
  }) : super(notifier: animation);

  Animation<double> get animation => notifier!;
}

/// Shape primitive — a solid box that pulses between [AppColors.
/// skeletonBase] and [AppColors.skeletonHighlight]. Must be built under a
/// [SkeletonShimmer] ancestor.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 6,
    this.shape = BoxShape.rectangle,
  });

  final double? width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    final animation = SkeletonShimmer.of(context);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final color = Color.lerp(
          AppColors.skeletonBase,
          AppColors.skeletonHighlight,
          animation.value,
        )!;
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            shape: shape,
            borderRadius: shape == BoxShape.rectangle
                ? BorderRadius.circular(borderRadius)
                : null,
          ),
        );
      },
    );
  }
}

/// Placeholder for the icon-bubble + 2-lines (+ optional trailing box)
/// shape repeated across most list pages (Transactions, Recurring,
/// Transfers, Portfolio, BTC Activity, Category/Investment-provider
/// lists, Notification History). Wrapped in the same card shell
/// (surface/border/radius 14) as the real list tiles so there's no
/// layout jump once data replaces it.
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key, this.hasTrailing = true});

  final bool hasTrailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const SkeletonBox(width: 40, height: 40, shape: BoxShape.circle),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: 140, height: 14),
                const SizedBox(height: 8),
                SkeletonBox(
                  width: MediaQuery.sizeOf(context).width * 0.35,
                  height: 11,
                ),
              ],
            ),
          ),
          if (hasTrailing) ...[
            const SizedBox(width: 12),
            const SkeletonBox(width: 56, height: 16),
          ],
        ],
      ),
    );
  }
}

/// Ready-made `loading:` value for list pages using the standard
/// [SkeletonListTile] shape — one shared [SkeletonShimmer] for all
/// [count] rows. `count` defaults to roughly a screenful.
Widget skeletonListTiles({int count = 6, bool hasTrailing = true}) {
  return SkeletonShimmer(
    child: ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: count,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) =>
          SkeletonListTile(hasTrailing: hasTrailing),
    ),
  );
}
