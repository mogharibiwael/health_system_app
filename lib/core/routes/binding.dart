import 'package:get/get.dart';
import 'package:nutri_guide/core/class/crud.dart';
import 'package:nutri_guide/feature/auth/controller/forget_password_controller.dart';
import 'package:nutri_guide/feature/auth/controller/login_controller.dart';
import 'package:nutri_guide/feature/auth/controller/signup_controller.dart';
import 'package:nutri_guide/feature/splash/controller/controller.dart';

class InitBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(Crud());
    Get.lazyPut(() => SplashController());
  }
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
  }
}

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SignupController());
  }
}
class ForgotBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ForgotPasswordController());
  }
}
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeBinding());
  }
}
