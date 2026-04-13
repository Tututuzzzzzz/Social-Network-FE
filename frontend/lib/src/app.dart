import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'configs/injector/injector_conf.dart';
import 'core/constants/list_translation_locale.dart';
import 'features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'features/post/presentation/bloc/post/post_bloc.dart';
import 'l10n/generated/app_localizations.dart';
import 'routes/app_route_conf.dart';

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
        providers: [
          BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>()),
          BlocProvider<PostBloc>(create: (_) => getIt<PostBloc>()),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Social Network',
          routerConfig: _appRoutesConf.router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [englishLocale, vietnameseLocale],
        ),
      ),
    );
  }
}
