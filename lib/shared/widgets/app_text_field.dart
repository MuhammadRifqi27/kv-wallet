import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.errorText,
    this.onFieldSubmitted,
    this.helperText,
  });

  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final String? errorText;
  final void Function(String)? onFieldSubmitted;

  /// Shown below the field when there's no [errorText] (errors take
  /// visual priority) — e.g. "auto-filled from receipt scan" hints. See
  /// docs/ide-improvement-fitur-existing.txt BAGIAN K #54.
  final String? helperText;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: widget.errorText,
        helperText: widget.helperText,
        helperStyle: TextStyle(color: AppColors.primary, fontSize: 11.5, fontWeight: FontWeight.w600),
        helperMaxLines: 2,
        prefixIcon: widget.icon != null ? Icon(widget.icon, color: AppColors.textSecondary, size: 20) : null,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
      ),
    );
  }
}
