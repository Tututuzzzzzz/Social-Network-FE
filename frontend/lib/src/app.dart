import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/api/api_interceptor.dart';
import 'configs/injector/injector_conf.dart';
import 'features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';

import 'l10n/generated/app_localizations.dart';
import 'routes/app_route_conf.dart';
import 'routes/app_route_path.dart';

class App extends StatelessWidget {
  App({super.key});

  final AppRoutesConf _appRoutesConf = AppRoutesConf();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MultiBlocProvider(
        providers: [BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>()),
        BlocProvider<NotificationBloc>(create: (_) => getIt<NotificationBloc>()),],
        child: ValueListenableBuilder<bool>(
          valueListenable: forceLogoutNotifier,
          builder: (context, forceLogout, _) {
            if (forceLogout) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _appRoutesConf.router.go(AppRoutes.login.path);
                forceLogoutNotifier.value = false;
              });
            }

            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Social Network',
              routerConfig: _appRoutesConf.router,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
            );
          },
        ),
      ),
    );
  }
}
