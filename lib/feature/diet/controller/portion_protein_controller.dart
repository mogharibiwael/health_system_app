import 'package:get/get.dart';
import '../../../core/routes/app_route.dart';
import '../../../../doctorApp/feature/home/model/patient_model.dart';
import '../../../core/service/diet_calculator_service.dart';
import '../model/exchange_model.dart';
import '../model/portion_categories_model.dart';

class PortionProteinController extends GetxController {
  int? patientId;
  String patientName = "";
  int? doctorId;
  PatientModel? patient;
  List<Map<String, dynamic>> periods = [];
  DietTargetsResult? targets;
  PortionCategoriesPlan? portionPlan;
  DailyExchangePlan? exchangePlan;

  int meatVeryLean = 0;
  int meatLean = 0;
  int meatMediumFat = 0;
  int meatHighFat = 0;

  int get totalMeatPortions =>
      meatVeryLean + meatLean + meatMediumFat + meatHighFat;

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? {};
    patientId = args["patient_id"];
    patientName = (args["patient_name"] ?? "").toString();
    doctorId = args["doctor_id"] is int
        ? args["doctor_id"] as int
        : int.tryParse("${args["doctor_id"]}") ?? 0;
    patient = args["patient"] as PatientModel?;
    if (args["periods"] is List) {
      periods = (args["periods"] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    targets = args["targets"] as DietTargetsResult?;
    portionPlan = args["portion_plan"] as PortionCategoriesPlan?;
    if (args["exchange_plan"] is DailyExchangePlan) {
      exchangePlan = args["exchange_plan"] as DailyExchangePlan;
    } else if (args["exchange_plan_json"] is Map) {
      exchangePlan = DailyExchangePlan.fromJson(
        Map<String, dynamic>.from(args["exchange_plan_json"] as Map),
      );
    }
    if (portionPlan != null) {
      meatVeryLean = portionPlan!.meatVeryLean;
      meatLean = portionPlan!.meatLean;
      meatMediumFat = portionPlan!.meatMediumFat;
      meatHighFat = portionPlan!.meatHighFat;
    } else if (exchangePlan != null) {
      meatVeryLean = exchangePlan!.meat;
      meatLean = 0;
      meatMediumFat = 0;
      meatHighFat = 0;
    }
  }

  void setMeatVeryLean(int v) {
    meatVeryLean = v.clamp(0, 20);
    update();
  }

  void setMeatLean(int v) {
    meatLean = v.clamp(0, 20);
    update();
  }

  void setMeatMediumFat(int v) {
    meatMediumFat = v.clamp(0, 20);
    update();
  }

  void setMeatHighFat(int v) {
    meatHighFat = v.clamp(0, 20);
    update();
  }

  void goToDistribution() {
    if (patientId == null || doctorId == null) {
      Get.snackbar("error".tr, "fillFields".tr);
      return;
    }
    final plan = portionPlan ?? PortionCategoriesPlan();
    plan.meatVeryLean = meatVeryLean;
    plan.meatLean = meatLean;
    plan.meatMediumFat = meatMediumFat;
    plan.meatHighFat = meatHighFat;
    Get.toNamed(
      AppRoute.dietDistribution,
      arguments: {
        "patient_id": patientId,
        "patient_name": patientName,
        "doctor_id": doctorId,
        "patient": patient,
        "periods": periods,
        "targets": targets,
        "portion_plan": plan,
        "exchange_plan": plan.toDailyExchange(),
        "exchange_plan_json": plan.toDailyExchange().toJson(),
      },
    );
  }
}
