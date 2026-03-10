import 'package:get/get.dart';
import '../../../core/routes/app_route.dart';
import '../../../../doctorApp/feature/home/model/patient_model.dart';
import '../../../core/service/diet_calculator_service.dart';
import '../model/exchange_model.dart';
import '../model/portion_categories_model.dart';

class PortionCarbController extends GetxController {
  int? patientId;
  String patientName = "";
  int? doctorId;
  PatientModel? patient;
  List<Map<String, dynamic>> periods = [];
  DietTargetsResult? targets;
  PortionCategoriesPlan? portionPlan;
  DailyExchangePlan? exchangePlan;

  int starchPortions = 0;
  int otherCarbPortions = 0;

  int get totalCarbPortions => starchPortions + otherCarbPortions;

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
      starchPortions = portionPlan!.starch;
      otherCarbPortions = portionPlan!.otherCarbs;
    } else if (exchangePlan != null) {
      starchPortions = exchangePlan!.starch;
      otherCarbPortions = 0;
    }
  }

  void setStarch(int v) {
    starchPortions = v.clamp(0, 20);
    update();
  }

  void setOtherCarbs(int v) {
    otherCarbPortions = v.clamp(0, 20);
    update();
  }

  void goToProteinDistribution() {
    if (patientId == null || doctorId == null) {
      Get.snackbar("error".tr, "fillFields".tr);
      return;
    }
    final plan = portionPlan ?? PortionCategoriesPlan();
    plan.starch = starchPortions;
    plan.otherCarbs = otherCarbPortions;
    Get.toNamed(
      AppRoute.dietPortionProtein,
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
