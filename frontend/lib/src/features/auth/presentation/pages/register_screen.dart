import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/src/configs/injector/injector_conf.dart';
import 'package:frontend/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:frontend/src/core/l10n/l10n.dart';
import 'package:frontend/src/routes/app_route_path.dart';
import 'package:frontend/src/widgets/custom_button.dart';
import 'package:frontend/src/widgets/snackbar_widget.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth_register_form/auth_register_form_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFF5F5F5),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthRegisterFormBloc>(
      create: (_) => getIt<AuthRegisterFormBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          final l10n = context.l10n;

          if (state is AuthRegisterSuccessState) {
            appSnackBar(context, Colors.green, l10n.registerSuccess);

            _firstNameController.clear();
            _lastNameController.clear();
            _usernameController.clear();
            _emailController.clear();
            _passwordController.clear();
            _confirmController.clear();

            context.go(AppRoutes.login.path);
          }

          if (state is AuthRegisterFailureState) {
            appSnackBar(
              context,
              Colors.red,
              state.message.isEmpty ? l10n.registerFailed : state.message,
            );
          }
        },
        child: Builder(
          builder: (context) {
            final l10n = context.l10n;

            return Scaffold(
              backgroundColor: Colors.white,
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
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      8.hS,
                      Image.asset(
                        'assets/images/logo.jpg',
                        height: 120,
                        width: 220,
                      ),
                      18.hS,
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _firstNameController,
                              decoration: _inputDecoration(l10n.firstNameHint),
                            ),
                          ),
                          10.wS,
                          Expanded(
                            child: TextField(
                              controller: _lastNameController,
                              decoration: _inputDecoration(l10n.lastNameHint),
                            ),
                          ),
                        ],
                      ),
                      10.hS,
                      TextField(
                        controller: _usernameController,
                        onChanged: (value) {
                          context.read<AuthRegisterFormBloc>().add(
                            RegisterFormUsernameChangedEvent(value.trim()),
                          );
                        },
                        decoration: _inputDecoration(l10n.usernameHint),
                      ),
                      10.hS,
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          context.read<AuthRegisterFormBloc>().add(
                            RegisterFormEmailChangedEvent(value.trim()),
                          );
                        },
                        decoration: _inputDecoration(l10n.enterEmailHint),
                      ),
                      10.hS,
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        onChanged: (value) {
                          context.read<AuthRegisterFormBloc>().add(
                            RegisterFormPasswordChangedEvent(value),
                          );
                        },
                        decoration: _inputDecoration(l10n.loginPasswordHint)
                            .copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                color: Colors.black,
                              ),
                            ),
                      ),
                      10.hS,
                      TextField(
                        controller: _confirmController,
                        obscureText: _obscurePassword,
                        onChanged: (value) {
                          context.read<AuthRegisterFormBloc>().add(
                            RegisterFormConfirmPasswordChangedEvent(value),
                          );
                        },
                        decoration: _inputDecoration(l10n.reenterPasswordHint)
                            .copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                color: Colors.black,
                              ),
                            ),
                      ),
                      18.hS,
                      BlocBuilder<AuthRegisterFormBloc, RegisterFormState>(
                        builder: (context, formState) {
                          final isValid =
                              formState.isValid &&
                              _firstNameController.text.trim().isNotEmpty &&
                              _lastNameController.text.trim().isNotEmpty;

                          return CustomButton(
                            label: l10n.register,
                            color: isValid
                                ? const Color(0xFF83C2FB)
                                : Colors.grey.shade400,
                            onPressed: () {
                              if (!isValid) {
                                appSnackBar(
                                  context,
                                  Colors.red,
                                  l10n.registerFailed,
                                );
                                return;
                              }

                              context.read<AuthBloc>().add(
                                AuthRegisterEvent(
                                  _firstNameController.text.trim(),
                                  _lastNameController.text.trim(),
                                  _usernameController.text.trim(),
                                  _emailController.text.trim(),
                                  _passwordController.text,
                                  _confirmController.text,
                                ),
                              );
                            },
                          );
                        },
                      ),
                      12.hS,
                      Center(
                        child: Text(
                          l10n.orText,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      12.hS,
                      OutlinedButton.icon(
                        onPressed: () {},
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
                      18.hS,
                      Center(
                        child: GestureDetector(
                          onTap: () => context.push(AppRoutes.login.path),
                          child: RichText(
                            text: TextSpan(
                              text: '${l10n.haveAccountQuestion} ',
                              style: const TextStyle(color: Colors.black54),
                              children: [
                                TextSpan(
                                  text: l10n.login,
                                  style: const TextStyle(
                                    color: Color(0xFF3797EF),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      20.hS,
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
