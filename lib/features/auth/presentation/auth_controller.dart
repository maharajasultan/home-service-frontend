import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reaple_app/core/network/api_exception.dart';
import 'package:reaple_app/core/network/session_events.dart';
import 'package:reaple_app/core/storage/token_storage.dart';
import 'package:reaple_app/features/auth/data/auth_repository.dart';
import 'package:reaple_app/features/auth/data/user_model.dart';

enum AuthStatus {
  unknown, // sedang memeriksa sesi
  authenticated,
  unauthenticated,
  offline, // punya token tapi server tidak terjangkau
}

class AuthState {
  const AuthState._(this.status, {this.user, this.message});

  const AuthState.unknown() : this._(AuthStatus.unknown);
  const AuthState.unauthenticated([String? message]) : this._(AuthStatus.unauthenticated, message: message);
  const AuthState.offline(String message) : this._(AuthStatus.offline, message: message);
  const AuthState.authenticated(UserModel user) : this._(AuthStatus.authenticated, user: user);

  final AuthStatus status;
  final UserModel? user;
  final String? message;
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    final sub = ref.read(sessionEventsProvider).onExpired.listen((_) => _onSessionExpired());
    ref.onDispose(sub.cancel);

    Future.microtask(bootstrap);
    return const AuthState.unknown();
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  /// Dipanggil saat aplikasi dibuka: pulihkan sesi dari token tersimpan.
  Future<void> bootstrap() async {
    state = const AuthState.unknown();

    final token = await ref.read(tokenStorageProvider).read();
    if (token == null || token.isEmpty) {
      state = const AuthState.unauthenticated();
      return;
    }

    try {
      state = AuthState.authenticated(await _repo.me());
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await ref.read(tokenStorageProvider).clear();
        state = const AuthState.unauthenticated('Sesi Anda berakhir. Silakan login kembali.');
      } else {
        state = AuthState.offline(e.message);
      }
    }
  }

  /// Melempar [ApiException] jika gagal. Jika berhasil, router otomatis memindahkan layar.
  Future<void> login({required String email, required String password}) async {
    final user = await _repo.login(email: email, password: password);
    state = AuthState.authenticated(user);
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    final user = await _repo.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    state = AuthState.authenticated(user);
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState.unauthenticated();
  }

  void _onSessionExpired() {
    if (state.status == AuthStatus.authenticated) {
      state = const AuthState.unauthenticated('Sesi Anda berakhir. Silakan login kembali.');
    }
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

final currentUserProvider = Provider<UserModel?>((ref) => ref.watch(authControllerProvider).user);