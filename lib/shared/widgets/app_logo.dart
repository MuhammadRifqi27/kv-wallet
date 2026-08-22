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
        Image.asset('assets/branding/logo_mark.png', height: size, fit: BoxFit.contain),
        if (showWordmark) ...[
          SizedBox(height: size * 0.14),
          Text(
            'Wallet',
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
