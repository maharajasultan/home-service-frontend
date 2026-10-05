import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reaple_app/core/network/api_exception.dart';
import 'package:reaple_app/core/router/app_router.dart';
import 'package:reaple_app/core/utils/validators.dart';
import 'package:reaple_app/core/widgets/app_text_field.dart';
import 'package:reaple_app/core/widgets/error_banner.dart';
import 'package:reaple_app/core/widgets/primary_button.dart';
import 'package:reaple_app/features/auth/data/auth_repository.dart';
import 'package:reaple_app/features/auth/presentation/auth_scaffold.dart';

/// Dua langkah dalam satu layar: (1) masukkan email, (2) masukkan kode 6 digit + sandi baru.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailKey = GlobalKey<FormState>();
  final _resetKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _codeSent = false;
  bool _loading = false;
  ApiException? _error;
  String? _info;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _clearError(String _) {
    if (_error != null) setState(() => _error = null);
  }

  Future<void> _sendCode({bool resend = false}) async {
    FocusScope.of(context).unfocus();
    if (!resend && !(_emailKey.currentState?.validate() ?? false)) return;

    setState(() {
      _loading = true;
      _error = null;
      _info = null;
    });

    try {
      await ref.read(authRepositoryProvider).forgotPassword(_email.text.trim().toLowerCase());
      if (!mounted) return;
      setState(() {
        _codeSent = true;
        _info = 'Jika email terdaftar, kode verifikasi 6 digit telah dikirim. Kode berlaku 15 menit.';
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reset() async {
    FocusScope.of(context).unfocus();
    if (!(_resetKey.currentState?.validate() ?? false)) return;

    setState(() {
      _loading = true;
      _error = null;
      _info = null;
    });

    try {
      await ref.read(authRepositoryProvider).resetPassword(
            email: _email.text.trim().toLowerCase(),
            code: _code.text.trim(),
            password: _password.text,
            passwordConfirmation: _confirm.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kata sandi berhasil diubah. Silakan login.')),
      );
      context.go(AppRoutes.login);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bannerMessage = (_error != null && !_error!.hasFieldErrors) ? _error!.message : null;

    return AuthScaffold(
      title: _codeSent ? 'Masukkan kode verifikasi' : 'Lupa kata sandi?',
      subtitle: _codeSent
          ? 'Kami mengirim kode ke ${_email.text.trim()}. Masukkan kode tersebut dan buat kata sandi baru.'
          : 'Masukkan email akun Anda. Kami akan mengirim kode verifikasi 6 digit.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_info != null) ...[ErrorBanner(_info!, isInfo: true), const SizedBox(height: 16)],
          if (bannerMessage != null) ...[ErrorBanner(bannerMessage), const SizedBox(height: 16)],
          if (!_codeSent) _emailStep() else _resetStep(),
        ],
      ),
    );
  }

  Widget _emailStep() {
    return Form(
      key: _emailKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _email,
            label: 'Email',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: Validators.email,
            errorText: _error?.fieldError('email'),
            onChanged: _clearError,
            onSubmitted: (_) => _sendCode(),
            enabled: !_loading,
          ),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Kirim Kode', loading: _loading, onPressed: _sendCode),
          const SizedBox(height: 8),
          TextButton(onPressed: () => context.go(AppRoutes.login), child: const Text('Kembali ke halaman masuk')),
        ],
      ),
    );
  }

  Widget _resetStep() {
    return Form(
      key: _resetKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _code,
            label: 'Kode verifikasi',
            hint: '6 digit',
            icon: Icons.pin_outlined,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: Validators.code,
            errorText: _error?.fieldError('code'),
            onChanged: _clearError,
            enabled: !_loading,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _password,
            label: 'Kata sandi baru',
            icon: Icons.lock_outline_rounded,
            obscure: true,
            textInputAction: TextInputAction.next,
            validator: Validators.password,
            errorText: _error?.fieldError('password'),
            onChanged: _clearError,
            enabled: !_loading,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _confirm,
            label: 'Konfirmasi kata sandi baru',
            icon: Icons.lock_reset_rounded,
            obscure: true,
            textInputAction: TextInputAction.done,
            validator: (v) => v != _password.text ? 'Konfirmasi kata sandi tidak cocok.' : null,
            onSubmitted: (_) => _reset(),
            enabled: !_loading,
          ),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Ubah Kata Sandi', loading: _loading, onPressed: _reset),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              TextButton(onPressed: _loading ? null : () => _sendCode(resend: true), child: const Text('Kirim ulang kode')),
              TextButton(
                onPressed: _loading ? null : () => setState(() {
                  _codeSent = false;
                  _error = null;
                  _info = null;
                }),
                child: const Text('Ganti email'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}