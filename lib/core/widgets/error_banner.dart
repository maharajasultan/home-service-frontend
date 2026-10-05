import 'package:flutter/material.dart';

class ErrorBanner extends StatelessWidget {
  const ErrorBanner(this.message, {super.key, this.isInfo = false});

  final String message;

  /// true = pesan informasi (misalnya "Sesi berakhir"), false = error.
  final bool isInfo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = isInfo ? scheme.secondaryContainer : scheme.errorContainer;
    final fg = isInfo ? scheme.onSecondaryContainer : scheme.onErrorContainer;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(isInfo ? Icons.info_outline : Icons.error_outline, color: fg, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: TextStyle(color: fg))),
        ],
      ),
    );
  }
}