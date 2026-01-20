import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutri_guide/core/class/status_request.dart';
import 'package:nutri_guide/core/function/handel_data.dart';
import 'package:nutri_guide/core/function/show_dialog.dart';
import 'package:nutri_guide/core/routes/app_route.dart';
import '../../../core/helper/extract_massege.dart';
import '../data/register_data.dart';

class SignupController extends GetxController {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  final SignupData signupData = SignupData(Get.find());

  StatusRequest statusRequest = StatusRequest.success;

  // Optional fields (backend accepts nullable)
  String selectedType = "user";     // default in backend is 'user'
  String? selectedRole="patient";             // null means not sending role

  // You can change these lists based on what you allow in UI
  // final List<String> typeItems = const ["user", "payed"];
  final List<String> roleItems = const ["patient", "doctor"];

  goToLogin() => Get.toNamed(AppRoute.login);

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final pass = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    print("pass");
    print(pass);
    print(confirm);
    print("confirm");

    // Required validations (match backend required)
    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      showAwesomeDialog(
        type: DialogType.warning,
        title: "Validation",
        desc: "Name, Email, and Password are required",
      );
      return;
    }

    if (pass.length < 8) {
      showAwesomeDialog(
        type: DialogType.warning,
        title: "Validation",
        desc: "Password must be at least 8 characters",
      );
      return;
    }

    // Client-side confirm
    if (confirm.isEmpty || pass != confirm) {
      showAwesomeDialog(
        type: DialogType.warning,
        title: "Validation",
        desc: "Confirm password does not match",
      );
      return;
    }



    statusRequest = StatusRequest.loading;
    update();

    final res = await signupData.register(
      name: name,
      email: email,
      password: pass,
      phone: phone.isEmpty ? null : phone,
      type: selectedType,         // send always (or make it nullable if you want)
      role: selectedRole,
      passwordConfirmation: confirm,         // send only if not null
    );

    // If it returned StatusRequest => offline/server
    if (res is StatusRequest) {
      final msg = res == StatusRequest.offlineFailure
          ? "No internet connection"
          : "Server error";
      showAwesomeDialog(
        type: DialogType.error,
        title: "Register Failed",
        desc: msg,
      );
      statusRequest = StatusRequest.failure;
      update();
      return;
    }

    statusRequest = handelData(res);

    // Laravel validation errors
    if (res is Map && res["errors"] != null) {
      showAwesomeDialog(
        type: DialogType.error,
        title: "Register Failed",
        desc: extractLaravelError(res),
      );
      statusRequest = StatusRequest.failure;
      update();
      return;
    }

    if (statusRequest != StatusRequest.success) {
      showAwesomeDialog(
        type: DialogType.error,
        title: "Register Failed",
        desc: "Try again",
      );
      update();
      return;
    }

    showAwesomeDialog(
      type: DialogType.success,
      title: "Success",
      desc: "Account created successfully",
      dismissOnTouchOutside: false,
      onOk: () => Get.offAllNamed(AppRoute.login),
    );

    statusRequest = StatusRequest.success;
    update();
  }

  @override
  void onInit() {
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    super.onInit();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
