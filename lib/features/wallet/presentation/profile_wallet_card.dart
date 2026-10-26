import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../application/wallet_controller.dart';

/// Wallet balance card shown on the Profile page, right under the account
/// header card and above the Portfolio section. Tapping it opens
/// [WalletPage]. A failed load never blocks the rest of Profile — it just
/// shows an inline retry.
class ProfileWalletCard extends ConsumerWidget {
  const ProfileWalletCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final walletAsync = ref.watch(walletControllerProvider);
    final onPrimary = AppColors.onPrimary;

    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/wallet'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: onPrimary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.account_balance_wallet_rounded, color: onPrimary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: walletAsync.when(
                  loading: () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.wltCardTitle, style: TextStyle(color: onPrimary.withValues(alpha: 0.8), fontSize: 12)),
                      const SizedBox(height: 6),
                      Container(
                        width: 120,
                        height: 18,
                        decoration: BoxDecoration(
                          color: onPrimary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  error: (_, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.wltCardTitle, style: TextStyle(color: onPrimary.withValues(alpha: 0.8), fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(l10n.wltCardLoadError, style: TextStyle(color: onPrimary, fontSize: 13)),
                    ],
                  ),
                  data: (wallet) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.wltCardTitle, style: TextStyle(color: onPrimary.withValues(alpha: 0.8), fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(
                        wallet.isFrozen ? l10n.wltCardFrozen : formatRupiah(wallet.balance),
                        style: TextStyle(color: onPrimary, fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        wallet.formattedAccountNumber,
                        style: TextStyle(color: onPrimary.withValues(alpha: 0.8), fontSize: 12, letterSpacing: 0.8),
                      ),
                    ],
                  ),
                ),
              ),
              if (walletAsync.hasError)
                IconButton(
                  tooltip: l10n.wltCardRetry,
                  icon: Icon(Icons.refresh_rounded, color: onPrimary),
                  onPressed: () => ref.invalidate(walletControllerProvider),
                )
              else
                Icon(Icons.chevron_right_rounded, color: onPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
