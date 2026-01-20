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

  StatusRequest statusRequest = StatusRequest.success; // start idle

  bool get isLoading => statusRequest == StatusRequest.loading;

  Future<void> login() async {
    if (isLoading) return; // prevent double tap

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
        statusRequest = l; // failure / offline / serverFailure
        String msg = "Invalid email or password";
        if (l == StatusRequest.offlineFailure) {
          msg = "No internet connection";
        } else if (l == StatusRequest.serverFailure) {
          msg = "Server error, try again later";
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
          final token = r['token'] ?? r['access_token'];
          if (token == null || token.toString().isEmpty) {
            statusRequest = StatusRequest.failure;
            update();
            showAwesomeDialog(
              type: DialogType.error,
              title: "Login Failed",
              desc: "Token not returned from server",
            );
            return;
          }

          await myServices.sharedPreferences
              .setString("token", token.toString());

          if (r['user'] != null) {
            await myServices.sharedPreferences.setString(
              "user",
              jsonEncode(r['user']),
            );
          }

          statusRequest = StatusRequest.success;
          update();

          showAwesomeDialog(
            type: DialogType.success,
            title: "Success",
            desc: "Login successful",
            dismissOnTouchOutside: false,
            onOk: () => Get.offAllNamed(AppRoute.home),
          );
        } catch (_) {
          statusRequest = StatusRequest.failure;
          update();
          showAwesomeDialog(
            type: DialogType.error,
            title: "Error",
            desc: "Something went wrong while saving session",
            dismissOnTouchOutside: false,
          );
        }
      },
    );
  }

  goToSignup() => Get.toNamed(AppRoute.signUp);
  goToForget() => Get.toNamed(AppRoute.forgotPassword);

  @override
  void onInit() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.onInit();
  }


}
