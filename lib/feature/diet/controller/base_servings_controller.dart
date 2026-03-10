import 'package:get/get.dart';
import '../../../core/routes/app_route.dart';
import '../../../../doctorApp/feature/home/model/patient_model.dart';
import '../../../core/service/diet_calculator_service.dart';
import '../model/exchange_model.dart';

/// Calories from macros: (carbs * 4) + (protein * 4) + (fat * 9) kcal.
double caloriesFromMacros(double carbsG, double proteinG, double fatG) {
  return (carbsG * 4) + (proteinG * 4) + (fatG * 9);
}

/// Result of base servings contribution (fruits, vegetables, milk only).
class BaseServingsContribution {
  final double carbsG;
  final double proteinG;
  final double fatG;
  final double calories;

  const BaseServingsContribution({
    required this.carbsG,
    required this.proteinG,
    required this.fatG,
    required this.calories,
  });
}

/// Remaining macro requirements after subtracting base servings contribution.
class RemainingMacros {
  final double carbsG;
  final double proteinG;
  final double fatG;
  final double calories;

  const RemainingMacros({
    required this.carbsG,
    required this.proteinG,
    required this.fatG,
    required this.calories,
  });
}

/// Controller for the Base Servings step (after Diet Targets, before Portion Categories).
/// Doctor sets servings and manually enters carbs, protein, and fat per group (Fruits, Vegetables, Milk).
/// Totals and remaining macros are computed from these manual values.
class BaseServingsController extends GetxController {
  int? patientId;
  String patientName = "";
  int? doctorId;
  PatientModel? patient;
  List<Map<String, dynamic>> periods = [];
  DietTargetsResult? targets;
  DailyExchangePlan? exchangePlan;

  int fruitServings = 0;
  int vegetablesServings = 0;
  int milkServings = 0;

