import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:frontend/src/core/l10n/l10n.dart';
import 'package:frontend/src/routes/app_route_path.dart';
import 'package:frontend/src/widgets/custom_button.dart';

import '../widgets/auth_theme.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validateInput);
    _confirmController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _validateInput() {
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    final isValid = password.isNotEmpty && 
                    password.length >= 6 && 
                    password == confirm;
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

    return Scaffold(
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
                l10n.createNewPasswordTitle,
                style: AuthTheme.titleStyle(context),
                textAlign: TextAlign.center,
              ),
              16.hS,
              Text(
                l10n.createNewPasswordDescription,
                style: AuthTheme.bodyStyle(context),
                textAlign: TextAlign.center,
              ),
              32.hS,
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: AuthTheme.inputDecoration(
                  context,
                  l10n.loginPasswordHint,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: authColors.authIcon,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                style: TextStyle(color: authColors.authInputText),
              ),
              12.hS,
              TextField(
                controller: _confirmController,
                obscureText: _obscureConfirmPassword,
                decoration: AuthTheme.inputDecoration(
                  context,
                  l10n.confirmPasswordHint,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: authColors.authIcon,
                    ),
                    onPressed: () => setState(
                        () => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                style: TextStyle(color: authColors.authInputText),
              ),
              24.hS,
              CustomButton(
                label: l10n.done,
                color: _isValid
                    ? authColors.authPrimaryAction
                    : authColors.authDisabledAction,
                onPressed: () {
                  if (_isValid) {
                    context.go(AppRoutes.login.path);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
