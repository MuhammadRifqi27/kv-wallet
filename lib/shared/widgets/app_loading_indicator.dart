import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Branded full-page/section loading state — three dots in a row, each
/// growing/fading from [AppColors.primaryLight] to [AppColors.primary] and
/// back in a staggered wave, looping continuously (like a typing
/// indicator). Small inline spinners (button loading state, tiny inline
/// "checking..." indicators) stay a plain [CircularProgressIndicator].
class AppLoadingIndicator extends StatefulWidget {
  const AppLoadingIndicator({super.key, this.dotSize = 10, this.spacing = 6});

  final double dotSize;
  final double spacing;

  @override
  State<AppLoadingIndicator> createState() => _AppLoadingIndicatorState();
}

class _AppLoadingIndicatorState extends State<AppLoadingIndicator> with SingleTickerProviderStateMixin {
  static const _dotCount = 3;
  static const _phaseShift = 1 / _dotCount;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Triangle wave in [0, 1] for dot [index], peaking at the midpoint of
  /// its own phase-shifted slice of the loop so the three dots animate in
  /// a rolling sequence instead of together.
  double _activationFor(int index) {
    final t = (_controller.value + index * _phaseShift) % 1.0;
    return t < 0.5 ? t * 2 : (1 - t) * 2;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _dotCount; i++) ...[
              if (i > 0) SizedBox(width: widget.spacing),
              _Dot(size: widget.dotSize, activation: _activationFor(i)),
            ],
          ],
        );
      },
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.size, required this.activation});

  final double size;

  /// 0 = resting (small, [AppColors.primaryLight]), 1 = peak (full size,
  /// [AppColors.primary]).
  final double activation;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.6 + (0.5 * activation),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Color.lerp(AppColors.primaryLight, AppColors.primary, activation),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
