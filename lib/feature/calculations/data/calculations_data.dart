import 'package:dartz/dartz.dart';
import '../../../core/class/crud.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/api_link.dart';

/// Per developer_api_guide: POST /api/calculations/nutrition
/// Returns BMI, BMR, TEF, TDEE, and macros in one request.
class CalculationsData {
  final Crud crud;
  CalculationsData(this.crud);

  /// POST /api/calculations/nutrition
  /// Body: weight, height, age, gender, activity_level, goal, save (optional)
  /// activity_level: "sedentary" | "low" | "moderate" | "active" | "very_active"
  /// goal: "maintain" | "lose" | "gain"
  Future<Either<StatusRequest, Map<String, dynamic>>> nutrition({
    required double weight,
    required double height,
    required int age,
    required String gender,
    required String activityLevel,
    String goal = "maintain",
    bool save = false,
    String? token,
  }) async {
    final body = {
      "weight": weight,
      "height": height,
      "age": age,
      "gender": gender,
      "activity_level": activityLevel,
      "goal": goal,
      "save": save,
    };
    return await crud.postData(ApiLinks.calculationsNutrition, body, token: token);
  }
}
