import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_spacing.dart';

/// A labeled, validated text input used across the auth forms.
///
/// Wraps [TextFormField] with a consistent label, optional leading [icon],
/// password obscuring with a show/hide toggle, and inherits the app's global
/// `inputDecorationTheme`. Keeping this in one widget guarantees every field in
/// the app looks and behaves identically.
class AppTextField extends StatefulWidget {
  /// Creates an [AppTextField].
  const AppTextField({
    required this.label,
    this.controller,
    this.hintText,
    this.icon,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.enabled = true,
    super.key,
  });

  /// Field label shown above the input.
  final String label;

  /// Optional externally-owned controller.
  final TextEditingController? controller;

  /// Placeholder text shown when empty.
  final String? hintText;

  /// Optional leading icon.
  final IconData? icon;

  /// Whether to obscure text (passwords). Adds a visibility toggle.
  final bool obscure;

  /// Keyboard layout hint.
  final TextInputType? keyboardType;

  /// Keyboard action button behavior.
  final TextInputAction? textInputAction;

  /// Auto-capitalization behavior (e.g. words for names).
  final TextCapitalization textCapitalization;

  /// Synchronous validator (see [FormField.validator]).
  final String? Function(String?)? validator;

  /// Change callback.
  final ValueChanged<String>? onChanged;

  /// Submit (keyboard action) callback.
  final ValueChanged<String>? onSubmitted;

  /// Optional input formatters (e.g. digits-only for age).
  final List<TextInputFormatter>? inputFormatters;

  /// Whether the field accepts input.
  final bool enabled;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.sm,
            bottom: AppSpacing.xs,
          ),
          child: Text(widget.label, style: text.titleMedium),
        ),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscured,
          enabled: widget.enabled,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          inputFormatters: widget.inputFormatters,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: widget.icon == null ? null : Icon(widget.icon),
            suffixIcon: widget.obscure
                ? IconButton(
                    icon: Icon(
                      _obscured ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscured = !_obscured),
                    tooltip: _obscured ? 'Show password' : 'Hide password',
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
