import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Icon + title/subtitle + chevron row — the standard tappable menu tile
/// used across Profile, Edit Profile, and anywhere else a simple "go to
/// this sub-page" menu item is needed.
class SettingsTile extends StatelessWidget {
  const SettingsTile({super.key, required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      // ListTile paints its ink splashes on the nearest Material ancestor —
      // without this, the opaque BoxDecoration above hides them and Flutter
      // throws "ListTile background color or ink splashes may be invisible"
      // in debug builds. See docs/ide-improvement-fitur-existing.txt BAGIAN
      // A #1. `transparency` so the Container's own background still shows.
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          subtitle: Text(subtitle, style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
          trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
