import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../configs/injector/injector.dart';
import '../features/admin/presentation/bloc/dashboard/admin_dashboard_cubit.dart';
import '../features/auth/presentation/bloc/auth/admin_auth_cubit.dart';
import '../features/auth/presentation/bloc/auth/admin_auth_state.dart';
import 'app_route_path.dart';
import 'routes.dart';

GoRouter createAdminRouter(AdminAuthCubit authCubit) {
  return GoRouter(
    initialLocation: AppRoutePath.admin.path,
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final status = authCubit.state.status;
      final location = state.uri.path;
      final isLogin = location == AppRoutePath.login.path;

      if (status == AdminAuthStatus.checking) {
        return null;
      }

      if (!authCubit.state.isAuthenticated && !isLogin) {
        return AppRoutePath.login.path;
      }

      if (authCubit.state.isAuthenticated && isLogin) {
        return AppRoutePath.admin.path;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutePath.login.path,
        name: AppRoutePath.login.name,
        builder: (context, state) => const AdminLoginPage(),
      ),
      GoRoute(
        path: AppRoutePath.admin.path,
        name: AppRoutePath.admin.name,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => injector<AdminDashboardCubit>()..load(),
            child: const AdminShellPage(),
          );
        },
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
