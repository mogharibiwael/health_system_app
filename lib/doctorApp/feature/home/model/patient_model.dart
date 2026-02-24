class PatientModel {
  final int id;
  final String fullname;
  final String? gender;
  final double? height;
  final double? weight;
  final String? phoneNumber;
  final String? image;
  final String? birthdate;
  final String? physicalActivity;
  final String? medical;
  /// Carbohydrates (g per day) - set by doctor
  final double? carbohydrates;
  /// Fats (g per day) - set by doctor
  final double? fats;
  /// Protein (g per day) - set by doctor
  final double? protein;

  final int userId;
  final PatientUserModel? user;

  PatientModel({
    required this.id,
    required this.fullname,
    required this.userId,
    this.gender,
    this.height,
    this.weight,
    this.phoneNumber,
    this.image,
    this.birthdate,
    this.physicalActivity,
    this.medical,
    this.carbohydrates,
    this.fats,
    this.protein,
    this.user,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    int _toInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    return PatientModel(
      id: _toInt(json["id"]),
      fullname: (json["fullname"] ?? "-").toString(),
      gender: json["gender"]?.toString(),
      height: _toDouble(json["height"]),
      weight: _toDouble(json["weight"]),
      phoneNumber: json["phone_number"]?.toString(),
      image: json["image"]?.toString(),
      birthdate: json["birthdate"]?.toString(),
      physicalActivity: json["physical_activity"]?.toString(),
      medical: json["medical"]?.toString(),
      carbohydrates: _toDouble(json["carbohydrates"]),
      fats: _toDouble(json["fats"]),
      protein: _toDouble(json["protein"]),
      userId: _toInt(json["user_id"]),
      user: (json["user"] is Map)
          ? PatientUserModel.fromJson(Map<String, dynamic>.from(json["user"]))
          : null,
    );
  }

  PatientModel copyWith({
    double? carbohydrates,
    double? fats,
    double? protein,
  }) {
    return PatientModel(
      id: id,
      fullname: fullname,
      userId: userId,
      gender: gender,
      height: height,
      weight: weight,
      phoneNumber: phoneNumber,
      image: image,
      birthdate: birthdate,
      physicalActivity: physicalActivity,
      medical: medical,
      carbohydrates: carbohydrates ?? this.carbohydrates,
      fats: fats ?? this.fats,
      protein: protein ?? this.protein,
      user: user,
    );
  }
}

class PatientUserModel {
  final int id;
  final String name;
  final String email;
  final String? role;

  PatientUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role,
  });

  factory PatientUserModel.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    return PatientUserModel(
      id: _toInt(json["id"]),
      name: (json["name"] ?? "-").toString(),
      email: (json["email"] ?? "-").toString(),
      role: json["role"]?.toString(),
    );
  }
}
