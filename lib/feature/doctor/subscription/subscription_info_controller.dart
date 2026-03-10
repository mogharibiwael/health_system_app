import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/routes/app_route.dart';
import '../model/doctor_model.dart';

enum SubscriptionGender { male, female }

enum SubscriptionActivity { sedentary, light, moderate, active }

class SubscriptionInfoController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();

  DateTime? dateOfBirth;
  int? heightCm;
  int? weightKg;
  SubscriptionGender gender = SubscriptionGender.male;
  SubscriptionActivity activity = SubscriptionActivity.sedentary;

  late DoctorModel doctor;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Map<String, dynamic>) {
      doctor = DoctorModel.fromJson(arg['doctor'] as Map<String, dynamic>);
    } else {
      doctor = DoctorModel(
        id: 0,
        name: "-",
        isVerified: false,
        isAvailable: false,
        rating: "0",
      );
    }
  }

  String get dateOfBirthText {
    if (dateOfBirth == null) return "";
    return "${dateOfBirth!.year}-${dateOfBirth!.month.toString().padLeft(2, '0')}-${dateOfBirth!.day.toString().padLeft(2, '0')}";
  }

  String get heightText => heightCm != null ? "$heightCm cm" : "";
  String get weightText => weightKg != null ? "$weightKg kg" : "";

  void setDateOfBirth(DateTime d) {
    dateOfBirth = d;
    update();
  }

  void setHeight(int cm) {
    heightCm = cm;
    update();
  }

  void setWeight(int kg) {
    weightKg = kg;
    update();
  }

  void setGender(SubscriptionGender g) {
    gender = g;
    update();
  }

  void setActivity(SubscriptionActivity a) {
    activity = a;
    update();
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: dateOfBirth ?? DateTime(1990, 6, 12),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) setDateOfBirth(picked);
  }

  Future<void> pickHeight() async {
    final picked = await showDialog<int>(
      context: Get.context!,
      builder: (context) => _NumberPickerDialog(
        title: "selectHeight".tr,
        min: 100,
        max: 250,
        initial: heightCm ?? 170,
        unit: "cm",
      ),
    );
    if (picked != null) setHeight(picked);
  }

  Future<void> pickWeight() async {
    final picked = await showDialog<int>(
      context: Get.context!,
      builder: (context) => _NumberPickerDialog(
        title: "selectWeight".tr,
        min: 30,
        max: 250,
        initial: weightKg ?? 70,
        unit: "kg",
      ),
    );
    if (picked != null) setWeight(picked);
  }

  void goToPaymentInvoice() {
    if (!formKey.currentState!.validate()) return;
    if (dateOfBirth == null) {
      Get.snackbar("fillFields".tr, "selectDateOfBirth".tr);
      return;
    }
    if (heightCm == null || weightKg == null) {
      Get.snackbar("fillFields".tr, "selectHeight".tr + " / " + "selectWeight".tr);
      return;
    }

    Get.toNamed(AppRoute.paymentInvoice, arguments: {
      "doctor": doctor.toJson(),
      "full_name": fullNameController.text.trim(),
      "phone": phoneController.text.trim(),
      "date_of_birth": dateOfBirthText,
      "height_cm": heightCm,
      "weight_kg": weightKg,
      "gender": gender == SubscriptionGender.male ? "male" : "female",
      "activity": activity.name,
    });
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}

class _NumberPickerDialog extends StatefulWidget {
  final String title;
  final int min;
  final int max;
  final int initial;
  final String unit;

  const _NumberPickerDialog({
    required this.title,
    required this.min,
    required this.max,
    required this.initial,
    required this.unit,
  });

  @override
  State<_NumberPickerDialog> createState() => _NumberPickerDialogState();
}

class _NumberPickerDialogState extends State<_NumberPickerDialog> {
  late int value;

  @override
  void initState() {
    super.initState();
    value = widget.initial.clamp(widget.min, widget.max);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: value > widget.min
                    ? () => setState(() => value--)
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "$value ${widget.unit}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: value < widget.max
                    ? () => setState(() => value++)
                    : null,
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("cancel".tr),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(value),
          style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
          child: Text("ok".tr),
        ),
      ],
    );
  }
}
