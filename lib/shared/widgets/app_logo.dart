import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Programmatic brand mark used on Splash/Login/Register until a real
/// logo asset is supplied.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 88, this.showWordmark = true});

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Icon(
            Icons.account_balance_wallet_rounded,
            color: Colors.white,
            size: size * 0.5,
          ),
        ),
        if (showWordmark) ...[
          SizedBox(height: size * 0.22),
          Text(
            'KVWallet',
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
