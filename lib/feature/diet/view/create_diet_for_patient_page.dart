import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../controller/diet_controller.dart';

/// Doctor-only: create diet plan for a specific patient (opened from patient details).
class CreateDietForPatientPage extends GetView<DietController> {
  const CreateDietForPatientPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = (Get.arguments as Map?) ?? {};
    final patientId = (args["patient_id"] is int) ? args["patient_id"] as int : int.tryParse("${args["patient_id"]}") ?? 0;
    final patientName = (args["patient_name"] ?? "").toString();
    final doctorId = (args["doctor_id"] is int) ? args["doctor_id"] as int : int.tryParse("${args["doctor_id"]}") ?? 0;

    return GetBuilder<DietController>(
      builder: (c) {
        if (patientId > 0 && c.patientIdController.text != patientId.toString()) {
          c.patientIdController.text = patientId.toString();
        }
        if (patientName.isNotEmpty && c.titleController.text.isEmpty) {
          c.titleController.text = "Diet plan for $patientName";
        }

        return SafeArea(
          child: Scaffold(
          appBar: CustomAppBar(
            title: "createDietPlan".tr,
            showBackButton: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (patientName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      "Patient: $patientName",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                TextField(
                  controller: c.patientIdController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "patientId".tr,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: c.titleController,
                  decoration: InputDecoration(
                    labelText: "title".tr,
                    hintText: "e.g. Weight loss plan",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: c.dailyCaloriesController,
                  decoration: InputDecoration(
                    labelText: "dailyCalories".tr,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: c.durationDaysController,
                  decoration: InputDecoration(
                    labelText: "durationDays".tr,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: c.startDateController,
                  decoration: InputDecoration(
                    labelText: "startDate".tr,
                    hintText: "2024-01-01",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: c.endDateController,
                  decoration: InputDecoration(
                    labelText: "endDate".tr,
                    hintText: "2024-01-31",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: c.createStatus == StatusRequest.loading
                      ? null
                      : () {
                          final pid = int.tryParse(c.patientIdController.text);
                          final dailyCalories = int.tryParse(c.dailyCaloriesController.text);
                          final durationDays = int.tryParse(c.durationDaysController.text);
                          if (pid == null || doctorId == 0 || c.titleController.text.isEmpty ||
                              dailyCalories == null || durationDays == null ||
                              c.startDateController.text.isEmpty || c.endDateController.text.isEmpty) {
                            Get.snackbar("error".tr, "fillFields".tr);
                            return;
                          }
                          c.createDietPlan(
                            patientId: pid,
                            doctorId: doctorId,
                            title: c.titleController.text,
                            dailyCalories: dailyCalories,
                            durationDays: durationDays,
                            startDate: c.startDateController.text,
                            endDate: c.endDateController.text,
                          );
                          Get.back();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: c.createStatus == StatusRequest.loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text("create".tr),
                ),
              ],
            ),
          ),
        ));
      },
    );
  }
}
