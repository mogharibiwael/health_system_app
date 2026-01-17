import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutri_guide/core/class/status_request.dart';
import 'package:nutri_guide/core/function/handel_data.dart';
import 'package:nutri_guide/core/routes/app_route.dart';
import 'package:nutri_guide/feature/auth/data/login_data.dart';
import '../../../core/function/show_dialog.dart';
import '../../../core/service/serviecs.dart';

class LoginController extends GetxController {

  late TextEditingController emailController;
  late TextEditingController passwordController;

  final LoginData loginData = LoginData(Get.find());
  final MyServices myServices = Get.find();

  StatusRequest statusRequest = StatusRequest.loading;

  Future<void> login() async {
    // ✅ Validate fields first
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      showAwesomeDialog(
        type: DialogType.warning,
        title: "Validation",
        desc: "Please enter email and password",
      );
      return;
    }

    statusRequest = StatusRequest.loading;
    update();

    final response = await loginData.getData(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    statusRequest = handelData(response);

    response.fold(
          (l) {
        // l is StatusRequest in your Either
        statusRequest = l;

        // ✅ Offline / Server / Generic
        String msg = "Invalid email or password";
        if (l == StatusRequest.offlineFailure) {
          msg = "No internet connection";
        } else if (l == StatusRequest.serverFailure) {
          msg = "Server error, try again later";
        } else if (l == StatusRequest.failure) {
          msg = "Invalid email or password";
        }

        showAwesomeDialog(
          type: DialogType.error,
          title: "Login Failed",
          desc: msg,
        );

        update();
      },
          (r) async {
        try {
          // ✅ Token
          final token = r['token'] ?? r['access_token'];
          if (token == null || token.toString().isEmpty) {
            showAwesomeDialog(
              type: DialogType.error,
              title: "Login Failed",
              desc: "Token not returned from server",
            );
            statusRequest = StatusRequest.failure;
            update();
            return;
          }

          await myServices.sharedPreferences.setString("token", token.toString());

          // ✅ User (optional)
          if (r['user'] != null) {
            await myServices.sharedPreferences.setString(
              "user",
              jsonEncode(r['user']),
            );
          }

          statusRequest = StatusRequest.success;
          update();

          // ✅ Success dialog then navigate
          showAwesomeDialog(
            type: DialogType.success,
            title: "Success",
            desc: "Login successful",
            dismissOnTouchOutside: false,
            onOk: () {
              Get.offAllNamed(AppRoute.home);
            },
          );
        } catch (_) {
          showAwesomeDialog(
            type: DialogType.error,
            title: "Error",
            desc: "Something went wrong while saving session",
          );
          statusRequest = StatusRequest.failure;
          update();
        }
      },
    );
  }

  goToSignup(){
    Get.toNamed(AppRoute.signUp);
  }

  @override
  void onInit() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.onInit();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
