import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:frontend/src/core/l10n/l10n.dart';
import 'package:frontend/src/configs/injector/injector_conf.dart';
import 'package:frontend/src/core/cache/secure_local_storage.dart';
import 'package:frontend/src/routes/app_route_path.dart';
import 'package:frontend/src/widgets/custom_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    _restoreRememberedSession();
  }

  Future<void> _restoreRememberedSession() async {
    final storage = getIt<SecureLocalStorage>();
    final rememberMe =
        (await storage.load(key: 'remember_me')).trim() == 'true';

    if (rememberMe) {
      final accessToken = (await storage.load(key: 'access_token')).trim();
      final refreshToken = (await storage.load(key: 'refresh_token')).trim();

      if (!mounted) {
        return;
      }

      if (accessToken.isNotEmpty || refreshToken.isNotEmpty) {
        context.go(AppRoutes.home.path);
        return;
      }
    }

    if (mounted) {
      setState(() => _checkingSession = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (_checkingSession) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Image.asset('assets/images/logo.jpg', height: 120, width: 220),

                // Two lines of description under the logo
                Text(
                  l10n.welcomeTaglineConnect,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                6.hS,

                Text(
                  l10n.welcomeTaglineRelationship,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                40.hS,

                // Buttons
                CustomButton(
                  label: l10n.login,
                  onPressed: () => context.push(AppRoutes.login.path),
                ),

                12.hS,

                CustomButton(
                  label: l10n.register,
                  onPressed: () => context.push(AppRoutes.register.path),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
