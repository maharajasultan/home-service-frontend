import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reaple_app/core/responsive/responsive.dart';
import 'package:reaple_app/core/router/app_router.dart';
import 'package:reaple_app/core/utils/format.dart';
import 'package:reaple_app/core/widgets/error_banner.dart';
import 'package:reaple_app/features/checkout/data/checkout_draft.dart';

/// Sementara. Di F3 layar ini diganti form alamat, kontak WhatsApp, jadwal, dan pembuatan pesanan.
class CheckoutPlaceholderScreen extends ConsumerWidget {
  const CheckoutPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(checkoutDraftProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.user);
            }
          },
        ),
        title: const Text('Pemesanan'),
      ),
      body: ResponsiveCenter(
        maxWidth: 640,
        padding: EdgeInsets.all(context.pagePadding),
        child: draft == null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Belum ada item yang dipilih.'),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: () => context.go(AppRoutes.user), child: const Text('Ke beranda')),
                  ],
                ),
              )
            : ListView(
                children: [
                  Text('Ringkasan pesanan', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          for (final line in draft.lines)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(line.productName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                        if (line.variantLabel.isNotEmpty) Text(line.variantLabel, style: theme.textTheme.bodySmall),
                                        Text('Jumlah: ${line.qty}', style: theme.textTheme.bodySmall),
                                      ],
                                    ),
                                  ),
                                  Text(Fmt.rupiah(line.lineTotal), style: const TextStyle(fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          const Divider(),
                          Row(
                            children: [
                              const Text('Total', style: TextStyle(fontWeight: FontWeight.w700)),
                              const Spacer(),
                              Text(Fmt.rupiah(draft.total), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const ErrorBanner(
                    'Form alamat (khusus Bekasi), nomor WhatsApp, dan jadwal teknisi dibuat di F3.',
                    isInfo: true,
                  ),
                ],
              ),
      ),
    );
  }
}