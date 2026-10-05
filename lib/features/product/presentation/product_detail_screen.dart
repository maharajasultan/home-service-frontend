import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reaple_app/core/network/api_exception.dart';
import 'package:reaple_app/core/responsive/responsive.dart';
import 'package:reaple_app/core/router/app_router.dart';
import 'package:reaple_app/core/utils/format.dart';
import 'package:reaple_app/core/widgets/app_network_image.dart';
import 'package:reaple_app/core/widgets/error_banner.dart';
import 'package:reaple_app/core/widgets/error_view.dart';
import 'package:reaple_app/core/widgets/rating_stars.dart';
import 'package:reaple_app/features/cart/data/cart_repository.dart';
import 'package:reaple_app/features/cart/presentation/cart_count_controller.dart';
import 'package:reaple_app/features/checkout/data/checkout_draft.dart';
import 'package:reaple_app/features/product/data/product_models.dart';
import 'package:reaple_app/features/product/data/product_repository.dart';
import 'package:reaple_app/features/product/presentation/review_tile.dart';
import 'package:reaple_app/features/product/presentation/variant_picker_sheet.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final int productId;

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  ProductModel? _product;
  ApiException? _error;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.productId <= 0) {
      setState(() {
        _loading = false;
        _error = ApiException('Produk tidak ditemukan.', statusCode: 404);
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final product = await ref.read(productRepositoryProvider).fetchProduct(widget.productId);
      if (!mounted) return;
      setState(() => _product = product);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _start(VariantAction action) async {
    final product = _product;
    if (product == null || _busy) return;

    if (product.variants.isEmpty) {
      _snack('Produk ini belum tersedia.');
      return;
    }

    final selection = await showVariantPicker(context, product: product, action: action);
    if (selection == null || !mounted) return;

    final variant = selection.variant;

    if (action == VariantAction.buyNow) {
      ref.read(checkoutDraftProvider.notifier).setDirect(
            CheckoutLine(
              productId: product.id,
              productName: product.name,
              productType: product.type,
              variantId: variant.id,
              variantLabel: variant.shortLabel,
              unitPrice: variant.price,
              baseFee: product.baseFee,
              qty: selection.qty,
            ),
          );
      context.push(AppRoutes.checkout);
      return;
    }

    setState(() => _busy = true);
    try {
      final count = await ref.read(cartRepositoryProvider).add(variantId: variant.id, qty: selection.qty);
      ref.read(cartCountProvider.notifier).set(count);
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('Ditambahkan ke keranjang.'),
            action: SnackBarAction(label: 'Lihat', onPressed: () => context.go(AppRoutes.userCart)),
          ),
        );
    } on ApiException catch (e) {
      if (!mounted) return;
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;

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
        title: Text(product?.name ?? 'Detail Produk', maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: _body(product),
      bottomNavigationBar: product == null
          ? null
          : _ActionBar(
              busy: _busy,
              enabled: product.variants.isNotEmpty,
              onAdd: () => _start(VariantAction.addToCart),
              onBuy: () => _start(VariantAction.buyNow),
            ),
    );
  }

  Widget _body(ProductModel? product) {
    if (product == null) {
      if (_loading) return const Center(child: CircularProgressIndicator());

      final error = _error;
      final notFound = error?.statusCode == 404;

      return ErrorView(
        message: notFound ? 'Produk tidak ditemukan atau sudah tidak tersedia.' : (error?.message ?? 'Terjadi kesalahan.'),
        icon: notFound ? Icons.search_off_rounded : Icons.cloud_off_rounded,
        onRetry: notFound ? null : _load,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final images = product.images.isNotEmpty
            ? product.images
            : (product.thumbnail != null ? [product.thumbnail!] : <String>[]);

        final gallery = _Gallery(images: images);
        final info = _Info(product: product);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: ResponsiveCenter(
            maxWidth: 1100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: gallery),
                      const SizedBox(width: 32),
                      Expanded(flex: 6, child: info),
                    ],
                  )
                else ...[
                  gallery,
                  const SizedBox(height: 16),
                  info,
                ],
                const SizedBox(height: 24),
                _ReviewsSection(
                  product: product,
                  onSeeAll: () => context.push(AppRoutes.productReviews(product.id)),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.busy, required this.enabled, required this.onAdd, required this.onBuy});

  final bool busy;
  final bool enabled;
  final VoidCallback onAdd;
  final VoidCallback onBuy;

  Widget _fit(String text) => FittedBox(fit: BoxFit.scaleDown, child: Text(text, maxLines: 1));

  @override
  Widget build(BuildContext context) {
    final active = enabled && !busy;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: ResponsiveCenter(
          maxWidth: 1100,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: active ? onAdd : null, child: _fit('Masukkan Keranjang'))),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: active ? onBuy : null,
                    child: busy
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Theme.of(context).colorScheme.onPrimary),
                          )
                        : _fit('Beli Langsung'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Gallery extends StatefulWidget {
  const _Gallery({required this.images});

  final List<String> images;

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final images = widget.images;

    if (images.isEmpty) {
      return AspectRatio(
        aspectRatio: 4 / 3,
        child: AppNetworkImage(null, borderRadius: BorderRadius.circular(16), iconSize: 48),
      );
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: PageView.builder(
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => AppNetworkImage(images[i]),
            ),
          ),
        ),
        if (images.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < images.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _index ? 18 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == _index ? scheme.primary : scheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final p = product;
    final price = p.startingPrice;
    final inspection = p.options.inspectionOnly;
    final description = p.description?.trim() ?? '';

    final hint = p.options.needsGrade
        ? 'Pilih tipe iPhone dan grade (Standar, Premium, Original) saat memesan.'
        : p.options.needsDuration
            ? 'Pilih durasi (bulan) saat memesan.'
            : 'Pilih tipe iPhone saat memesan.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(20)),
          child: Text(
            p.typeLabel,
            style: theme.textTheme.labelMedium?.copyWith(color: scheme.onPrimaryContainer, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        Text(p.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Row(
          children: [
            RatingStars(rating: p.ratingAvg, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                p.ratingCount > 0 ? '${p.ratingAvg.toStringAsFixed(1)} (${p.ratingCount} ulasan)' : 'Belum ada ulasan',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          inspection ? 'Biaya ongkir/pengecekan' : 'Mulai dari',
          style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        Text(
          price == null ? 'Belum tersedia' : Fmt.rupiah(price),
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: scheme.primary),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(p.inStock ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 18, color: p.inStock ? Colors.green : scheme.error),
            const SizedBox(width: 6),
            Text(p.inStock ? 'Tersedia' : 'Stok habis'),
          ],
        ),
        if (inspection) ...[
          const SizedBox(height: 16),
          const ErrorBanner(
            'Anda hanya membayar ongkir/pengecekan. Estimasi perbaikan tidak dihitung di awal, teknisi hanya mencari kerusakan.',
            isInfo: true,
          ),
        ],
        const SizedBox(height: 16),
        Text(hint, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
        const Divider(height: 32),
        Text('Deskripsi', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(description.isEmpty ? 'Belum ada deskripsi.' : description),
      ],
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({required this.product, required this.onSeeAll});

  final ProductModel product;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = product;
    final reviews = p.latestReviews;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Ulasan', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                if (p.ratingCount > reviews.length)
                  TextButton(onPressed: onSeeAll, child: Text('Lihat semua (${p.ratingCount})')),
              ],
            ),
            if (p.ratingCount > 0) ...[
              Row(
                children: [
                  Text(p.ratingAvg.toStringAsFixed(1), style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(width: 8),
                  RatingStars(rating: p.ratingAvg, size: 18),
                  const SizedBox(width: 8),
                  Flexible(child: Text('dari ${p.ratingCount} ulasan')),
                ],
              ),
              const SizedBox(height: 4),
            ],
            if (reviews.isEmpty)
              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Belum ada ulasan untuk produk ini.'))
            else
              for (var i = 0; i < reviews.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                ReviewTile(reviews[i]),
              ],
          ],
        ),
      ),
    );
  }
}