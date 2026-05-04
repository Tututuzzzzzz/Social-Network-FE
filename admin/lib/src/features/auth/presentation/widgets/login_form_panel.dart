import 'package:flutter/material.dart';

class LoginFormPanel extends StatelessWidget {
  final Widget form;

  const LoginFormPanel({super.key, required this.form});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE6E0D5)),
      ),
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
