import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/admin_auth_cubit.dart';
import '../bloc/auth/admin_auth_state.dart';
import '../widgets/login_form_fields.dart';
import '../widgets/login_stage_panel.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: LoginStagePanel(wide: wide, form: _buildForm()),
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

        return LoginFormFields(
          usernameController: _usernameController,
          passwordController: _passwordController,
          submitting: submitting,
          onPasswordSubmitted: () => _submit(context),
          formKey: _formKey,
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
