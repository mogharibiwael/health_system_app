class DietModel {
  final int id;
  final int? patientId;
  final int? doctorId;
  final String? doctorName;
  final String title;
  final int dailyCalories;
  final int durationDays;
  final String startDate;
  final String endDate;
  final String? notes;
  final List<DietMealModel> meals;
  final String? createdAt;

  DietModel({
    required this.id,
    this.patientId,
    this.doctorId,
    this.doctorName,
    required this.title,
    required this.dailyCalories,
    required this.durationDays,
    required this.startDate,
    required this.endDate,
    this.notes,
    this.meals = const [],
    this.createdAt,
  });

  factory DietModel.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    String? _extractDoctorName(Map<String, dynamic> json) {
      if (json["doctor"] is Map) {
        return (json["doctor"] as Map)["name"]?.toString();
      }
      return json["doctor_name"]?.toString();
    }

    List<DietMealModel> mealsList = [];
    if (json["meals"] is List) {
      mealsList = (json["meals"] as List)
          .map((e) => DietMealModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return DietModel(
      id: _toInt(json["id"]),
      patientId: json["patient_id"] != null ? _toInt(json["patient_id"]) : null,
      doctorId: json["doctor_id"] != null ? _toInt(json["doctor_id"]) : null,
      doctorName: _extractDoctorName(json),
      title: (json["title"] ?? "").toString(),
      dailyCalories: _toInt(json["daily_calories"] ?? 0),
      durationDays: _toInt(json["duration_days"] ?? 0),
      startDate: (json["start_date"] ?? "").toString(),
      endDate: (json["end_date"] ?? "").toString(),
      notes: json["notes"]?.toString(),
      meals: mealsList,
      createdAt: json["created_at"]?.toString(),
    );
  }
}

class DietMealModel {
  final int id;
  final int dayNumber;
  final String mealType; // breakfast, lunch, dinner, snack
  final String mealName;
  final int calories;

  DietMealModel({
    required this.id,
    required this.dayNumber,
    required this.mealType,
    required this.mealName,
    required this.calories,
  });

  factory DietMealModel.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    return DietMealModel(
      id: _toInt(json["id"] ?? 0),
      dayNumber: _toInt(json["day_number"] ?? 0),
      mealType: (json["meal_type"] ?? "").toString(),
      mealName: (json["meal_name"] ?? "").toString(),
      calories: _toInt(json["calories"] ?? 0),
    );
  }

  String get mealTypeDisplay {
    switch (mealType.toLowerCase()) {
      case "breakfast":
        return "Breakfast";
      case "lunch":
        return "Lunch";
      case "dinner":
        return "Dinner";
      case "snack":
        return "Snack";
      default:
        return mealType;
    }
  }
}
