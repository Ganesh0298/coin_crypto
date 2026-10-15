// import 'package:coin_pilot/data/local/secure_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../../utils/app_routes.dart';
//
// class SplashController {
//   final FlutterSecureStorage storage = const FlutterSecureStorage();
//
//   SplashController();
//
//   void navigateToHome(BuildContext context) async {
//     try {
//       await Future.delayed(Duration(seconds: 2));
//
//       final storageService = await SecureStorageService.instance;
//
//       final String? token = await storageService.accessToken;
//       final String? userType = await storageService.userType;
//
//       if (!context.mounted) return;
//       if (token != null && token.isNotEmpty) {
//         if (userType == 'admin' || userType == 'employee') {
//
//           CustomNavigation.pushReplacement(
//             context,
//             MultiBlocProvider(
//               providers: [
//                 BlocProvider(
//                   create: (_) => AuthenticationBloc(AuthenticationRepo()),
//                 ),
//               ],
//               child: EmployeeDashboardScreen(),
//             ),
//           );
//           return;
//         }
//
//         if (userType == 'super_admin') {
//           CustomNavigation.pushReplacement(
//             context,
//             MultiBlocProvider(
//               providers: [
//                 BlocProvider(
//                   create: (_) => CompanyBloc(SuperAdminRepo()),
//                 ),
//                 BlocProvider(
//                   create: (_) => PlansPricingBloc(SuperAdminRepo()),
//                 ),
//               ],
//               child: SuperAdminDashboardScreen(),
//             ),
//           );
//           return;
//         }
//       }
//       _navigateToLogin(context);
//     } catch (e) {
//       if (context.mounted) {
//         _navigateToLogin(context);
//       }
//     }
//   }
//
//
//   void _navigateToLogin(BuildContext context) {
//     CustomNavigation.pushReplacement(
//       context,
//       MultiBlocProvider(
//         providers: [
//           BlocProvider(create: (_) => AuthenticationBloc(AuthenticationRepo())),
//         ],
//         child: const LoginScreen(),
//       ),
//     );
//   }
// }
