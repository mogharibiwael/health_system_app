import 'package:get/get.dart';
import 'package:nutri_guide/feature/Home/view/home.dart';
import 'package:nutri_guide/feature/auth/view/forget_password.dart';
import 'package:nutri_guide/feature/auth/view/login.dart';
import 'package:nutri_guide/feature/auth/view/signup.dart';

import '../../feature/splash/view/splash.dart';
import 'app_route.dart';
import 'binding.dart';

abstract class AppPages {
  static final pages = [
    GetPage(
      name: AppRoute.splash,
      page: () => SplashScreen(),
      // bindings: [SignupBinding()]
    ),

    GetPage(name: AppRoute.login, page: () => Login(), binding: LoginBinding()),
    GetPage(
      name: AppRoute.signUp,
      page: () => Signup(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: AppRoute.forgotPassword,
      page: () => ForgotPasswordPage(),
      bindings: [ForgotBinding()]
    ),
    GetPage(
      name: AppRoute.home,
      page: () => HomePage(),
      bindings: [HomeBinding()]
    ),
  ];
}
