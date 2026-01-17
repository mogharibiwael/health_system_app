import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutri_guide/core/service/serviecs.dart';

class LocalController extends GetxController {
  Locale? language;
  MyServices myServices = Get.find();

  changeLang(String code) {
    Locale locale = Locale(code);
    myServices.sharedPreferences.setString("lang", code);
    Get.updateLocale(locale);
  }

  _loadSavedLanguage() async {
    String? sharedprefLang = myServices.sharedPreferences.getString("lang");
    switch (sharedprefLang) {
      case "ar":
        language = const Locale('ar', '');
        break;
      case "en":
        language = const Locale('en', '');
        break;
      default:
        language = Locale(Get.deviceLocale!.languageCode);
    }
  }

  @override
  void onInit() {
    _loadSavedLanguage();
    super.onInit();
  }
}
