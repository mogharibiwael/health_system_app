
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {


  RxBool isLoading = true.obs;


  // Observables for UI updates
  RxString imageUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> fetchSplashData() async {

  }



}
