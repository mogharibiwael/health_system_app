import 'dart:convert';
import 'package:get/get.dart';
import 'package:nutri_guide/core/service/serviecs.dart';

class HomeController extends GetxController {
  final MyServices myServices = Get.find();

  Map<String, dynamic>? user;

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  void loadUser() {
    final userStr = myServices.sharedPreferences.getString("user");
    if (userStr == null || userStr.isEmpty) {
      user = null;
      update();
      return;
    }
    try {
      user = jsonDecode(userStr) as Map<String, dynamic>;
    } catch (_) {
      user = null;
    }
    update();
  }

  String get userName => (user?["name"] ?? "Guest").toString();
  String get userEmail => (user?["email"] ?? "-").toString();
  String get userPhone => (user?["phone"] ?? "-").toString();
  String get userRole  => (user?["role"] ?? "-").toString();

  void goDoctors() => Get.toNamed("/doctors");
  void goTips() => Get.toNamed("/tips");
  void goBmi() => Get.toNamed("/bmi");

  void logout() async {
    await myServices.sharedPreferences.remove("token");
    await myServices.sharedPreferences.remove("user");
    Get.offAllNamed("/login");
  }
}
