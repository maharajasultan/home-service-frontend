import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reaple_app/core/responsive/responsive.dart';
import 'package:reaple_app/core/router/app_router.dart';
import 'package:reaple_app/core/widgets/brand_logo.dart';
import 'package:reaple_app/core/widgets/error_banner.dart';
import 'package:reaple_app/core/widgets/error_view.dart';
import 'package:reaple_app/features/auth/presentation/auth_controller.dart';
import 'package:reaple_app/features/home/presentation/banner_carousel.dart';
import 'package:reaple_app/features/home/presentation/banner_controller.dart';
import 'package:reaple_app/features/home/presentation/product_card.dart';
import 'package:reaple_app/features/home/presentation/product_list_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const double _maxWidth = 1100;
  static const _filters = <(String?, String)>[
    (null, 'Semua'),
    ('sparepart', 'Sparepart'),
    ('matot', 'Service Matot'),
    ('unlock_imei', 'Unlock IMEI'),
  ];

  final _scroll = ScrollController();
  final _search = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.pixels >= pos.maxScrollExtent - 400) {
      ref.read(productListProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      ref.read(productListProvider.notifier).setQuery(value.trim());
    });
  }

  void _searchNow(String value) {
    _debounce?.cancel();
    ref.read(productListProvider.notifier).setQuery(value.trim());
  }

  Future<void> _refresh() {
    return Future.wait([
      ref.read(bannerProvider.notifier).refresh(),
      ref.read(productListProvider.notifier).refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final list = ref.watch(productListProvider);
    final banners = ref.watch(bannerProvider);
    final theme = Theme.of(context);
    final firstName = (user?.name ?? '').trim().split(' ').first;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final contentWidth = math.min(width, _maxWidth);
            final side = (width - contentWidth) / 2 + context.pagePadding;
            final columns = width >= 1000 ? 4 : (width >= 640 ? 3 : 2);

            return RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                controller: _scroll,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: ResponsiveCenter(
                      maxWidth: _maxWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      firstName.isEmpty ? 'Halo' : 'Halo, $firstName',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Teknisi iPhone datang langsung ke rumah Anda.',
                                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              const BrandLogo(size: 40, showName: false),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _search,
                            textInputAction: TextInputAction.search,
                            onChanged: _onSearchChanged,
                            onSubmitted: _searchNow,
                            decoration: InputDecoration(
                              hintText: 'Cari produk atau layanan',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _search,
                                builder: (_, value, __) => value.text.isEmpty
                                    ? const SizedBox.shrink()
                                    : IconButton(
                                        tooltip: 'Hapus',
                                        icon: const Icon(Icons.close_rounded),
                                        onPressed: () {
                                          _search.clear();
                                          _searchNow('');
                                        },
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          BannerCarousel(state: banners),
                          const SizedBox(height: 20),
                          Text('Layanan & Sparepart', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (final (type, label) in _filters)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      label: Text(label),
                                      selected: list.type == type,
                                      onSelected: (_) => ref.read(productListProvider.notifier).setType(type),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  ..._productSlivers(context, list, side: side, columns: columns, width: width),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _productSlivers(
    BuildContext context,
    ProductListState list, {
    required double side,
    required int columns,
    required double width,
  }) {
    if (list.loading && list.items.isEmpty) {
      return const [
        SliverToBoxAdapter(child: Padding(padding: EdgeInsets.symmetric(vertical: 48), child: Center(child: CircularProgressIndicator()))),
      ];
    }

    if (list.error != null && list.items.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: ErrorView(message: list.error!.message, onRetry: () => ref.read(productListProvider.notifier).refresh()),
        ),
      ];
    }

    if (list.items.isEmpty) {
      final message = list.query.isEmpty ? 'Belum ada produk.' : 'Produk "${list.query}" tidak ditemukan.';
      return [
        SliverToBoxAdapter(
          child: ErrorView(message: message, icon: Icons.search_off_rounded),
        ),
      ];
    }

    const spacing = 12.0;
    final itemWidth = (width - side * 2 - spacing * (columns - 1)) / columns;
    // Tinggi kartu = foto 4:3 + area teks (ikut membesar jika font sistem diperbesar).
    final extent = itemWidth * 0.75 + MediaQuery.textScalerOf(context).scale(134);

    return [
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: side),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            mainAxisExtent: extent,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final product = list.items[i];
              return ProductCard(
                product: product,
                onTap: () => context.push(AppRoutes.productDetail(product.id)),
              );
            },
            childCount: list.items.length,
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(side, 16, side, 32),
          child: _footer(list),
        ),
      ),
    ];
  }

  Widget _footer(ProductListState list) {
    if (list.loadingMore) {
      return const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)));
    }

    if (list.error != null) {
      return Column(
        children: [
          ErrorBanner(list.error!.message),
          TextButton(onPressed: () => ref.read(productListProvider.notifier).retry(), child: const Text('Coba lagi')),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}