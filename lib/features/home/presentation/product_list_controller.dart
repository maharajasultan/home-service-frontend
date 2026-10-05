import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reaple_app/core/network/api_exception.dart';
import 'package:reaple_app/features/product/data/product_models.dart';
import 'package:reaple_app/features/product/data/product_repository.dart';

class ProductListState {
  const ProductListState({
    this.items = const [],
    this.loading = false,
    this.loadingMore = false,
    this.error,
    this.page = 1,
    this.lastPage = 1,
    this.type,
    this.query = '',
  });

  final List<ProductModel> items;
  final bool loading;
  final bool loadingMore;
  final ApiException? error;
  final int page;
  final int lastPage;
  final String? type; // null = semua
  final String query;

  bool get hasMore => page < lastPage;

  ProductListState copyWith({
    List<ProductModel>? items,
    bool? loading,
    bool? loadingMore,
    ApiException? error,
    bool clearError = false,
    int? page,
    int? lastPage,
  }) {
    return ProductListState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: clearError ? null : (error ?? this.error),
      page: page ?? this.page,
      lastPage: lastPage ?? this.lastPage,
      type: type,
      query: query,
    );
  }
}

class ProductListController extends Notifier<ProductListState> {
  bool _alive = true;
  int _seq = 0; // menolak balasan lama jika filter berubah di tengah jalan

  @override
  ProductListState build() {
    _alive = true;
    ref.onDispose(() => _alive = false);
    Future.microtask(refresh);
    return const ProductListState(loading: true);
  }

  ProductRepository get _repo => ref.read(productRepositoryProvider);

  Future<void> setType(String? type) {
    if (type == state.type) return Future.value();
    state = ProductListState(type: type, query: state.query);
    return refresh();
  }

  Future<void> setQuery(String query) {
    if (query == state.query) return Future.value();
    state = ProductListState(type: state.type, query: query);
    return refresh();
  }

  Future<void> refresh() async {
    if (!_alive) return;
    final seq = ++_seq;
    state = state.copyWith(loading: true, loadingMore: false, clearError: true);

    try {
      final result = await _repo.fetchProducts(type: state.type, query: state.query, page: 1);
      if (!_alive || seq != _seq) return;
      state = state.copyWith(
        items: result.items,
        page: result.currentPage,
        lastPage: result.lastPage,
        loading: false,
      );
    } on ApiException catch (e) {
      if (!_alive || seq != _seq) return;
      state = state.copyWith(loading: false, error: e);
    }
  }

  Future<void> loadMore() async {
    if (!_alive || state.loading || state.loadingMore || !state.hasMore) return;
    final seq = _seq;
    state = state.copyWith(loadingMore: true, clearError: true);

    try {
      final result = await _repo.fetchProducts(type: state.type, query: state.query, page: state.page + 1);
      if (!_alive || seq != _seq) return;
      state = state.copyWith(
        items: [...state.items, ...result.items],
        page: result.currentPage,
        lastPage: result.lastPage,
        loadingMore: false,
      );
    } on ApiException catch (e) {
      if (!_alive || seq != _seq) return;
      state = state.copyWith(loadingMore: false, error: e);
    }
  }

  /// Tombol "Coba lagi" di bawah daftar.
  Future<void> retry() => (state.items.isEmpty || !state.hasMore) ? refresh() : loadMore();
}

final productListProvider = NotifierProvider<ProductListController, ProductListState>(ProductListController.new);