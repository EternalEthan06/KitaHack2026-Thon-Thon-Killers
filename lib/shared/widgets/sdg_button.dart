import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SdgButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final _ButtonStyle _style;
  final String? icon;

  const SdgButton._({required this.label, required this.onPressed, required _ButtonStyle style, this.icon})
      : _style = style;

  factory SdgButton.primary({required String label, VoidCallback? onPressed}) =>
      SdgButton._(label: label, onPressed: onPressed, style: _ButtonStyle.primary);

  factory SdgButton.outlined({required String label, VoidCallback? onPressed, String? icon}) =>
      SdgButton._(label: label, onPressed: onPressed, style: _ButtonStyle.outlined, icon: icon);

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Text(icon!, style: const TextStyle(fontSize: 18)), const SizedBox(width: 8)],
        Text(label),
      ],
    );

    if (_style == _ButtonStyle.primary) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(onPressed: onPressed, child: child),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.onBackground,
          side: const BorderSide(color: AppTheme.surfaceVariant, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: child,
      ),
    );
  }
}

enum _ButtonStyle { primary, outlined }
