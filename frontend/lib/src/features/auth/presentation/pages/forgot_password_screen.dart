import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:frontend/src/core/l10n/l10n.dart';
import 'package:frontend/src/routes/app_route_path.dart';
import 'package:frontend/src/widgets/custom_button.dart';

import '../bloc/auth/auth_bloc.dart';
import '../widgets/auth_theme.dart';

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
    final authColors = AuthTheme.colorsOf(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthForgotPasswordSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: authColors.authPrimaryAction,
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
        backgroundColor: authColors.authBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: AuthTheme.backButton(
            context,
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
                  style: AuthTheme.titleStyle(context),
                  textAlign: TextAlign.center,
                ),
                16.hS,
                Text(
                  l10n.forgotPasswordDescription,
                  style: AuthTheme.bodyStyle(context),
                  textAlign: TextAlign.center,
                ),
                32.hS,
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: AuthTheme.inputDecoration(
                    context,
                    l10n.enterEmailHint,
                  ),
                  style: TextStyle(color: authColors.authInputText),
                ),
                24.hS,
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthForgotPasswordLoadingState;

                    return CustomButton(
                      label: l10n.sendVerificationCode,
                      color: (_isValid && !isLoading)
                          ? authColors.authPrimaryAction
                          : authColors.authDisabledAction,
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
