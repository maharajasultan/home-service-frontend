import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.keyboardType,
    this.textInputAction,
    this.obscure = false,
    this.validator,
    this.errorText,
    this.onSubmitted,
    this.onChanged,
    this.autofillHints,
    this.enabled = true,
    this.maxLength,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscure;
  final String? Function(String?)? validator;

  /// Pesan error dari server untuk kolom ini.
  final String? errorText;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final Iterable<String>? autofillHints;
  final bool enabled;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: _hidden,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      onFieldSubmitted: widget.onSubmitted,
      onChanged: widget.onChanged,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.errorText,
        counterText: '',
        prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
        suffixIcon: widget.obscure
            ? IconButton(
                tooltip: _hidden ? 'Tampilkan kata sandi' : 'Sembunyikan kata sandi',
                icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _hidden = !_hidden),
              )
            : null,
      ),
    );
  }
}