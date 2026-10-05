import 'package:flutter/material.dart';

class FeaturePlaceholder extends StatelessWidget {
  const FeaturePlaceholder({super.key, required this.title, required this.note, required this.icon});

  final String title;
  final String note;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: scheme.onSurfaceVariant),
                const SizedBox(height: 12),
                Text(note, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}