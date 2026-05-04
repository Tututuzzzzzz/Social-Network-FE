import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/api/api_interceptor.dart';
import 'configs/injector/injector_conf.dart';
import 'features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'features/auth/presentation/bloc/language_bloc.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';

import 'l10n/generated/app_localizations.dart';
import 'routes/app_route_conf.dart';
import 'routes/app_route_path.dart';

class App extends StatelessWidget {
  App({super.key});

  final AppRoutesConf _appRoutesConf = AppRoutesConf();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>()),
        BlocProvider<NotificationBloc>(create: (_) => getIt<NotificationBloc>()),
        BlocProvider<LanguageBloc>(
          create: (_) => getIt<LanguageBloc>()..add(LanguageStarted()),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        child: ValueListenableBuilder<bool>(
          valueListenable: forceLogoutNotifier,
          builder: (context, forceLogout, _) {
            if (forceLogout) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _appRoutesConf.router.go(AppRoutes.login.path);
                forceLogoutNotifier.value = false;
              });
            }

            return BlocBuilder<LanguageBloc, LanguageState>(
              builder: (context, languageState) {
                return MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  title: 'Social Network',
                  routerConfig: _appRoutesConf.router,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  locale: languageState.locale,
                  localeResolutionCallback: (locale, supportedLocales) {
                    if (locale == null) return const Locale('en');
                    for (var supportedLocale in supportedLocales) {
                      if (supportedLocale.languageCode ==
                          locale.languageCode) {
                        return supportedLocale;
                      }
                    }
                    return const Locale('en');
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
