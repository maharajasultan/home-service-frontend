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
import 'package:reaple_app/features/auth/presentation/auth_controller.dart';
import 'package:reaple_app/features/auth/presentation/auth_scaffold.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _loading = false;
  ApiException? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _clearError(String _) {
    if (_error != null) setState(() => _error = null);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).register(
            name: _name.text.trim(),
            email: _email.text.trim().toLowerCase(),
            phone: _phone.text.trim(),
            password: _password.text,
            passwordConfirmation: _confirm.text,
          );
      // Berhasil: otomatis login dan dipindahkan oleh router.
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
      title: 'Buat akun baru',
      subtitle: 'Daftar gratis dan pesan teknisi ke rumah dalam hitungan menit.',
      footer: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('Sudah punya akun?'),
          TextButton(onPressed: () => context.go(AppRoutes.login), child: const Text('Masuk')),
        ],
      ),
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (bannerMessage != null) ...[ErrorBanner(bannerMessage), const SizedBox(height: 16)],
              AppTextField(
                controller: _name,
                label: 'Nama lengkap',
                icon: Icons.person_outline_rounded,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                validator: (v) => Validators.requiredText(v, 'Nama'),
                errorText: _error?.fieldError('name'),
                onChanged: _clearError,
                enabled: !_loading,
              ),
              const SizedBox(height: 16),
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
                controller: _phone,
                label: 'Nomor HP / WhatsApp',
                hint: '081234567890',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumber],
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\- ]'))],
                validator: Validators.phone,
                errorText: _error?.fieldError('phone'),
                onChanged: _clearError,
                enabled: !_loading,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _password,
                label: 'Kata sandi',
                icon: Icons.lock_outline_rounded,
                obscure: true,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                validator: Validators.password,
                errorText: _error?.fieldError('password'),
                onChanged: _clearError,
                enabled: !_loading,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 4, top: 6),
                child: Text('Minimal 8 karakter, mengandung huruf dan angka.', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _confirm,
                label: 'Konfirmasi kata sandi',
                icon: Icons.lock_reset_rounded,
                obscure: true,
                textInputAction: TextInputAction.done,
                validator: (v) => v != _password.text ? 'Konfirmasi kata sandi tidak cocok.' : null,
                onSubmitted: (_) => _submit(),
                enabled: !_loading,
              ),
              const SizedBox(height: 24),
              PrimaryButton(label: 'Daftar', loading: _loading, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}