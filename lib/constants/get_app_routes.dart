import 'package:e_commerce/auth/admin_setup_screen.dart';
import 'package:e_commerce/auth/login_screen.dart';
import 'package:e_commerce/constants/app_routes.dart';
import 'package:e_commerce/splash_screen.dart';
import 'package:e_commerce/testing/test_data_screen.dart';
import 'package:e_commerce/views/customer/home_page.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

class GetAppRoutes {
  GetAppRoutes._();
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => SplashScreen(),
      middlewares: [],
    ),
    GetPage(name: AppRoutes.adminSetup, page: () => AdminSetupScreen()),
    GetPage(name: AppRoutes.login, page: () => LoginScreen(), middlewares: []),
    GetPage(name: AppRoutes.home, page: () => HomePage(), middlewares: []),
    GetPage(name: AppRoutes.testData, page: () => TestDataScreen()),
  ];
}
