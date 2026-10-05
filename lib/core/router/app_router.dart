import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reaple_app/features/auth/presentation/auth_controller.dart';
import 'package:reaple_app/features/auth/presentation/forgot_password_screen.dart';
import 'package:reaple_app/features/auth/presentation/login_screen.dart';
import 'package:reaple_app/features/auth/presentation/register_screen.dart';
import 'package:reaple_app/features/auth/presentation/splash_screen.dart';
import 'package:reaple_app/features/checkout/presentation/checkout_placeholder_screen.dart';
import 'package:reaple_app/features/home/presentation/home_screen.dart';
import 'package:reaple_app/features/product/presentation/product_detail_screen.dart';
import 'package:reaple_app/features/product/presentation/product_reviews_screen.dart';
import 'package:reaple_app/shell/feature_placeholder.dart';
import 'package:reaple_app/shell/session_placeholder.dart';
import 'package:reaple_app/shell/technician_shell.dart';
import 'package:reaple_app/shell/user_shell.dart';

abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  // Area pelanggan (semua diawali /user agar RBAC berlaku)
  static const user = '/user';
  static const userCart = '/user/cart';
  static const userHistory = '/user/history';
  static const userChat = '/user/chat';
  static const userProfile = '/user/profile';
  static const checkout = '/user/checkout';

  static String productDetail(int id) => '/user/product/$id';
  static String productReviews(int id) => '/user/product/$id/reviews';

  static const technician = '/technician';
}

const _publicRoutes = {AppRoutes.login, AppRoutes.register, AppRoutes.forgotPassword};

/// Aturan akses (RBAC) di satu tempat.
String? _redirect(AuthState auth, String location) {
  switch (auth.status) {
    case AuthStatus.unknown:
    case AuthStatus.offline:
      return location == AppRoutes.splash ? null : AppRoutes.splash;

    case AuthStatus.unauthenticated:
      return _publicRoutes.contains(location) ? null : AppRoutes.login;

    case AuthStatus.authenticated:
      final isTechnician = auth.user?.isTechnician ?? false;
      final home = isTechnician ? AppRoutes.technician : AppRoutes.user;

      if (location == AppRoutes.splash || _publicRoutes.contains(location)) return home;
      if (location.startsWith(AppRoutes.technician) && !isTechnician) return home;
      if (location.startsWith(AppRoutes.user) && isTechnician) return home;
      return null;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);

  // Router dievaluasi ulang setiap status login berubah.
  ref.listen<AuthState>(authControllerProvider, (previous, next) {
    if (previous?.status != next.status) refresh.value++;
  });

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) => _redirect(ref.read(authControllerProvider), state.matchedLocation),
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: AppRoutes.register, builder: (_, __) => const RegisterScreen()),
      GoRoute(path: AppRoutes.forgotPassword, builder: (_, __) => const ForgotPasswordScreen()),

      // ---------- Pelanggan: shell dengan 5 tab ----------
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => UserShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.user, builder: (_, __) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.userCart,
              builder: (_, __) => const FeaturePlaceholder(
                title: 'Keranjang',
                icon: Icons.shopping_cart_rounded,
                note: 'Layar keranjang dibuat di F3.',
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.userHistory,
              builder: (_, __) => const FeaturePlaceholder(
                title: 'Riwayat',
                icon: Icons.receipt_long_rounded,
                note: 'Riwayat transaksi (Berhasil, Pending, Gagal) dibuat di F4.',
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.userChat,
              builder: (_, __) => const FeaturePlaceholder(
                title: 'Chat',
                icon: Icons.chat_bubble_rounded,
                note: 'Chat dengan teknisi dan admin dibuat di F5.',
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.userProfile,
              builder: (_, __) => const SessionPlaceholder(
                title: 'Profil',
                note: 'Edit profil, Daftar Teknisi, dan Tentang Kami dibuat di F6.',
              ),
            ),
          ]),
        ],
      ),

      // ---------- Pelanggan: layar penuh di atas shell ----------
      GoRoute(
        path: '/user/product/:id',
        builder: (_, state) => ProductDetailScreen(productId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0),
      ),
      GoRoute(
        path: '/user/product/:id/reviews',
        builder: (_, state) => ProductReviewsScreen(productId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0),
      ),
      GoRoute(path: AppRoutes.checkout, builder: (_, __) => const CheckoutPlaceholderScreen()),

      // ---------- Teknisi ----------
      GoRoute(path: AppRoutes.technician, builder: (_, __) => const TechnicianShell()),
    ],
    errorBuilder: (context, state) => const _NotFoundScreen(),
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });

  return router;
});

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Halaman tidak ditemukan.'),
            const SizedBox(height: 12),
            FilledButton(onPressed: () => context.go(AppRoutes.splash), child: const Text('Kembali')),
          ],
        ),
      ),
    );
  }
}