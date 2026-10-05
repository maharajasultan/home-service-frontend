import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.loading = false, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        // Tetap "aktif" saat loading agar spinner terlihat jelas; tap diabaikan.
        onPressed: onPressed == null
            ? null
            : () {
                if (!loading) onPressed!();
              },
        child: loading
            ? SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: onPrimary))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
                  Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
                ],
              ),
      ),
    );
  }
}