import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutri_guide/core/constant/theme/colors.dart';
import 'package:nutri_guide/core/shared/widgets/app_bar.dart';
import 'package:nutri_guide/feature/step_counter/controller/step_counter_controller.dart';

class StepCounterPage extends GetView<StepCounterController> {
  const StepCounterPage({super.key});

  static const Color _lightLavender = Color(0xffe4e0ec);
  static const Color _darkPurple = Color(0xff4a3f6a);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "stepCounter".tr,
        showBackButton: true,
        showLogo: true,
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              // Circular step display
              Expanded(
                child: Center(
                  child: Obx(() {
                    return Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(
                          color: _lightLavender,
                          width: 12,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.shadowColor.withOpacity(0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions_walk,
                            size: 48,
                            color: Colors.black87,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${controller.steps.value}',
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.stepLabel,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 32),
              // Start Counting button
              Obx(() {
                final isCounting = controller.isCounting.value;
                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isCounting
                        ? null
                        : () => controller.startCounting(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _darkPurple,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _darkPurple.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: AppColor.shadowColor.withOpacity(0.4),
                    ),
                    child: Text(
                      isCounting ? "stepCounter".tr : "startCounting".tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
