import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'configs/injector/injector.dart';
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
      ),
    );
  }
}
