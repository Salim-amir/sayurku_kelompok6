class PromoModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;

  PromoModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });

  factory PromoModel.fromMap(Map<String, dynamic> map, String id) {
    return PromoModel(
      id: id,
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
    };
  }
}