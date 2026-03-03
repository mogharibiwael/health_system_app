import 'package:get/get.dart';
import 'package:nutri_guide/core/class/crud.dart';
import 'package:nutri_guide/doctorApp/feature/home/controller/doctor_patients_controller.dart';
import 'package:nutri_guide/feature/auth/controller/forget_password_controller.dart';
import 'package:nutri_guide/feature/auth/controller/verify_email_controller.dart';
import 'package:nutri_guide/feature/auth/controller/login_controller.dart';
import 'package:nutri_guide/feature/auth/controller/signup_controller.dart';
import 'package:nutri_guide/feature/chat/controller/patient_profile_controller.dart';
import 'package:nutri_guide/feature/splash/controller/controller.dart';

import '../../doctorApp/feature/home/controller/home_doctor_controller.dart';
import '../../doctorApp/feature/home/controller/patient_details_controller.dart';
import '../../feature/bmi/controller/bmi_controller.dart';
import '../../feature/chat/controller/chat_controller.dart';
import '../../feature/doctor/controller/doctor_details_controller.dart';
import '../../feature/doctor/controller/doctors_controller.dart';
import '../../feature/home/controller/home_controller.dart';
import '../../feature/forum/controller/forum_posts_controller.dart';
import '../../feature/forum/controller/forums_controller.dart';
import '../../feature/tips/controller/tips_controller.dart';
import '../../feature/tips/controller/tips_main_controller.dart';
import '../../feature/athkar/controller/spiritual_nutrition_controller.dart';
import '../../feature/athkar/controller/athkar_list_controller.dart';
import '../../feature/settings/controller/settings_controller.dart';
import '../../feature/settings/controller/edit_profile_controller.dart';
import '../../feature/settings/controller/reminders_controller.dart';
import '../../feature/consultations/controller/consultations_controller.dart';
import '../../feature/diet/controller/diet_controller.dart';
import '../../feature/step_counter/controller/step_counter_controller.dart';

class InitBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(Crud());
    Get.put( SplashController());
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
class VerifyEmailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VerifyEmailController());
  }
}
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut( () => HomeController(), fenix: true);
  }
}
class HomeDoctorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut( () => DoctorHomeController(), fenix: true);
    Get.lazyPut( () => DoctorPatientsController(), fenix: true);
  }
}

class TipsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TipsController(), fenix: true);
  }
}

class TipsMainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TipsMainController(), fenix: true);
  }
}

class SpiritualNutritionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SpiritualNutritionController());
  }
}

class AthkarListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AthkarListController(), fenix: true);
  }
}

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingsController());
  }
}

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EditProfileController());
  }
}

class RemindersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RemindersController());
  }
}

class DoctorsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DoctorsController(), fenix: true);
  }
}


class BmiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BmiController());
  }
}




class DoctorDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DoctorDetailsController(), fenix: true);
  }
}

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatController(), fenix: true);
  }
}


class PatientDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PatientDetailsController());
  }
}
class PatientProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PatientProfileController());
  }
}

class ForumsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ForumsController(), fenix: true);
  }
}

class ForumPostsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ForumPostsController(), fenix: true);
  }
}

class ConsultationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ConsultationsController(), fenix: true);
  }
}

class DietBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DietController(), fenix: true);
  }
}

class StepCounterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StepCounterController());
  }
}



