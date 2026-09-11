import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Brand mark (kodevisual "K") used on Splash/Login/Register, paired with
/// the "Wallet" wordmark.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 88, this.showWordmark = true});

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ColorFiltered(
          // The source asset is a solid black mark — tinting it to
          // textPrimary (not conditionally, always) keeps it looking
          // identical in light mode (textPrimary is near-black there) while
          // automatically turning it near-white in dark mode, with no
          // separate white asset to keep in sync.
          colorFilter: ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn),
          child: Image.asset('assets/branding/logo_mark.png', height: size, fit: BoxFit.contain),
        ),
        if (showWordmark) ...[
          SizedBox(height: size * 0.14),
          Text(
            'Flowr',
            style: TextStyle(
              fontSize: size * 0.27,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ],
    );
  }
}
