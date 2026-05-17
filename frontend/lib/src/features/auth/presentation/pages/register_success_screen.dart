import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/src/routes/app_route_path.dart';
import 'package:frontend/src/widgets/custom_button.dart';
import 'package:frontend/src/core/testing/test_keys.dart';

import '../widgets/auth_theme.dart';

class RegisterSuccessScreen extends StatelessWidget {
  const RegisterSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AuthTheme.colorsOf(context);

    return Scaffold(
      body: Stack(
        children: [
          // Hình nền
          Positioned.fill(
            child: Image.asset(
              'assets/images/register_success.png',
              fit: BoxFit.cover,
            ),
          ),
          // Nút bắt đầu ở dưới cùng
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 40.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    key: TestKeys.registerSuccessStartButton,
                    label: 'Bắt đầu',
                    color: colors.authPrimaryAction,
                    onPressed: () {
                      context.go(AppRoutes.login.path);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
