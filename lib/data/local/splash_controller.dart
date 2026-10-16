import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/coins_bloc.dart';
import '../../repo/coins_repo.dart';
import '../../view/screens/main_navigation_screen.dart';


class AppLifecycleController with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> navigatorKey;
  bool _wasInBackground = false;
  bool _isNavigating = false;

  AppLifecycleController(this.navigatorKey);

  void start() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      _wasInBackground = true;
    }

    if (state == AppLifecycleState.resumed && _wasInBackground) {
      _wasInBackground = false;
      _navigateToCoinList();
    }
  }

  void _navigateToCoinList() {
    if (_isNavigating) return;

    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    _isNavigating = true;

    navigator
        .pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => CoinBloc(CoinRepository()),
          child: const MainNavigationScreen(),
        ),
      ),
          (route) => false,
    )
        .whenComplete(() {
      _isNavigating = false;
    });
  }
}