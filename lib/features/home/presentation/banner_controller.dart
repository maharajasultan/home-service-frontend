import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reaple_app/core/network/api_exception.dart';
import 'package:reaple_app/features/home/data/banner_model.dart';
import 'package:reaple_app/features/home/data/home_repository.dart';

class BannerState {
  const BannerState({this.items = const [], this.loading = false, this.error});

  final List<BannerModel> items;
  final bool loading;
  final ApiException? error;
}

class BannerController extends Notifier<BannerState> {
  bool _alive = true;

  @override
  BannerState build() {
    _alive = true;
    ref.onDispose(() => _alive = false);
    Future.microtask(refresh);
    return const BannerState(loading: true);
  }

  Future<void> refresh() async {
    if (!_alive) return;
    state = BannerState(items: state.items, loading: true);

    try {
      final items = await ref.read(homeRepositoryProvider).fetchBanners();
      if (_alive) state = BannerState(items: items);
    } on ApiException catch (e) {
      if (_alive) state = BannerState(items: state.items, error: e);
    }
  }
}

final bannerProvider = NotifierProvider<BannerController, BannerState>(BannerController.new);