import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:nutri_guide/feature/Home/view/home.dart';
import 'package:nutri_guide/feature/auth/view/forget_password.dart';
import 'package:nutri_guide/feature/auth/view/login.dart';
import 'package:nutri_guide/feature/auth/view/signup.dart';
import '../../doctorApp/feature/home/view/doctor_home.dart';
import '../../doctorApp/feature/home/view/patient_details_view.dart';
import '../../feature/auth/middleware/GateMiddleware.dart';
import '../../feature/auth/middleware/auth_middleware.dart';
import '../../feature/auth/view/gate_page.dart';
import '../../feature/bmi/view/bmi_page.dart';
import '../../feature/chat/view/chat_page.dart';
import '../../feature/chat/view/patient_profile_page.dart';
import '../../feature/doctor/view/doctor_details_page.dart';
import '../../feature/doctor/view/doctors_page.dart';
import '../../feature/splash/view/splash.dart';
import '../../feature/forum/view/forum_posts_page.dart';
import '../../feature/forum/view/forums_page.dart';
import '../../feature/tips/view/tips_page.dart';
import '../../feature/consultations/view/consultations_page.dart';
import '../../feature/diet/view/diet_page.dart';
import '../../feature/diet/view/diet_meals_page.dart';
import '../../feature/diet/view/create_diet_for_patient_page.dart';
import 'app_route.dart';
import 'binding.dart';

abstract class AppPages {
  static final pages = [
    // Splash: no middleware here. Splash should only route to /gate
    GetPage(
      name: AppRoute.splash,
      page: () => const SplashScreen(),
      bindings: [InitBinding()],
    ),

    // Guest pages: prevent opening when logged in (will redirect to home/doctorHome)
    GetPage(
      name: AppRoute.login,
      page: () => const Login(),
      binding: LoginBinding(),
      middlewares: [GuestMiddleware()],
    ),
    GetPage(
      name: AppRoute.signUp,
      page: () => const Signup(),
      binding: SignupBinding(),
      middlewares: [GuestMiddleware()],
    ),
    GetPage(
      name: AppRoute.forgotPassword,
      page: () => const ForgotPasswordPage(),
      bindings: [ForgotBinding()],
      middlewares: [GuestMiddleware()],
    ),

    // Gate: decides where to go (login / home / doctorHome)
    GetPage(
      name: AppRoute.gate,
      page: () => const GatePage(),
      middlewares: [GateMiddleware()], // ✅ NEW
    ),

    // Protected pages
    GetPage(
      name: AppRoute.home,
      page: () => const HomePage(),
      bindings: [HomeBinding()],
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: "/tips",
      page: () => const TipsPage(),
      binding: TipsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: "/doctors",
      page: () => const DoctorsPage(),
      binding: DoctorsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: "/bmi",
      page: () => const BmiPage(),
      binding: BmiBinding(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: "/doctor-details",
      page: () => const DoctorDetailsPage(),
      binding: DoctorDetailsBinding(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: AppRoute.doctorHome,
      page: () => const DoctorPatientsPage(),
      middlewares: [DoctorOnlyMiddleware()], // Only doctors can access
      bindings: [HomeDoctorBinding()]
    ),
    GetPage(
      name: AppRoute.chat,
      page: () => const ChatPage(),
      binding: ChatBinding(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: "/patient-details",
      page: () => const PatientDetailsPage(),
      binding: PatientDetailsBinding(),
      middlewares: [DoctorOnlyMiddleware()], // Only doctors can view patient details
    ),

    GetPage(
      name: AppRoute.patientProfile,
      page: () => const PatientProfilePage(),
      binding: PatientProfileBinding(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: AppRoute.forums,
      page: () => const ForumsPage(),
      binding: ForumsBinding(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: AppRoute.forumPosts,
      page: () => const ForumPostsPage(),
      binding: ForumPostsBinding(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: AppRoute.consultations,
      page: () => const ConsultationsPage(),
      binding: ConsultationsBinding(),
      middlewares: [AuthMiddleware()], // Patients and doctors can access
    ),

    GetPage(
      name: AppRoute.diet,
      page: () => const DietPage(),
      binding: DietBinding(),
      middlewares: [AuthMiddleware()], // Patients can view, doctors can create
    ),

    GetPage(
      name: AppRoute.dietMeals,
      page: () => const DietMealsPage(),
      binding: DietBinding(),
      middlewares: [PatientOnlyMiddleware()], // Only patients can view their meals
    ),

    GetPage(
      name: AppRoute.createDietForPatient,
      page: () => const CreateDietForPatientPage(),
      binding: DietBinding(),
      middlewares: [DoctorOnlyMiddleware()],
    ),

  ];
}