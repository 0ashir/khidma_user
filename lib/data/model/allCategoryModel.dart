class AllCategoryModel {
  final String? id;
  final String? name;
  final String? translated_name;
  final String? image;

  AllCategoryModel({
    this.id,
    this.name,
    this.translated_name,
    this.image,
  });

  AllCategoryModel.fromJson(Map<String, dynamic> json)
      : id = json['id']?.toString() ?? '',
        name = json['name']?.toString() ?? '',
        translated_name = (json['translated_name']?.toString() ?? '').isNotEmpty
            ? json['translated_name']!.toString()
            : (json['name']?.toString() ?? ''),
        image = json['image']?.toString() ?? '';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'translated_name': translated_name,
        'image': image
      };
}
