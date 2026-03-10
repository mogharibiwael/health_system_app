import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutri_guide/core/class/crud.dart';
import 'package:nutri_guide/core/class/status_request.dart';
import 'package:nutri_guide/core/function/handel_data.dart';
import 'package:nutri_guide/core/routes/app_route.dart';
import 'package:nutri_guide/feature/auth/data/login_data.dart';
import 'package:nutri_guide/feature/doctor/data/subscription_data.dart';
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
          title: "login_failed".tr,
          desc: msg,
        );

        update();
      },
          (r) async {

        try {
          // Handle error responses (message but no token)
          if (r is Map && !r.containsKey("token") && !r.containsKey("access_token")) {
            if (r.containsKey("message")) {
              statusRequest = StatusRequest.failure;
              update();
              showAwesomeDialog(
                type: DialogType.error,
                title: "login_failed".tr,
                desc: r["message"].toString(),
              );
              return;
            }
          }

          final token = r['token'] ?? r['access_token'];
          if (token == null || token.toString().trim().isEmpty) {
            statusRequest = StatusRequest.failure;
            update();
            showAwesomeDialog(
              type: DialogType.error,
              title: "login_failed".tr,
              desc: "Token not returned from server",
            );
            return;
          }

          final userMap = (r['user'] is Map)
              ? Map<String, dynamic>.from(r['user'])
              : <String, dynamic>{};

          // Infer type: explicit "type" or "doctor" if user has doctor object
          String userType = (userMap['type'] ?? '').toString().trim().toLowerCase();
          if (userType.isEmpty && userMap['doctor'] != null) {
            userType = 'doctor';
          }
          if (userType.isEmpty) userType = 'user';

          await myServices.saveSession(
            token: token.toString(),
            type: userType, // store doctor/patient in "type"
            user: userMap.isEmpty ? null : userMap,
          );

          // Load subscriptions from backend for patients (so Chat shows for subscribed doctors after re-login)
          if (userType == "user" || userType == "patient" || userType == "payed") {
            _loadSubscriptionsFromBackend(token.toString());
          }

          statusRequest = StatusRequest.success;
          update();

          // ✅ Only go to gate. Middleware will redirect to correct page.
          Get.offAllNamed(AppRoute.gate);

        } catch (e) {
          statusRequest = StatusRequest.failure;
          update();
          showAwesomeDialog(
            type: DialogType.error,
            title: "Error",
            desc: "Something went wrong while saving session",
            dismissOnTouchOutside: false,
          );
        }
      }

      ,
    );
  }

  goToSignup() => Get.toNamed(AppRoute.signUp);
  goToForget() => Get.toNamed(AppRoute.forgotPassword);

  Future<void> _loadSubscriptionsFromBackend(String token) async {
    try {
      final subscriptionData = SubscriptionData(Get.find<Crud>());
      final res = await subscriptionData.getMySubscriptions(token: token);
      res.fold(
        (_) {},
        (r) {
          final raw = r["data"] ?? r["subscriptions"] ?? r;
          final list = raw is List ? raw : <dynamic>[];
          final doctorIds = <int>{};
          for (final e in list) {
            if (e is! Map) continue;
            final did = e["doctor_id"] ?? e["doctorId"];
            if (did != null) {
              final id = did is int ? did : int.tryParse(did.toString());
              if (id != null && id > 0) doctorIds.add(id);
            }
          }
          if (doctorIds.isNotEmpty) {
            myServices.setSubscribedDoctorIds(doctorIds);
          }
        },
      );
    } catch (_) {}
  }

  @override
  void onInit() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.onInit();
  }


}
