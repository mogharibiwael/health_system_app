import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/asset.dart';
import '../controller/controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Image.asset(
            ImageAssets.logo,
            height: 200,
            fit: BoxFit.contain,
          ),
        ),
      ),
    ));
  }
}
