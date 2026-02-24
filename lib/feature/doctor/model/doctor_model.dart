class DoctorModel {
  final int id;
  final String name;
  final String? specialization;
  final String? bio;
  final bool isVerified;
  final bool isAvailable;
  final String rating;
  final String? consultationFee;
  final int? yearsOfExperience;
  final int? userId;


  DoctorModel({
    required this.id,
    required this.name,
    this.specialization,
    this.bio,
    required this.isVerified,
    required this.isAvailable,
    required this.rating,
    this.consultationFee,
    this.yearsOfExperience,
    this.userId
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json["id"] ?? 0,
      userId: json["user_id"] is int ? json["user_id"] : int.tryParse("${json["user_id"]}"),

      name: (json["name"] ?? "-").toString(),
      specialization: json["specialization"]?.toString(),
      bio: json["bio"]?.toString(),
      isVerified: json["is_verified"] == true,
      isAvailable: json["is_available"] == true,
      rating: (json["rating"] ?? "0.00").toString(),
      consultationFee: json["consultation_fee"]?.toString(),
      yearsOfExperience: json["years_of_experience"] is int
          ? json["years_of_experience"]
          : int.tryParse((json["years_of_experience"] ?? "").toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "specialization": specialization,
    "bio": bio,
    "is_verified": isVerified,
    "is_available": isAvailable,
    "rating": rating,
    "consultation_fee": consultationFee,
    "years_of_experience": yearsOfExperience,
  };
}
