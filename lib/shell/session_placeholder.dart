import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reaple_app/core/config/api_config.dart';
import 'package:reaple_app/core/responsive/responsive.dart';
import 'package:reaple_app/features/auth/presentation/auth_controller.dart';

/// Halaman sementara untuk memastikan login dan RBAC berjalan.
/// Seluruh data berasal dari API (/auth/login atau /auth/me).
class SessionPlaceholder extends ConsumerWidget {
  const SessionPlaceholder({super.key, required this.title, required this.note});

  final String title;
  final String note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(ApiConfig.appName),
        actions: [
          TextButton.icon(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Keluar'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ResponsiveCenter(
        maxWidth: 640,
        padding: EdgeInsets.all(context.pagePadding),
        child: ListView(
          children: [
            Text('Halo, ${user?.name ?? ''}', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row('Peran', user?.roleLabel ?? '-'),
                    _row('Email', user?.email ?? '-'),
                    _row('Nomor HP', user?.phone ?? '-'),
                    if (user?.isTechnician ?? false) _row('Rating', '${user?.avgRating?.toStringAsFixed(1) ?? '0.0'} (${user?.ratingCount ?? 0} ulasan)'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(note, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 90, child: Text(label)),
            Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
      );
}