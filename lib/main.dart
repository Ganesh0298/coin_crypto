import 'package:coin_pilot/bloc/coins_bloc.dart';
import 'package:coin_pilot/repo/coins_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'view/screens/main_navigation_screen.dart';
import 'utils/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return
    //   BlocProvider(
    //   create: (context) => CryptoCubit(CryptoApiService()),
    //   child: MaterialApp(
    //     title: 'CoinPilot Crypto Research',
    //     debugShowCheckedModeBanner: false,
    //     theme: ThemeData(
    //       colorScheme: ColorScheme.fromSeed(
    //         seedColor: ColorResource.appThemeColor1,
    //         primary: ColorResource.appThemeColor1,
    //         secondary: ColorResource.appThemeColor2,
    //       ),
    //       scaffoldBackgroundColor: ColorResource.appMainBgColor,
    //       useMaterial3: true,
    //     ),
    //     home: const MainNavigationScreen(),
    //   ),
    // );
    MultiBlocProvider(
      providers: [BlocProvider(create: (_) => CoinBloc(CoinRepository()))],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: ColorResource.appThemeColor1,
            primary: ColorResource.appThemeColor1,
            secondary: ColorResource.appThemeColor2,
          ),
          scaffoldBackgroundColor: ColorResource.appMainBgColor,
          useMaterial3: true,
        ),

        home: MainNavigationScreen(),
      ),
    );
  }
}
