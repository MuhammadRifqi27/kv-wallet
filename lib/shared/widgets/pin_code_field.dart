import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';

/// 6-box PIN entry. A fully transparent [TextField] drives focus & input;
/// the boxes on top just reflect how many digits have been typed so far
/// (filled dot = one digit), giving the usual banking-app PIN look.
class PinCodeField extends StatefulWidget {
  const PinCodeField({
    super.key,
    required this.controller,
    this.autofocus = false,
    this.onCompleted,
    this.errorText,
  });

  final TextEditingController controller;
  final bool autofocus;
  final void Function(String pin)? onCompleted;
  final String? errorText;

  static const length = 6;

  @override
  State<PinCodeField> createState() => _PinCodeFieldState();
}

class _PinCodeFieldState extends State<PinCodeField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() {});
    if (widget.controller.text.length == PinCodeField.length) {
      widget.onCompleted?.call(widget.controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          child: SizedBox(
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    PinCodeField.length,
                    (i) => _PinBox(
                      filled: i < widget.controller.text.length,
                      hasError: widget.errorText != null,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Opacity(
                    opacity: 0,
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      autofocus: widget.autofocus,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(PinCodeField.length),
                      ],
                      showCursor: false,
                      decoration: const InputDecoration(border: InputBorder.none, counterText: ''),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 10),
          Text(widget.errorText!, style: const TextStyle(color: AppColors.error, fontSize: 12.5)),
        ],
      ],
    );
  }
}

class _PinBox extends StatelessWidget {
  const _PinBox({required this.filled, required this.hasError});

  final bool filled;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final color = hasError ? AppColors.error : (filled ? AppColors.primary : AppColors.border);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 44,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: filled ? 2 : 1),
        borderRadius: BorderRadius.circular(12),
        color: AppColors.surface,
      ),
      child: filled
          ? Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(color: AppColors.textPrimary, shape: BoxShape.circle),
            )
          : null,
    );
  }
}
