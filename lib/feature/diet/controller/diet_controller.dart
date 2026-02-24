import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dartz/dartz.dart';
import '../../../core/class/status_request.dart';
import '../../../core/function/handel_data.dart';
import '../../../core/service/serviecs.dart';
import '../../../core/permissions/permissions.dart';
import '../data/diet_data.dart';
import '../model/diet_model.dart';

class DietController extends GetxController {
  final DietData dietData = DietData(Get.find());
  final MyServices myServices = Get.find();
  late final Permissions permissions;

  StatusRequest statusRequest = StatusRequest.loading;
  StatusRequest mealsStatusRequest = StatusRequest.loading;
  StatusRequest createStatus = StatusRequest.success;

  DietModel? currentDiet;
  List<DietMealModel> meals = [];

  String? get token => myServices.token;
  bool get isDoctor => permissions.isDoctor || permissions.isAdmin;
  bool get canCreateDiet => permissions.canCreateDietPlan;
  int? get currentUserId => myServices.userId;

  // Create diet plan form controllers (for doctors)
  final TextEditingController patientIdController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController dailyCaloriesController = TextEditingController();
  final TextEditingController durationDaysController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    permissions = Permissions(myServices);
    // Only load diet if user is patient
    if (permissions.canViewMyDiet) {
      loadMyDiet();
    } else {
      statusRequest = StatusRequest.success;
      update();
    }
  }

  Future<void> loadMyDiet() async {
    statusRequest = StatusRequest.loading;
    update();

    final res = await dietData.getMyDiet(token: token);

    res.fold((l) {
      statusRequest = l;
      update();
    }, (r) {
      statusRequest = handelData(r);

      if (r["data"] is Map) {
        currentDiet = DietModel.fromJson(r["data"] as Map<String, dynamic>);
      } else {
        currentDiet = DietModel.fromJson(r);
      }

      statusRequest = StatusRequest.success;
      update();
    });
  }

  Future<void> loadMeals() async {
    mealsStatusRequest = StatusRequest.loading;
    update();

    final res = await dietData.getMyDietMeals(token: token);

    res.fold((l) {
      mealsStatusRequest = l;
      update();
    }, (r) {
      mealsStatusRequest = handelData(r);

      final List data = (r["data"] ?? r["meals"] ?? []) as List;
      meals = data
          .map((e) => DietMealModel.fromJson(e as Map<String, dynamic>))
          .toList();

      mealsStatusRequest = StatusRequest.success;
      update();
    });
  }

  Future<void> createDietPlan({
    required int patientId,
    required int doctorId,
    required String title,
    required int dailyCalories,
    required int durationDays,
    required String startDate,
    required String endDate,
    List<Map<String, dynamic>>? meals,
  }) async {
    createStatus = StatusRequest.loading;
    update();

    final res = await dietData.createDietPlan(
      patientId: patientId,
      doctorId: doctorId,
      title: title,
      dailyCalories: dailyCalories,
      durationDays: durationDays,
      startDate: startDate,
      endDate: endDate,
      meals: meals,
      token: token,
    );

    res.fold((l) {
      createStatus = StatusRequest.failure;
      update();
      Get.snackbar("error".tr, "serverError".tr);
    }, (r) {
      if (r.containsKey("errors")) {
        createStatus = StatusRequest.failure;
        update();
        final errors = r["errors"] as Map?;
        final firstError = errors?.values.first;
        final msg = (firstError is List && firstError.isNotEmpty)
            ? firstError.first.toString()
            : r["message"]?.toString() ?? "serverError".tr;
        Get.snackbar("error".tr, msg);
        return;
      }

      createStatus = StatusRequest.success;
      update();
      Get.snackbar("success".tr, r["message"]?.toString() ?? "Diet plan created successfully");
    });
  }

  Future<void> refreshDiet() async {
    await loadMyDiet();
  }

  @override
  void onClose() {
    patientIdController.dispose();
    titleController.dispose();
    dailyCaloriesController.dispose();
    durationDaysController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.onClose();
  }
}
