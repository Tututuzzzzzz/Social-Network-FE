import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'configs/injector/injector.dart';
import 'core/api/session_expiration_notifier.dart';
import 'core/theme/admin_theme.dart';
import 'features/auth/presentation/bloc/auth/admin_auth_cubit.dart';
import 'routes/app_route_conf.dart';

class AdminApp extends StatefulWidget {
  const AdminApp({super.key});

  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  late final AdminAuthCubit _authCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authCubit = injector<AdminAuthCubit>()..bootstrap();
    _router = createAdminRouter(_authCubit);
  }

  @override
  void dispose() {
    _router.dispose();
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Mochi Admin',
        theme: AdminTheme.light,
        routerConfig: _router,
        builder: (context, child) {
          return _SessionExpiredDialogListener(
            authCubit: _authCubit,
            navigatorKey: _router.routerDelegate.navigatorKey,
            notifier: injector<SessionExpirationNotifier>(),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

class _SessionExpiredDialogListener extends StatefulWidget {
  final AdminAuthCubit authCubit;
  final GlobalKey<NavigatorState> navigatorKey;
  final SessionExpirationNotifier notifier;
  final Widget child;

  const _SessionExpiredDialogListener({
    required this.authCubit,
    required this.navigatorKey,
    required this.notifier,
    required this.child,
  });

  @override
  State<_SessionExpiredDialogListener> createState() =>
      _SessionExpiredDialogListenerState();
}

class _SessionExpiredDialogListenerState
    extends State<_SessionExpiredDialogListener> {
  late StreamSubscription<void> _subscription;
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    _subscription = widget.notifier.stream.listen((_) {
      _showSessionExpiredDialog();
    });
  }

  @override
  void didUpdateWidget(_SessionExpiredDialogListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifier == widget.notifier) {
      return;
    }

    _subscription.cancel();
    _subscription = widget.notifier.stream.listen((_) {
      _showSessionExpiredDialog();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _showSessionExpiredDialog() async {
    if (!mounted || _dialogOpen) {
      return;
    }

    _dialogOpen = true;
    final navigatorContext = widget.navigatorKey.currentContext;
    if (navigatorContext == null) {
      widget.notifier.reset();
      _dialogOpen = false;
      return;
    }

    await showDialog<void>(
      context: navigatorContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Phi\u00EAn \u0111\u0103ng nh\u1EADp \u0111\u00E3 h\u1EBFt h\u1EA1n',
          ),
          content: const Text(
            'Access token \u0111\u00E3 h\u1EBFt h\u1EA1n. Vui l\u00F2ng \u0111\u0103ng nh\u1EADp l\u1EA1i \u0111\u1EC3 ti\u1EBFp t\u1EE5c.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('X\u00E1c nh\u1EADn'),
            ),
          ],
        );
      },
    );

    try {
      await widget.authCubit.logout();
    } finally {
      widget.notifier.reset();
      _dialogOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
