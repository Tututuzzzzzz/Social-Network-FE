import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:frontend/src/core/l10n/l10n.dart';
import 'package:frontend/src/routes/app_route_path.dart';
import 'package:frontend/src/widgets/custom_button.dart';

import '../bloc/auth/auth_bloc.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _validateInput() {
    final email = _emailController.text.trim();
    final isValid = email.isNotEmpty && email.contains('@');
    if (isValid != _isValid) {
      setState(() {
        _isValid = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthForgotPasswordSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFF3CC18E),
            ),
          );
          context.go(AppRoutes.login.path);
        }

        if (state is AuthForgotPasswordFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.black, size: 32),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                40.hS,
                Text(
                  l10n.forgotPasswordTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                16.hS,
                Text(
                  l10n.forgotPasswordDescription,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                32.hS,
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: l10n.enterEmailHint,
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                24.hS,
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthForgotPasswordLoadingState;

                    return CustomButton(
                      label: l10n.sendVerificationCode,
                      color: (_isValid && !isLoading)
                          ? const Color(0xFF3CC18E)
                          : const Color(0xFFB7BBC1),
                      onPressed: () {
                        if (_isValid && !isLoading) {
                          context.read<AuthBloc>().add(
                                AuthForgotPasswordEvent(
                                  _emailController.text.trim(),
                                ),
                              );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
