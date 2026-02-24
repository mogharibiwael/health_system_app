class ForumModel {
  final int id;
  final String name;
  final String? description;
  final String? createdAt;

  ForumModel({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
  });

  factory ForumModel.fromJson(Map<String, dynamic> json) {
    return ForumModel(
      id: (json["id"] is int) ? json["id"] : int.tryParse("${json["id"]}") ?? 0,
      name: (json["name"] ?? "-").toString(),
      description: json["description"]?.toString(),
      createdAt: json["created_at"]?.toString(),
    );
  }
}
