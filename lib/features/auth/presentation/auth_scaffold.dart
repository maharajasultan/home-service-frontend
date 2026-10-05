import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reaple_app/core/responsive/responsive.dart';
import 'package:reaple_app/core/widgets/brand_logo.dart';

/// HP: satu kolom dengan logo di atas.
/// Layar lebar (>= 900 dp): panel brand di kiri, form di kanan.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;

          final form = SafeArea(
            child: Center(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.symmetric(horizontal: context.isCompact ? 20 : 32, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (context.canPop())
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            tooltip: 'Kembali',
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                        ),
                      if (!wide) ...const [Center(child: BrandLogo(size: 52)), SizedBox(height: 28)],
                      Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 28),
                      child,
                      if (footer != null) ...[const SizedBox(height: 20), footer!],
                    ],
                  ),
                ),
              ),
            ),
          );

          if (!wide) return form;

          return Row(
            children: [
              const Expanded(flex: 11, child: _BrandPanel()),
              Expanded(flex: 9, child: form),
            ],
          );
        },
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const points = [
      (Icons.home_repair_service_rounded, 'Teknisi datang langsung ke rumah Anda di area Bekasi'),
      (Icons.verified_rounded, 'Sparepart Standar, Premium, dan Original'),
      (Icons.shield_rounded, 'Garansi service 3 bulan'),
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
        ),
      ),
      padding: const EdgeInsets.all(48),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BrandLogo(size: 64, onDark: true),
            const SizedBox(height: 32),
            Text(
              'Service iPhone tanpa antre.',
              style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 24),
            for (final (icon, text) in points)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        text,
                        style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: .92)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}