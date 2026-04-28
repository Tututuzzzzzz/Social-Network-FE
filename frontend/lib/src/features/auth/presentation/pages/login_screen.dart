import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/src/configs/injector/injector_conf.dart';
import 'package:frontend/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:frontend/src/core/l10n/l10n.dart';
import 'package:frontend/src/routes/app_route_path.dart';
import 'package:frontend/src/widgets/custom_button.dart';
import 'package:frontend/src/widgets/snackbar_widget.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth_login_form/auth_login_form_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthLoginFormBloc>(
      create: (_) => getIt<AuthLoginFormBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          final l10n = context.l10n;

          if (state is AuthLoginSuccessState) {
            appSnackBar(context, Colors.green, l10n.loginSuccess);

            context.go(AppRoutes.home.path);
          }

          if (state is AuthLoginFailureState) {
            appSnackBar(
              context,
              Colors.red,
              state.message.isEmpty ? l10n.loginFailed : state.message,
            );
          }
        },
        child: Builder(
          builder: (context) {
            final l10n = context.l10n;

            return Scaffold(
              backgroundColor: const Color(0xFFFFffff),
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      16.hS,
                      Image.asset(
                        'assets/images/logo.jpg',
                        height: 104,
                        width: 187,
                      ),
                      32.hS,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _usernameController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            onChanged: (value) {
                              context.read<AuthLoginFormBloc>().add(
                                LoginFormUsernameChangedEvent(value.trim()),
                              );
                            },
                            decoration: InputDecoration(
                              hintText: l10n.loginUsernameHint,
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
                          12.hS,
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onChanged: (value) {
                              context.read<AuthLoginFormBloc>().add(
                                LoginFormPasswordChangedEvent(value),
                              );
                            },
                            decoration: InputDecoration(
                              hintText: l10n.loginPasswordHint,
                              filled: true,
                              fillColor: const Color(0xFFF5F5F5),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          4.hS,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (v) => setState(
                                      () => _rememberMe = v ?? false,
                                    ),
                                  ),
                                  Text(l10n.rememberPassword),
                                ],
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  l10n.forgotPassword,
                                  style: const TextStyle(
                                    color: Color(0xFF3797EF),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          36.hS,
                          BlocBuilder<AuthLoginFormBloc, LoginFormState>(
                            builder: (context, formState) {
                              final isValid = formState.isValid;
                              return CustomButton(
                                label: l10n.login,
                                color: isValid
                                    ? const Color(0xFF83C2FB)
                                    : Colors.grey.shade400,
                                onPressed: () async {
                                  if (!isValid) return;

                                  FocusManager.instance.primaryFocus?.unfocus();
                                  await SystemChannels.textInput.invokeMethod(
                                    'TextInput.hide',
                                  );
                                  await Future.delayed(
                                    const Duration(milliseconds: 120),
                                  );

                                  if (!context.mounted) return;
                                  context.read<AuthBloc>().add(
                                    AuthLoginEvent(
                                      _usernameController.text.trim(),
                                      _passwordController.text,
                                      rememberMe: _rememberMe,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          11.hS,
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: Colors.grey,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  l10n.orText,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                              const Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          11.hS,
                          OutlinedButton.icon(
                            onPressed: () {
                              // TODO: đăng nhập với Google
                            },
                            icon: Image.asset(
                              'assets/images/google.png',
                              height: 24,
                              width: 24,
                            ),
                            label: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                l10n.loginWithGoogle,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      28.hS,
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${l10n.noAccountQuestion} ',
                              style: const TextStyle(color: Colors.black54),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  context.push(AppRoutes.register.path),
                              child: Text(
                                l10n.register,
                                style: const TextStyle(
                                  color: Color(0xFF3797EF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
