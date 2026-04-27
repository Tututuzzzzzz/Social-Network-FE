import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/admin_auth_cubit.dart';
import '../bloc/auth/admin_auth_state.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminAuthCubit, AdminAuthState>(
      listenWhen: (previous, current) => previous.message != current.message,
      listener: (context, state) {
        final message = state.message;
        if (message == null || message.trim().isEmpty) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
        );
      },
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 920;

            return Container(
              color: const Color(0xFFF7F5EF),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: wide
                        ? Row(
                            children: [
                              const Expanded(child: _LoginBrandPanel()),
                              const SizedBox(width: 22),
                              Expanded(
                                child: _LoginFormPanel(form: _buildForm()),
                              ),
                            ],
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                const _LoginBrandPanel(compact: true),
                                const SizedBox(height: 18),
                                _LoginFormPanel(form: _buildForm()),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm() {
    return BlocBuilder<AdminAuthCubit, AdminAuthState>(
      builder: (context, state) {
        final submitting = state.status == AdminAuthStatus.submitting;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _usernameController,
                enabled: !submitting,
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
                controller: _passwordController,
                enabled: !submitting,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword
                        ? 'Hiển thị mật khẩu'
                        : 'Ẩn mật khẩu',
                    onPressed: submitting
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
                onFieldSubmitted: (_) => _submit(context),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Mật khẩu là bắt buộc';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: submitting ? null : () => _submit(context),
                icon: submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: Text(submitting ? 'Đang đăng nhập' : 'Đăng nhập'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submit(BuildContext context) {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      return;
    }

    context.read<AdminAuthCubit>().login(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );
  }
}

class _LoginBrandPanel extends StatelessWidget {
  final bool compact;

  const _LoginBrandPanel({this.compact = false});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: compact ? 220 : 560),
      padding: EdgeInsets.all(compact ? 24 : 34),
      decoration: BoxDecoration(
        color: const Color(0xFF17211D),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.shield, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                'Mochi Admin',
                style: textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 42),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quản trị viên Mochi',
                style: textTheme.displaySmall?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 14),
              Text(
                'Sử dụng tài khoản quản trị viên để đăng nhập và quản lý nội dung mạng xã hội.',
                style: textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: .72),
                ),
              ),
            ],  
          ),
        ],
      ),
    );
  }
}

class _LoginFormPanel extends StatelessWidget {
  final Widget form;

  const _LoginFormPanel({required this.form});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Đăng nhập', style: textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Sử dụng tài khoản quản trị viên để đăng nhập và quản lý nội dung mạng xã hội.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 26),
            form,
          ],
        ),
      ),
    );
  }
}
