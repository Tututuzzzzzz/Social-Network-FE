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
import 'package:frontend/src/core/testing/test_keys.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth_login_form/auth_login_form_bloc.dart';
import '../widgets/auth_theme.dart';

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
            final authColors = AuthTheme.colorsOf(context);

            return Scaffold(
              backgroundColor: authColors.authBackground,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: AuthTheme.backButton(
                  context,
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
                        AuthTheme.logoAssetOf(context),
                        height: 104,
                        width: 187,
                      ),
                      32.hS,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            key: TestKeys.loginUsernameField,
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
                            ).copyWith(
                              hintStyle: TextStyle(
                                color: authColors.authInputHint,
                              ),
                              filled: true,
                              fillColor: authColors.authInputFill,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  color: authColors.authInputBorder,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  color: authColors.authInputBorder,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  color: authColors.authPrimaryAction,
                                  width: 1.4,
                                ),
                              ),
                            ),
                            style: TextStyle(color: authColors.authInputText),
                          ),
                          12.hS,
                          TextField(
                            key: TestKeys.loginPasswordField,
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onChanged: (value) {
                              context.read<AuthLoginFormBloc>().add(
                                LoginFormPasswordChangedEvent(value),
                              );
                            },
                            decoration: AuthTheme.inputDecoration(
                              context,
                              l10n.loginPasswordHint,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: authColors.authIcon,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                            style: TextStyle(color: authColors.authInputText),
                          ),
                          4.hS,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    key: TestKeys.loginRememberCheckbox,
                                    value: _rememberMe,
                                    onChanged: (v) => setState(
                                      () => _rememberMe = v ?? false,
                                    ),
                                  ),
                                  Text(
                                    l10n.rememberPassword,
                                    style: TextStyle(
                                      color: authColors.authBody,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () =>
                                    context.push(AppRoutes.forgotPassword.path),
                                child: Text(
                                  l10n.forgotPassword,
                                  style: AuthTheme.linkStyle(context),
                                ),
                              ),
                            ],
                          ),
                          36.hS,
                          BlocBuilder<AuthLoginFormBloc, LoginFormState>(
                            builder: (context, formState) {
                              final isValid = formState.isValid;
                              return CustomButton(
                                key: TestKeys.loginSubmitButton,
                                label: l10n.login,
                                color: isValid
                                    ? authColors.authPrimaryAction
                                    : authColors.authDisabledAction,
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
                              Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: authColors.authDivider,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  l10n.orText,
                                  style: TextStyle(
                                    color: authColors.authBody,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: authColors.authDivider,
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
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: authColors.authTitle,
                                ),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: authColors.authGoogleBorder,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor: authColors.authGoogleButton,
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
                              style: TextStyle(color: authColors.authBody),
                            ),
                            GestureDetector(
                              key: TestKeys.loginRegisterLink,
                              onTap: () =>
                                  context.push(AppRoutes.register.path),
                              child: Text(
                                l10n.register,
                                style: AuthTheme.linkStyle(context),
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
