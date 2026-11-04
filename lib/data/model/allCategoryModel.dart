class AllCategoryModel {
  final String? id;
  final String? name;
  final String? translated_name;
  final String? image;
  final int? servicesCount;
  final List<AllCategoryModel>? subCategories;

  AllCategoryModel({
    this.id,
    this.name,
    this.translated_name,
    this.image,
    this.servicesCount,
    this.subCategories,
  });

  AllCategoryModel.fromJson(Map<String, dynamic> json)
    : id = json['id']?.toString() ?? '',
      name = (json['name'] ?? json['category_name'])?.toString() ?? '',
      translated_name = (json['translated_name']?.toString() ?? '').isNotEmpty
          ? json['translated_name'].toString()
          : (json['name'] ?? json['category_name'])?.toString() ?? '',
      image = json['image']?.toString() ?? '',
      servicesCount =
          int.tryParse(json['services_count']?.toString() ?? '') ?? 0,
      subCategories = json['children'] is List
          ? (json['children'] as List)
                .whereType<Map>()
                .map(
                  (e) =>
                      AllCategoryModel.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'translated_name': translated_name,
    'image': image,
    'services_count': servicesCount,
    'children': subCategories?.map((e) => e.toJson()).toList(),
  };
}
