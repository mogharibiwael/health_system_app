import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutri_guide/core/routes/app_route.dart';

import '../../../core/constant/asset.dart';
import '../controller/controller.dart';

class SplashScreen extends GetView<SplashController> {
  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 5), () => Get.toNamed(AppRoute.login));
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(ImageAssets.logo,height: 200,),
            SizedBox(width: 10),
            SizedBox(width: 36, height: 36, child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
