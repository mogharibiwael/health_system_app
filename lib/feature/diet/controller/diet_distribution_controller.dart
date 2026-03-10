import 'package:get/get.dart';
import '../../../core/routes/app_route.dart';
import '../../../../doctorApp/feature/home/model/patient_model.dart';
import '../model/exchange_model.dart';
import '../model/portion_categories_model.dart';
import '../../../../core/service/diet_calculator_service.dart';

/// Distribution of daily servings across meal periods.
/// Keys: meal_type (breakfast, lunch, dinner, firstSnack, secondSnack, thirdSnack, extraSnack_X)
class MealDistribution {
  final Map<String, Map<String, int>> servingsPerMeal;

  MealDistribution(this.servingsPerMeal);

  Map<String, int> getMealServings(String mealKey) =>
      servingsPerMeal[mealKey] ?? {};
}

class DietDistributionController extends GetxController {
  int? patientId;
  String patientName = "";
  int? doctorId;
  PatientModel? patient;
  List<Map<String, dynamic>> periods = [];
  DietTargetsResult? targets;
  DailyExchangePlan? exchangePlan;
  PortionCategoriesPlan? portionPlan;

  /// Current distribution: mealKey -> {starch, fruit, vegetables, milk, meat, fat}
  final Map<String, Map<String, int>> _distribution = {};

  Map<String, Map<String, int>> get distribution => Map.unmodifiable(_distribution);

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? {};
    patientId = args["patient_id"];
    patientName = (args["patient_name"] ?? "").toString();
    doctorId = args["doctor_id"];
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
    portionPlan = args["portion_plan"] as PortionCategoriesPlan?;
    _computeDefaultDistribution();
    update();
  }

  void _computeDefaultDistribution() {
    if (exchangePlan == null || periods.isEmpty) return;

    final plan = exchangePlan!;
    final mealKeys = _getMealKeys();

    final ratios = _getCalorieRatios(mealKeys.length);

    for (var i = 0; i < mealKeys.length; i++) {
      final key = mealKeys[i];
      final ratio = ratios[i];
      _distribution[key] = {
        'starch': (plan.starch * ratio).round().clamp(0, 20),
        'fruit': (plan.fruit * ratio).round().clamp(0, 5),
        'vegetables': (plan.vegetables * ratio).round().clamp(0, 10),
        'milk': (plan.milk * ratio).round().clamp(0, 2),
        'meat': (plan.meat * ratio).round().clamp(0, 10),
        'fat': (plan.fat * ratio).round().clamp(0, 5),
      };
    }

    _balanceToMatchTotals(plan);
  }

  List<String> _getMealKeys() {
    final keys = <String>[];
    var extraIdx = 0;
    for (final p in periods) {
      final type = p["meal_type"]?.toString() ?? "";
      final custom = p["custom_name"]?.toString();
      if (type == "extraSnack") {
        keys.add(custom != null && custom.isNotEmpty
            ? "extra_$custom"
            : "extraSnack_${++extraIdx}");
      } else if (type.isNotEmpty) {
        keys.add(type);
      }
    }
    if (keys.isEmpty) keys.addAll(["breakfast", "lunch", "dinner"]);
    return keys;
  }

  List<double> _getCalorieRatios(int count) {
    if (count <= 0) return [];
    if (count <= 3) {
      return [0.25, 0.35, 0.40];
    }
    final mainMeals = 3;
    final snacks = count - mainMeals;
    final snackShare = 0.15 / snacks.clamp(1, 10);
    final mainShare = (1 - 0.15) / mainMeals;
    final list = <double>[];
    for (var i = 0; i < count; i++) {
      list.add(i < mainMeals ? mainShare : snackShare);
    }
    return list;
  }

  void _balanceToMatchTotals(DailyExchangePlan plan) {
    final mealKeys = _distribution.keys.toList();
    if (mealKeys.isEmpty) return;

    final targets = {
      'starch': plan.starch,
      'fruit': plan.fruit,
      'vegetables': plan.vegetables,
      'milk': plan.milk,
      'meat': plan.meat,
      'fat': plan.fat,
    };

    for (final group in targets.keys) {
      var sum = 0;
      for (final key in mealKeys) {
        sum += _distribution[key]![group] ?? 0;
      }
      var diff = targets[group]! - sum;
      var idx = 0;
      while (diff != 0 && mealKeys.isNotEmpty) {
        final key = mealKeys[idx % mealKeys.length];
        final current = _distribution[key]![group] ?? 0;
        if (diff > 0) {
          _distribution[key]![group] = current + 1;
          diff--;
        } else if (diff < 0 && current > 0) {
          _distribution[key]![group] = current - 1;
          diff++;
        }
        idx++;
        if (idx > mealKeys.length * 20) break;
      }
    }
  }

  void setMealServings(String mealKey, String group, int value) {
    _distribution[mealKey] ??= {};
    _distribution[mealKey]![group] = value.clamp(0, 20);
    update();
  }

  void goToCreateDiet() {
    if (patientId == null || doctorId == null) {
      Get.snackbar("error".tr, "fillFields".tr);
      return;
    }
    Get.toNamed(
      AppRoute.dietDetermineMeals,
      arguments: {
        "patient_id": patientId,
        "patient_name": patientName,
        "doctor_id": doctorId,
        "patient": patient,
        "periods": periods,
        "targets": targets,
        "portion_plan": portionPlan,
        "exchange_plan": exchangePlan,
        "exchange_plan_json": exchangePlan?.toJson(),
        "distribution": Map.from(_distribution),
      },
    );
  }

  String mealKeyToLabel(String key) {
    if (key == "breakfast") return "breakfast".tr;
    if (key == "lunch") return "lunch".tr;
    if (key == "dinner") return "dinner".tr;
    if (key == "firstSnack") return "firstSnack".tr;
    if (key == "secondSnack") return "secondSnack".tr;
    if (key == "thirdSnack") return "thirdSnack".tr;
    if (key.startsWith("extra_")) return key.substring(6);
    if (key.startsWith("extraSnack_")) return "${"extraSnack".tr} ${key.substring(11)}";
    return key;
  }
}
