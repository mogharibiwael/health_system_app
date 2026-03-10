import 'package:get/get.dart';
import '../../../core/routes/app_route.dart';
import '../../../../doctorApp/feature/home/model/patient_model.dart';
import '../../../core/service/diet_calculator_service.dart';
import '../model/exchange_model.dart';
import '../model/portion_categories_model.dart';

class PortionCategoriesController extends GetxController {
  int? patientId;
  String patientName = "";
  int? doctorId;
  PatientModel? patient;
  List<Map<String, dynamic>> periods = [];
  DietTargetsResult? targets;
  DailyExchangePlan? exchangePlan;

  late PortionCategoriesPlan portionPlan;

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
    if (args["exchange_plan"] is DailyExchangePlan) {
      exchangePlan = args["exchange_plan"] as DailyExchangePlan;
    } else if (args["exchange_plan_json"] is Map) {
      exchangePlan = DailyExchangePlan.fromJson(
        Map<String, dynamic>.from(args["exchange_plan_json"] as Map),
      );
    }
    portionPlan = exchangePlan != null
        ? PortionCategoriesPlan.fromDailyExchange(exchangePlan!)
        : PortionCategoriesPlan();

    // Prefill from Base Servings step when coming from that flow
    final baseServings = args["base_servings"] as Map<String, dynamic>?;
    if (baseServings != null && exchangePlan != null) {
      final fruit = baseServings["fruit"];
      final vegetables = baseServings["vegetables"];
      final milk = baseServings["milk"];
      if (fruit is int) portionPlan.fruit = fruit.clamp(0, 20);
      if (vegetables is int) portionPlan.vegetables = vegetables.clamp(0, 20);
      if (milk is int) {
        final m = milk.clamp(0, 20);
        switch (exchangePlan!.milkType) {
          case MilkType.skim:
            portionPlan.milkSkim = m;
            portionPlan.milkLowFat = 0;
            portionPlan.milkWhole = 0;
            break;
          case MilkType.lowFat:
            portionPlan.milkSkim = 0;
            portionPlan.milkLowFat = m;
            portionPlan.milkWhole = 0;
            break;
          case MilkType.whole:
            portionPlan.milkSkim = 0;
            portionPlan.milkLowFat = 0;
            portionPlan.milkWhole = m;
            break;
        }
      }
    }
  }

  void setPortion(String key, int value) {
    switch (key) {
      case 'milkSkim':
        portionPlan.milkSkim = value.clamp(0, 20);
        break;
      case 'milkLowFat':
        portionPlan.milkLowFat = value.clamp(0, 20);
        break;
      case 'milkWhole':
        portionPlan.milkWhole = value.clamp(0, 20);
        break;
      case 'vegetables':
        portionPlan.vegetables = value.clamp(0, 20);
        break;
      case 'fruit':
        portionPlan.fruit = value.clamp(0, 20);
        break;
      case 'starch':
        portionPlan.starch = value.clamp(0, 20);
        break;
      case 'otherCarbs':
        portionPlan.otherCarbs = value.clamp(0, 20);
        break;
      case 'meatVeryLean':
        portionPlan.meatVeryLean = value.clamp(0, 20);
        break;
      case 'meatLean':
        portionPlan.meatLean = value.clamp(0, 20);
        break;
      case 'meatMediumFat':
        portionPlan.meatMediumFat = value.clamp(0, 20);
        break;
      case 'meatHighFat':
        portionPlan.meatHighFat = value.clamp(0, 20);
        break;
      case 'fat':
        portionPlan.fat = value.clamp(0, 30);
        break;
    }
    update();
  }

  int getPortion(String key) {
    final m = portionPlan.toGroupMap();
    return m[key] ?? 0;
  }

  void goToCarbDistribution() {
    if (patientId == null || doctorId == null) {
      Get.snackbar("error".tr, "fillFields".tr);
      return;
    }
    Get.toNamed(
      AppRoute.dietPortionCarb,
      arguments: {
        "patient_id": patientId,
        "patient_name": patientName,
        "doctor_id": doctorId,
        "patient": patient,
        "periods": periods,
        "targets": targets,
        "portion_plan": portionPlan,
        "exchange_plan": portionPlan.toDailyExchange(),
        "exchange_plan_json": portionPlan.toDailyExchange().toJson(),
      },
    );
  }
}
