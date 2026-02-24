import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/class/status_request.dart';
import '../../../../core/function/handel_data.dart';
import '../../../../core/routes/app_route.dart';
import '../../../../core/service/serviecs.dart';
import '../data/doctor_patients_data.dart';
import '../model/patient_model.dart';

class PatientDetailsController extends GetxController {
  late PatientModel patient;
  final DoctorPatientsData patientsData = DoctorPatientsData(Get.find());
  final MyServices myServices = Get.find();

  final TextEditingController carbsController = TextEditingController();
  final TextEditingController fatsController = TextEditingController();
  final TextEditingController proteinController = TextEditingController();

  bool isEditingMacros = false;
  StatusRequest macrosStatus = StatusRequest.success;
  StatusRequest saveMacrosStatus = StatusRequest.success;

  @override
  void onInit() {
    super.onInit();

    final arg = Get.arguments;
    if (arg is PatientModel) {
      patient = arg;
    } else if (arg is Map<String, dynamic>) {
      patient = PatientModel.fromJson(arg);
    } else {
      patient = PatientModel(
        id: 0,
        fullname: "-",
        userId: 0,
      );
    }

    _setMacrosFromPatient();
    if (patient.id > 0) _loadMacros();
  }

  void _setMacrosFromPatient() {
    carbsController.text = patient.carbohydrates != null ? patient.carbohydrates!.toStringAsFixed(0) : "";
    fatsController.text = patient.fats != null ? patient.fats!.toStringAsFixed(0) : "";
    proteinController.text = patient.protein != null ? patient.protein!.toStringAsFixed(0) : "";
  }

  Future<void> _loadMacros() async {
    macrosStatus = StatusRequest.loading;
    update();

    final res = await patientsData.getPatientMacros(
      patientId: patient.id,
      token: myServices.token,
    );

    res.fold((l) {
      macrosStatus = l;
      update();
    }, (r) {
      macrosStatus = StatusRequest.success;
      final data = r["data"] is Map ? r["data"] as Map<String, dynamic> : r;
      final carbs = data["carbohydrates"];
      final fats = data["fats"];
      final protein = data["protein"];
      if (carbs != null) carbsController.text = num.tryParse(carbs.toString())?.toStringAsFixed(0) ?? "";
      if (fats != null) fatsController.text = num.tryParse(fats.toString())?.toStringAsFixed(0) ?? "";
      if (protein != null) proteinController.text = num.tryParse(protein.toString())?.toStringAsFixed(0) ?? "";
      patient = patient.copyWith(
        carbohydrates: carbs != null ? (num.tryParse(carbs.toString())?.toDouble()) : null,
        fats: fats != null ? (num.tryParse(fats.toString())?.toDouble()) : null,
        protein: protein != null ? (num.tryParse(protein.toString())?.toDouble()) : null,
      );
      update();
    });
  }

  void toggleEditMacros() {
    isEditingMacros = !isEditingMacros;
    if (!isEditingMacros) _setMacrosFromPatient();
    update();
  }

  Future<void> saveMacros() async {
    final carbs = double.tryParse(carbsController.text.trim());
    final fats = double.tryParse(fatsController.text.trim());
    final protein = double.tryParse(proteinController.text.trim());

    if (carbs == null || fats == null || protein == null) {
      Get.snackbar("error".tr, "fillFields".tr);
      return;
    }

    saveMacrosStatus = StatusRequest.loading;
    update();

    final res = await patientsData.updatePatientMacros(
      patientId: patient.id,
      carbohydrates: carbs,
      fats: fats,
      protein: protein,
      token: myServices.token,
    );

    res.fold((l) {
      saveMacrosStatus = StatusRequest.failure;
      update();
      Get.snackbar("error".tr, "serverError".tr);
    }, (r) {
      if (r.containsKey("errors")) {
        saveMacrosStatus = StatusRequest.failure;
        update();
        final msg = r["message"]?.toString() ?? "serverError".tr;
        Get.snackbar("error".tr, msg);
        return;
      }
      saveMacrosStatus = StatusRequest.success;
      patient = patient.copyWith(carbohydrates: carbs, fats: fats, protein: protein);
      isEditingMacros = false;
      update();
      Get.snackbar("success".tr, "saved".tr);
    });
  }

  void openCreateDiet() {
    final doctorId = myServices.userId;
    if (doctorId == null) {
      Get.snackbar("error".tr, "Session error");
      return;
    }
    Get.toNamed(
      AppRoute.createDietForPatient,
      arguments: {
        "patient_id": patient.id,
        "patient_name": patient.fullname,
        "doctor_id": doctorId,
      },
    );
  }

  @override
  void onClose() {
    carbsController.dispose();
    fatsController.dispose();
    proteinController.dispose();
    super.onClose();
  }
}
