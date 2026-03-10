import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../controller/portion_protein_controller.dart';

class PortionProteinPage extends GetView<PortionProteinController> {
  const PortionProteinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PortionProteinController>(
      builder: (c) => SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: CustomAppBar(
            subtitle: c.patientName.isNotEmpty ? c.patientName : null,
            title: "proteinDistribution".tr,
            showBackButton: true,
            showLogo: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.shadowColor.withOpacity(0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "proteinDistribution".tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColor.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "${"totalProteinPortions".tr} = ${c.totalMeatPortions} - ${"divideAmongFields".tr}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInput(
                        label: "veryLeanMeatPortions".tr,
                        value: c.meatVeryLean,
                        onChanged: c.setMeatVeryLean,
                      ),
                      const SizedBox(height: 12),
                      _buildInput(
                        label: "leanMeatPortions".tr,
                        value: c.meatLean,
                        onChanged: c.setMeatLean,
                      ),
                      const SizedBox(height: 12),
                      _buildInput(
                        label: "mediumFatMeatPortions".tr,
                        value: c.meatMediumFat,
                        onChanged: c.setMeatMediumFat,
                      ),
                      const SizedBox(height: 12),
                      _buildInput(
                        label: "highFatMeatPortions".tr,
                        value: c.meatHighFat,
                        onChanged: c.setMeatHighFat,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: c.goToDistribution,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text("proceedToNextStep".tr),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required int value,
    required void Function(int) onChanged,
  }) {
    return TextFormField(
      initialValue: value.toString(),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onChanged: (v) {
        final val = int.tryParse(v) ?? 0;
        onChanged(val);
      },
    );
  }
}
