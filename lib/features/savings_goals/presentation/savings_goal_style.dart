import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/savings_goal_model.dart';

/// Maps the free-form `color` string from the API (`primary`/`success`/
/// `info`/`warning`/`danger`) to an actual [Color] — the app decides this
/// mapping, per docs/mobile-api-reference.md's note that `color` is "app
/// yang menentukan pemetaan ke aset ikon di sisi mobile". `info` has no
/// existing token in [AppColors], so a plain blue is used just for this.
const _infoColor = Color(0xFF2563EB);

const savingsGoalColorOptions = ['primary', 'success', 'info', 'warning', 'danger'];

Color savingsGoalColorFor(String? key) => switch (key) {
      'success' => AppColors.success,
      'info' => _infoColor,
      'warning' => AppColors.accent,
      'danger' => AppColors.error,
      _ => AppColors.primary,
    };

String savingsGoalColorLabel(String key) => switch (key) {
      'success' => 'Hijau',
      'info' => 'Biru',
      'warning' => 'Kuning',
      'danger' => 'Merah',
      _ => 'Rose',
    };

/// Small curated icon set — `icon` is a free-form string on the backend, so
/// only these known keys render a matching glyph; anything else (or null)
/// falls back to a generic savings icon.
const savingsGoalIconOptions = [
  'savings',
  'shield-tick',
  'home',
  'car',
  'flight',
  'school',
  'wedding',
  'gift',
];

IconData savingsGoalIconFor(String? key) => switch (key) {
      'shield-tick' => Icons.shield_outlined,
      'home' => Icons.home_outlined,
      'car' => Icons.directions_car_outlined,
      'flight' => Icons.flight_takeoff_outlined,
      'school' => Icons.school_outlined,
      'wedding' => Icons.favorite_outline,
      'gift' => Icons.card_giftcard_outlined,
      _ => Icons.savings_outlined,
    };

String savingsGoalStatusLabel(SavingsGoalStatus status) => switch (status) {
      SavingsGoalStatus.achieved => 'Tercapai',
      SavingsGoalStatus.archived => 'Diarsipkan',
      SavingsGoalStatus.active => 'Aktif',
    };
