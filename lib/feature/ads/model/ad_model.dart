class AdModel {
  final int id;
  final String? title;
  final String? imageUrl;
  final String? link;
  final String? description;

  AdModel({
    required this.id,
    this.title,
    this.imageUrl,
    this.link,
    this.description,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    return AdModel(
      id: _toInt(json["id"]),
      title: json["title"]?.toString(),
      imageUrl: json["image_url"]?.toString() ?? json["image"]?.toString(),
      link: json["link"]?.toString(),
      description: json["description"]?.toString(),
    );
  }
}
