import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:frontend/src/core/l10n/l10n.dart';
import 'package:frontend/src/routes/app_route_path.dart';
import 'package:frontend/src/widgets/custom_button.dart';

import '../widgets/auth_theme.dart';

class VerificationCodeScreen extends StatefulWidget {
  final String email;
  const VerificationCodeScreen({super.key, required this.email});

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _validateInput() {
    final code = _codeController.text.trim();
    final isValid = code.length == 6; // Giả định mã 6 chữ số
    if (isValid != _isValid) {
      setState(() {
        _isValid = isValid;
      });
    }
  }

  String _maskEmail(String email) {
    if (email.isEmpty) return '';
    final parts = email.split('@');
    if (parts.length < 2) return email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return '***@$domain';
    return '${name.substring(0, 2)}***@$domain';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final maskedEmail = _maskEmail(widget.email);
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
                l10n.otpEnterCodeTitle,
                style: AuthTheme.titleStyle(context),
                textAlign: TextAlign.center,
              ),
              16.hS,
              Text(
                l10n.otpDescription(maskedEmail),
                style: AuthTheme.bodyStyle(context),
                textAlign: TextAlign.center,
              ),
              32.hS,
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  color: authColors.authInputText,
                ),
                decoration: AuthTheme.inputDecoration(
                  context,
                  '000000',
                  radius: 15,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ).copyWith(counterText: ''),
              ),
              24.hS,
              CustomButton(
                label: l10n.next,
                color: _isValid
                    ? authColors.authPrimaryAction
                    : authColors.authDisabledAction,
                onPressed: () {
                  if (_isValid) {
                    context.push(AppRoutes.resetPassword.path);
                  }
                },
              ),
              16.hS,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.didNotReceiveCode,
                    style: TextStyle(color: authColors.authBody),
                  ),
                  TextButton(
                    onPressed: () {
                      // Logic gửi lại mã
                    },
                    child: Text(
                      l10n.resendCode,
                      style: AuthTheme.linkStyle(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
