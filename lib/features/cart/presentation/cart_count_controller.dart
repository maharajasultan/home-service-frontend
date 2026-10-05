import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reaple_app/core/network/api_exception.dart';
import 'package:reaple_app/features/auth/presentation/auth_controller.dart';
import 'package:reaple_app/features/cart/data/cart_repository.dart';

/// Angka badge keranjang. Otomatis diulang saat pengguna berganti akun.
class CartCountController extends Notifier<int> {
  bool _alive = true;

  @override
  int build() {
    _alive = true;
    ref.onDispose(() => _alive = false);

    final user = ref.watch(currentUserProvider);
    if (user != null && !user.isTechnician) Future.microtask(refresh);

    return 0;
  }

  Future<void> refresh() async {
    try {
      final count = await ref.read(cartRepositoryProvider).count();
      if (_alive) state = count;
    } on ApiException {
      // Badge tidak kritis: biarkan angka lama.
    }
  }

  void set(int count) {
    if (_alive) state = count;
  }
}

final cartCountProvider = NotifierProvider<CartCountController, int>(CartCountController.new);