import 'package:flutter/material.dart';

class LoginFormFields extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool submitting;
  final VoidCallback onPasswordSubmitted;
  final GlobalKey<FormState> formKey;

  const LoginFormFields({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.submitting,
    required this.onPasswordSubmitted,
    required this.formKey,
  });

  @override
  State<LoginFormFields> createState() => _LoginFormFieldsState();
}

class _LoginFormFieldsState extends State<LoginFormFields> {
  late bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: widget.usernameController,
            enabled: !widget.submitting,
            decoration: const InputDecoration(
              labelText: 'Tên đăng nhập',
              prefixIcon: Icon(Icons.person_outline),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if ((value ?? '').trim().isEmpty) {
                return 'Tên đăng nhập là bắt buộc';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: widget.passwordController,
            enabled: !widget.submitting,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                tooltip: _obscurePassword ? 'Hiển thị mật khẩu' : 'Ẩn mật khẩu',
                onPressed: widget.submitting
                    ? null
                    : () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            onFieldSubmitted: (_) => widget.onPasswordSubmitted(),
            validator: (value) {
              if ((value ?? '').trim().isEmpty) {
                return 'Mật khẩu là bắt buộc';
              }
              return null;
            },
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: widget.submitting ? null : widget.onPasswordSubmitted,
            icon: widget.submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.login),
            label: Text(widget.submitting ? 'Đang đăng nhập' : 'Đăng nhập'),
          ),
        ],
      ),
    );
  }
}