  /// Manual macro input per group (grams). Doctor edits these directly.
  double fruitCarbs = 0;
  double fruitProtein = 0;
  double fruitFat = 0;
  double vegetableCarbs = 0;
  double vegetableProtein = 0;
  double vegetableFat = 0;
  double milkCarbs = 0;
  double milkProtein = 0;
  double milkFat = 0;

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? {};
    patientId = args["patient_id"] is int
        ? args["patient_id"] as int
        : int.tryParse("${args["patient_id"]}") ?? 0;
    patientName = (args["patient_name"] ?? "").toString();
    doctorId = args["doctor_id"] is int
        ? args["doctor_id"] as int
        : int.tryParse("${args["doctor_id"]}") ?? 0;
    if (args["patient"] is PatientModel) {
      patient = args["patient"] as PatientModel;
    }
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
    if (exchangePlan != null) {
      fruitServings = exchangePlan!.fruit;
      vegetablesServings = exchangePlan!.vegetables;
      milkServings = exchangePlan!.milk;
      // Pre-fill manual macros from exchange defaults so initial state is valid
      final f = ExchangeDefinitions.fruit;
      final v = ExchangeDefinitions.vegetables;
      final m = ExchangeDefinitions.getMilk(exchangePlan!.milkType);
      fruitCarbs = (fruitServings * f.carbsG).toDouble();
      fruitProtein = (fruitServings * f.proteinG).toDouble();
      fruitFat = (fruitServings * f.fatG).toDouble();
      vegetableCarbs = (vegetablesServings * v.carbsG).toDouble();
      vegetableProtein = (vegetablesServings * v.proteinG).toDouble();
      vegetableFat = (vegetablesServings * v.fatG).toDouble();
      milkCarbs = (milkServings * m.carbsG).toDouble();
      milkProtein = (milkServings * m.proteinG).toDouble();
      milkFat = (milkServings * m.fatG).toDouble();
    }
    update();
  }

  static double _clampNonNegative(double value) =>
      value.isNaN || value < 0 ? 0 : value;

  void setFruit(int value) {
    fruitServings = value.clamp(0, 999);
    update();
  }

  void setVegetables(int value) {
    vegetablesServings = value.clamp(0, 999);
    update();
  }

  void setMilk(int value) {
    milkServings = value.clamp(0, 999);
    update();
  }

  void setFruitCarbs(double value) {
    fruitCarbs = _clampNonNegative(value);
    update();
  }

  void setFruitProtein(double value) {
    fruitProtein = _clampNonNegative(value);
    update();
  }

  void setFruitFat(double value) {
    fruitFat = _clampNonNegative(value);
    update();
  }

  void setVegetableCarbs(double value) {
    vegetableCarbs = _clampNonNegative(value);
    update();
  }

  void setVegetableProtein(double value) {
    vegetableProtein = _clampNonNegative(value);
    update();
  }

  void setVegetableFat(double value) {
    vegetableFat = _clampNonNegative(value);
    update();
  }

  void setMilkCarbs(double value) {
    milkCarbs = _clampNonNegative(value);
    update();
  }

  void setMilkProtein(double value) {
    milkProtein = _clampNonNegative(value);
    update();
  }

  void setMilkFat(double value) {
    milkFat = _clampNonNegative(value);
    update();
  }

  /// Contribution from fruits only (manual macros; calories = carbs*4 + protein*4 + fat*9).
  BaseServingsContribution get fruitContribution {
    final cal = caloriesFromMacros(fruitCarbs, fruitProtein, fruitFat);
    return BaseServingsContribution(
      carbsG: fruitCarbs,
      proteinG: fruitProtein,
      fatG: fruitFat,
      calories: cal,
    );
  }

  /// Contribution from vegetables only.
  BaseServingsContribution get vegetablesContribution {
    final cal =
        caloriesFromMacros(vegetableCarbs, vegetableProtein, vegetableFat);
    return BaseServingsContribution(
      carbsG: vegetableCarbs,
      proteinG: vegetableProtein,
      fatG: vegetableFat,
      calories: cal,
    );
  }

  /// Contribution from milk only.
  BaseServingsContribution get milkContribution {
    final cal = caloriesFromMacros(milkCarbs, milkProtein, milkFat);
    return BaseServingsContribution(
      carbsG: milkCarbs,
      proteinG: milkProtein,
      fatG: milkFat,
      calories: cal,
    );
  }

  /// Total contribution from fruits + vegetables + milk.
  BaseServingsContribution get contribution {
    final f = fruitContribution;
    final v = vegetablesContribution;
    final m = milkContribution;
    return BaseServingsContribution(
      carbsG: f.carbsG + v.carbsG + m.carbsG,
      proteinG: f.proteinG + v.proteinG + m.proteinG,
      fatG: f.fatG + v.fatG + m.fatG,
      calories: f.calories + v.calories + m.calories,
    );
  }

  /// Remaining requirements = patient targets minus base contribution (clamped to ≥ 0).
  RemainingMacros? get remainingMacros {
    if (targets == null) return null;
    final c = contribution;
    return RemainingMacros(
      carbsG: (targets!.macros.carbsG - c.carbsG).clamp(0.0, double.infinity),
      proteinG:
          (targets!.macros.proteinG - c.proteinG).clamp(0.0, double.infinity),
      fatG: (targets!.macros.fatG - c.fatG).clamp(0.0, double.infinity),
      calories: (targets!.targetCalories - c.calories)
          .clamp(0.0, double.infinity),
    );
  }

  /// True if base contribution exceeds any patient target (show warning).
  bool get hasExceedsTargetsWarning {
    if (targets == null) return false;
    final c = contribution;
    return c.carbsG > targets!.macros.carbsG ||
        c.proteinG > targets!.macros.proteinG ||
        c.fatG > targets!.macros.fatG ||
        c.calories > targets!.targetCalories;
  }

  void goToPortionCategories() {
    if (patientId == null || doctorId == null) {
      Get.snackbar("error".tr, "fillFields".tr);
      return;
    }
    if (exchangePlan == null || targets == null) {
      Get.snackbar("error".tr, "fillPatientProfile".tr);
      return;
    }
    final baseServingsMap = {
      "fruit": fruitServings,
      "vegetables": vegetablesServings,
      "milk": milkServings,
    };
    final c = contribution;
    final baseContributionMap = {
      "carbs_g": c.carbsG,
      "protein_g": c.proteinG,
      "fat_g": c.fatG,
      "calories": c.calories,
    };
    final rem = remainingMacros;
    final remainingMap = rem != null
        ? {
            "carbs_g": rem.carbsG,
            "protein_g": rem.proteinG,
            "fat_g": rem.fatG,
            "calories": rem.calories,
          }
        : <String, double>{};

    Get.toNamed(
      AppRoute.dietPortionCategories,
      arguments: {
        "patient_id": patientId,
        "patient_name": patientName,
        "doctor_id": doctorId,
        "patient": patient,
        "periods": periods,
        "targets": targets!,
        "exchange_plan": exchangePlan!,
        "exchange_plan_json": exchangePlan!.toJson(),
        "base_servings": baseServingsMap,
        "base_contribution": baseContributionMap,
        "remaining_macros": remainingMap,
      },
    );
  }
}
