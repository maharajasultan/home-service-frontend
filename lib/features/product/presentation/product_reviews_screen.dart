import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reaple_app/core/network/api_exception.dart';
import 'package:reaple_app/core/responsive/responsive.dart';
import 'package:reaple_app/core/router/app_router.dart';
import 'package:reaple_app/core/widgets/error_view.dart';
import 'package:reaple_app/features/product/data/product_models.dart';
import 'package:reaple_app/features/product/data/product_repository.dart';
import 'package:reaple_app/features/product/presentation/review_tile.dart';

class ProductReviewsScreen extends ConsumerStatefulWidget {
  const ProductReviewsScreen({super.key, required this.productId});

  final int productId;

  @override
  ConsumerState<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends ConsumerState<ProductReviewsScreen> {
  final _scroll = ScrollController();

  List<ReviewModel> _items = const [];
  int _page = 1;
  int _lastPage = 1;
  int _total = 0;
  bool _loading = true;
  bool _loadingMore = false;
  ApiException? _error;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.hasClients && _scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) _loadMore();
    });
    _loadFirst();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadFirst() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final page = await ref.read(productRepositoryProvider).fetchReviews(widget.productId);
      if (!mounted) return;
      setState(() {
        _items = page.items;
        _page = page.currentPage;
        _lastPage = page.lastPage;
        _total = page.total;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || _page >= _lastPage) return;
    setState(() => _loadingMore = true);

    try {
      final page = await ref.read(productRepositoryProvider).fetchReviews(widget.productId, page: _page + 1);
      if (!mounted) return;
      setState(() {
        _items = [..._items, ...page.items];
        _page = page.currentPage;
        _lastPage = page.lastPage;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.productDetail(widget.productId));
            }
          },
        ),
        title: Text(_total > 0 ? 'Ulasan ($_total)' : 'Ulasan Produk'),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return ErrorView(message: _error!.message, onRetry: _loadFirst);
    if (_items.isEmpty) return const ErrorView(message: 'Belum ada ulasan untuk produk ini.', icon: Icons.rate_review_outlined);

    return ResponsiveCenter(
      maxWidth: 720,
      child: ListView.separated(
        controller: _scroll,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _items.length + 1,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          if (i < _items.length) return ReviewTile(_items[i]);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: _loadingMore ? const CircularProgressIndicator(strokeWidth: 2.5) : const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}