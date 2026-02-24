import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutri_guide/core/class/status_request.dart';
import 'package:nutri_guide/core/function/handel_data.dart';
import 'package:nutri_guide/core/service/serviecs.dart';
import '../data/patient_profile_data.dart';

class PatientProfileController extends GetxController {
  final MyServices myServices = Get.find();
  final PatientProfileData data = PatientProfileData(Get.find());


  // fields
  String gender = "male";
  String physicalActivity = "active";

  late TextEditingController dobController; // yyyy-mm-dd
  late TextEditingController heightController;
  late TextEditingController weightController;
  late TextEditingController medicalHistoryController;

  StatusRequest statusRequest = StatusRequest.success;

  @override
  void onInit() {
    dobController = TextEditingController();
    heightController = TextEditingController();
    weightController = TextEditingController();
    medicalHistoryController = TextEditingController();
    super.onInit();
  }

  void setGender(String v) {
    gender = v;
    update();
  }

  void setActivity(String v) {
    physicalActivity = v;
    update();
  }

  Future<void> pickDob(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20, 1, 1),
      firstDate: DateTime(1900, 1, 1),
      lastDate: now,
    );
    if (picked == null) return;
    final y = picked.year.toString().padLeft(4, '0');
    final m = picked.month.toString().padLeft(2, '0');
    final d = picked.day.toString().padLeft(2, '0');
    dobController.text = "$y-$m-$d";
    update();
  }

  Future<void> save() async {
    final token = myServices.token;
    if (token == null || token.trim().isEmpty) {
      Get.snackbar("Error", "Missing token, please login again");
      return;
    }

    final dob = dobController.text.trim();
    final h = double.tryParse(heightController.text.trim());
    final w = double.tryParse(weightController.text.trim());

    if (dob.isEmpty || h == null || w == null || h <= 0 || w <= 0) {
      Get.snackbar("Error", "Please fill required fields correctly");
      return;
    }

    statusRequest = StatusRequest.loading;
    update();

    final body = {
      "gender": gender,
      "date_of_birth": dob,
      "height": int.parse(heightController.text.trim()),
      "current_weight": int.parse(weightController.text.trim()),
      "physical_activity": physicalActivity,
      "medical_history": medicalHistoryController.text.trim(),
    };

    final res = await data.updateProfile(body, token: token);

    print("res");
    print(res);
    print("res");

    res.fold(
          (failure) {
        statusRequest = failure;
        update();

        String msg = "Request failed";
        if (failure == StatusRequest.offlineFailure) {
          msg = "No internet connection";
        } else if (failure == StatusRequest.serverFailure) {
          msg = "Server error";
        }

        Get.snackbar("Error", msg);
      },
          (response) {
        statusRequest = StatusRequest.success;
        update();

        final msg = response["message"] ?? "Profile updated successfully";

        AwesomeDialog(
          context: Get.context!,
          dialogType: DialogType.success,
          animType: AnimType.scale,
          title: "Success",
          desc: msg,
          dismissOnTouchOutside: false,
          btnOkOnPress: () {
            Get.back(result: true);
          },
        ).show();
      },
    );

  }


  @override
  void onClose() {
    dobController.dispose();
    heightController.dispose();
    weightController.dispose();
    medicalHistoryController.dispose();
    super.onClose();
  }
}
