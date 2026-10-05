import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reaple_app/core/network/api_exception.dart';
import 'package:reaple_app/core/router/app_router.dart';
import 'package:reaple_app/core/utils/validators.dart';
import 'package:reaple_app/core/widgets/app_text_field.dart';
import 'package:reaple_app/core/widgets/error_banner.dart';
import 'package:reaple_app/core/widgets/primary_button.dart';
import 'package:reaple_app/features/auth/presentation/auth_controller.dart';
import 'package:reaple_app/features/auth/presentation/auth_scaffold.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  ApiException? _error;
  String? _info;

  @override
  void initState() {
    super.initState();
    _info = ref.read(authControllerProvider).message; // contoh: "Sesi Anda berakhir..."
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _clearError(String _) {
    if (_error != null || _info != null) setState(() {
      _error = null;
      _info = null;
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
      _info = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).login(
            email: _email.text.trim().toLowerCase(),
            password: _password.text,
          );
      // Berhasil: router otomatis memindahkan ke halaman sesuai role.
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
      title: 'Selamat datang kembali',
      subtitle: 'Masuk untuk memesan service iPhone ke rumah Anda.',
      footer: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('Belum punya akun?'),
          TextButton(onPressed: () => context.go(AppRoutes.register), child: const Text('Daftar')),
        ],
      ),
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_info != null) ...[ErrorBanner(_info!, isInfo: true), const SizedBox(height: 16)],
              if (bannerMessage != null) ...[ErrorBanner(bannerMessage), const SizedBox(height: 16)],
              AppTextField(
                controller: _email,
                label: 'Email',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: Validators.email,
                errorText: _error?.fieldError('email'),
                onChanged: _clearError,
                enabled: !_loading,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _password,
                label: 'Kata sandi',
                icon: Icons.lock_outline_rounded,
                obscure: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                validator: (v) => Validators.requiredText(v, 'Kata sandi'),
                errorText: _error?.fieldError('password'),
                onChanged: _clearError,
                onSubmitted: (_) => _submit(),
                enabled: !_loading,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _loading ? null : () => context.push(AppRoutes.forgotPassword),
                  child: const Text('Lupa kata sandi?'),
                ),
              ),
              const SizedBox(height: 8),
              PrimaryButton(label: 'Masuk', loading: _loading, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}