import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flowr/l10n/app_localizations.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/primary_button.dart';

class _OnboardingSlide {
  const _OnboardingSlide({required this.icon, required this.title, required this.description});

  final IconData icon;
  final String title;
  final String description;
}

List<_OnboardingSlide> _buildSlides(AppLocalizations l10n) => [
      _OnboardingSlide(
        icon: Icons.account_balance_wallet_rounded,
        title: l10n.authOnboardingSlide1Title,
        description: l10n.authOnboardingSlide1Description,
      ),
      _OnboardingSlide(
        icon: Icons.receipt_long_rounded,
        title: l10n.authOnboardingSlide2Title,
        description: l10n.authOnboardingSlide2Description,
      ),
      _OnboardingSlide(
        icon: Icons.calculate_rounded,
        title: l10n.authOnboardingSlide3Title,
        description: l10n.authOnboardingSlide3Description,
      ),
      _OnboardingSlide(
        icon: Icons.lock_rounded,
        title: l10n.authOnboardingSlide4Title,
        description: l10n.authOnboardingSlide4Description,
      ),
    ];

/// Shown once per device, before Login/Register — see
/// core/storage/onboarding_service.dart for why this is per-device rather
/// than tied to the account.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  List<_OnboardingSlide> get _slides => _buildSlides(AppLocalizations.of(context));

  bool get _isLastSlide => _currentPage == _slides.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingServiceProvider).markSeen();
    ref.read(hasSeenOnboardingProvider.notifier).state = true;
    if (mounted) context.go('/splash');
  }

  void _next() {
    if (_isLastSlide) {
      _finish();
      return;
    }
    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final slides = _slides;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8, top: 4),
                child: Visibility(
                  visible: !_isLastSlide,
                  maintainState: true,
                  maintainAnimation: true,
                  maintainSize: true,
                  child: TextButton(onPressed: _finish, child: Text(l10n.authOnboardingSkipButton)),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) => _SlideView(slide: slides[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < slides.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _currentPage ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _currentPage ? AppColors.primary : AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: _isLastSlide ? l10n.authOnboardingStartButton : l10n.authOnboardingNextButton,
                  onPressed: _next,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(slide.icon, color: AppColors.primaryDark, size: 64),
          ),
          const SizedBox(height: 40),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}
