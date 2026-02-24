import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/theme/colors.dart';
import '../controller/controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // تأكد أن البايندنج يحقن SplashController أو استخدم Get.put هنا إذا تحب
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  Icons.health_and_safety_outlined,
                  size: 56,
                  color: AppColor.primary,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                "Nutri Guide",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                "Loading...",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 22),

              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
