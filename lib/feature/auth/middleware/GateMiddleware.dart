import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_route.dart';
import '../../../core/service/serviecs.dart';

class GateMiddleware extends GetMiddleware {
  GateMiddleware({this.priority = 0});

  @override
  final int priority;

  final MyServices myServices = Get.find();

  @override
  RouteSettings? redirect(String? route) {
    // 1) لا يوجد جلسة -> شاشة الترحيب ثم تسجيل الدخول
    if (!myServices.isLoggedIn) {
      return RouteSettings(name: AppRoute.welcome);
    }

    // 2) يوجد جلسة -> حسب type
    final t = (myServices.type ?? "user").toString();
    return RouteSettings(
      name: t == "doctor" ? AppRoute.doctorWelcome : AppRoute.home,
    );
  }
}
