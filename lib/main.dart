
import 'package:coinCrypto/bloc/coins_bloc.dart';
import 'package:coinCrypto/repo/coins_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/local/splash_controller.dart';
import 'view/screens/splash_screen.dart';
import 'utils/app_colors.dart';
import 'utils/theme_notifier.dart';

final GlobalKey<NavigatorState> navigatorKey =
GlobalKey<NavigatorState>();

late final AppLifecycleController appLifecycleController;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  appLifecycleController = AppLifecycleController(navigatorKey);
  appLifecycleController.start();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => CoinBloc(CoinRepository()))],
      child: AnimatedBuilder(
        animation: themeNotifier,
        builder: (context, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            themeMode: themeNotifier.themeMode,
            theme: ThemeData(
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: ColorResource.appThemeColor1,
                primary: ColorResource.appThemeColor1,
                secondary: ColorResource.appThemeColor2,
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: const Color(0xFFF4F4F8),
              cardColor: Colors.white,
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: const ColorScheme.dark(
                primary: ColorResource.appThemeColor1,
                secondary: ColorResource.appThemeColor2,
                surface: Color(0xFF121212),
              ),
              scaffoldBackgroundColor: const Color(0xFF000000),
              cardColor: const Color(0xFF16161A),
              dividerColor: const Color(0xFF27272A),
              useMaterial3: true,
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
