import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutri_guide/core/class/status_request.dart';
import 'package:nutri_guide/core/constant/theme/colors.dart';
import 'package:nutri_guide/core/routes/app_route.dart';
import '../controller/patient_details_controller.dart';

class PatientDetailsPage extends GetView<PatientDetailsController> {
  const PatientDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PatientDetailsController>(
      builder: (c) => Scaffold(
        appBar: AppBar(
          title: Text(c.patient.fullname),
          actions: [
            IconButton(
              icon: const Icon(Icons.chat_outlined),
              tooltip: "Chat",
              onPressed: () {
                Get.toNamed(
                  AppRoute.chat,
                  arguments: {
                    "doctor_id": c.patient.userId,
                    "doctor_name": c.patient.fullname,
                    "receiver_id": c.patient.userId,
                    "conversation_id": c.patient.userId,
                  },
                );
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _InfoRow("Full Name", c.patient.fullname),
            _InfoRow("Gender", c.patient.gender ?? "-"),
            _InfoRow("Height", c.patient.height?.toString() ?? "-"),
            _InfoRow("Weight", c.patient.weight?.toString() ?? "-"),
            _InfoRow("Phone", c.patient.phoneNumber ?? "-"),
            _InfoRow("Birthdate", c.patient.birthdate ?? "-"),
            _InfoRow("Activity", c.patient.physicalActivity ?? "-"),
            _InfoRow("Medical", c.patient.medical ?? "-"),

            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _MacrosSection(controller: c),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.toNamed(
                    AppRoute.chat,
                    arguments: {
                      "doctor_id": c.patient.userId,
                      "doctor_name": c.patient.fullname,
                      "receiver_id": c.patient.userId,
                      "conversation_id": c.patient.userId,
                    },
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline),
                label: Text("Chat with ${c.patient.fullname}"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: OutlinedButton.icon(
                onPressed: c.openCreateDiet,
                icon: const Icon(Icons.restaurant_menu_outlined),
                label: Text("createDietForPatient".tr),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColor.primary,
                  side: BorderSide(color: AppColor.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacrosSection extends StatelessWidget {
  final PatientDetailsController controller;

  const _MacrosSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "nutritionMacros".tr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (c.macrosStatus == StatusRequest.loading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              TextButton.icon(
                onPressed: c.toggleEditMacros,
                icon: Icon(
                  c.isEditingMacros ? Icons.close : Icons.edit_outlined,
                  size: 18,
                ),
                label: Text(c.isEditingMacros ? "cancel".tr : "edit".tr),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (c.isEditingMacros) ...[
          TextField(
            controller: c.carbsController,
            decoration: InputDecoration(
              labelText: "carbohydrates".tr,
              suffixText: "g",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: c.fatsController,
            decoration: InputDecoration(
              labelText: "fats".tr,
              suffixText: "g",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: c.proteinController,
            decoration: InputDecoration(
              labelText: "protein".tr,
              suffixText: "g",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: c.saveMacrosStatus == StatusRequest.loading ? null : c.saveMacros,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: c.saveMacrosStatus == StatusRequest.loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text("save".tr),
            ),
          ),
        ] else ...[
          _InfoRow("carbohydrates".tr, _macrosValue(c.patient.carbohydrates)),
          _InfoRow("fats".tr, _macrosValue(c.patient.fats)),
          _InfoRow("protein".tr, _macrosValue(c.patient.protein)),
        ],
      ],
    );
  }

  String _macrosValue(double? v) {
    if (v == null) return "-";
    return "${v.toStringAsFixed(0)} g";
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
