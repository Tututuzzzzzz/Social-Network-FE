import 'package:flutter/material.dart';

import 'login_brand_panel.dart';
import 'login_form_panel.dart';

class LoginStagePanel extends StatelessWidget {
  final bool wide;
  final Widget form;

  const LoginStagePanel({super.key, required this.wide, required this.form});

  @override
  Widget build(BuildContext context) {
    final formPanel = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: LoginFormPanel(form: form),
    );

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: wide ? 560 : 0),
      padding: EdgeInsets.all(wide ? 34 : 22),
      decoration: BoxDecoration(
        color: const Color(0xFFDDEFE8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC2DBD0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF17211D).withValues(alpha: .08),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(flex: 1, child: LoginBrandPanel()),
                const SizedBox(width: 40),
                Expanded(
                  flex: 1,
                  child: Align(alignment: Alignment.center, child: formPanel),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const LoginBrandPanel(compact: true),
                const SizedBox(height: 22),
                formPanel,
              ],
            ),
    );
  }
}
