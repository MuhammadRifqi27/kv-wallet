import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Round avatar: the network image when [url] is set, else the first
/// letter of [name]. Shared by the friends pages and shared savings goals.
class FriendAvatar extends StatelessWidget {
  const FriendAvatar({super.key, required this.name, this.url, this.radius = 20});

  final String name;
  final String? url;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    final fallback = Text(
      initial,
      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: radius * 0.8),
    );
    final imageUrl = url;
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryLight,
      foregroundImage: imageUrl != null && imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
      onForegroundImageError: imageUrl != null && imageUrl.isNotEmpty ? (_, _) {} : null,
      child: fallback,
    );
  }
}
