import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../controller/portion_carb_controller.dart';

class PortionCarbPage extends GetView<PortionCarbController> {
  const PortionCarbPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PortionCarbController>(
      builder: (c) => SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: CustomAppBar(
            subtitle: c.patientName.isNotEmpty ? c.patientName : null,
            title: "carbDistribution".tr,
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
                        "carbDistribution".tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColor.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "${"totalCarbPortions".tr} = ${c.totalCarbPortions} - ${"divideAmongFields".tr}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInput(
                        label: "starchPortions".tr,
                        value: c.starchPortions,
                        onChanged: c.setStarch,
                      ),
                      const SizedBox(height: 12),
                      _buildInput(
                        label: "otherCarbPortions".tr,
                        value: c.otherCarbPortions,
                        onChanged: c.setOtherCarbs,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: c.goToProteinDistribution,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text("save".tr),
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
