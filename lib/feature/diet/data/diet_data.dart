import 'package:dartz/dartz.dart';
import '../../../core/class/crud.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/api_link.dart';

class DietData {
  final Crud crud;
  DietData(this.crud);

  /// GET /api/my-diet - Get current active diet plan
  Future<Either<StatusRequest, Map<String, dynamic>>> getMyDiet({
    String? token,
  }) async {
    return await crud.getData(ApiLinks.myDiet, token: token);
  }

  /// GET /api/my-diet/meals - Get diet meals/components
  Future<Either<StatusRequest, Map<String, dynamic>>> getMyDietMeals({
    String? token,
  }) async {
    return await crud.getData(ApiLinks.myDietMeals, token: token);
  }

  /// POST /api/diet-plans - Create/assign diet plan (for doctors)
  /// Supports doctor_notes (array of strings) and meals (type, name, macros, servings) per developer_api_guide.
  Future<Either<StatusRequest, Map<String, dynamic>>> createDietPlan({
    required int patientId,
    required int doctorId,
    required String title,
    required int dailyCalories,
    required int durationDays,
    required String startDate,
    required String endDate,
    List<Map<String, dynamic>>? meals,
    List<String>? doctorNotes,
    String? token,
  }) async {
    final body = {
      "patient_id": patientId,
      "doctor_id": doctorId,
      "title": title,
      "daily_calories": dailyCalories,
      "duration_days": durationDays,
      "start_date": startDate,
      "end_date": endDate,
      if (meals != null && meals.isNotEmpty) "meals": meals,
      if (doctorNotes != null && doctorNotes.isNotEmpty) "doctor_notes": doctorNotes,
    };
    return await crud.postData(ApiLinks.dietPlans, body, token: token);
  }
}
