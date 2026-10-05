import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reaple_app/core/widgets/brand_logo.dart';
import 'package:reaple_app/features/auth/presentation/auth_controller.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final offline = auth.status == AuthStatus.offline;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BrandLogo(size: 64),
                  const SizedBox(height: 32),
                  if (!offline)
                    const CircularProgressIndicator()
                  else ...[
                    const Icon(Icons.wifi_off_rounded, size: 40),
                    const SizedBox(height: 12),
                    Text(auth.message ?? 'Tidak dapat terhubung ke server.', textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => ref.read(authControllerProvider.notifier).bootstrap(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Coba lagi'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                      child: const Text('Keluar dari akun'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}