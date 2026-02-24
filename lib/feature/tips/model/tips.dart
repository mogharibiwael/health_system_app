class TipModel {
  final int id;
  final String describtion; // keep backend spelling
  final int? adminId;
  final int? categoryId;
  final String? date;
  final String? createdAt;
  final String? updatedAt;

  TipModel({
    required this.id,
    required this.describtion,
    this.adminId,
    this.categoryId,
    this.date,
    this.createdAt,
    this.updatedAt,
  });

  factory TipModel.fromJson(Map<String, dynamic> json) {
    return TipModel(
      id: (json["id"] ?? 0) as int,
      describtion: (json["describtion"] ?? "").toString(),
      adminId: json["admin_id"] is int ? json["admin_id"] as int : int.tryParse("${json["admin_id"]}"),
      categoryId: json["category_id"] is int ? json["category_id"] as int : int.tryParse("${json["category_id"]}"),
      date: json["date"]?.toString(),
      createdAt: json["created_at"]?.toString(),
      updatedAt: json["updated_at"]?.toString(),
    );
  }
}
