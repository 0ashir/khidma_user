class CategoryModel {
  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.categoryImage,
    required this.backgroundDarkColor,
    required this.backgroundLightColor,
    this.totalProviders,
    this.childrenCount,
    this.totalServices,
  });

  CategoryModel.fromJson(final Map<String?, dynamic> json) {
    id = json["id"]?.toString() ?? '';
    name = json["name"]?.toString() ?? '';
    slug = json["slug"]?.toString() ?? '';
    //the "categories" home-screen section sends this under "image" instead
    //of "category_image" (used by "all_categories" and elsewhere) — same
    //model parses both section types' items.
    categoryImage = (json["category_image"]?.toString() ?? '').isNotEmpty
        ? json["category_image"].toString()
        : (json["image"]?.toString() ?? '');
    backgroundLightColor = json['light_color']?.toString() ?? '';
    backgroundDarkColor = json['dark_color']?.toString() ?? '';
    totalProviders = json['total_providers']?.toString() ?? '';
    childrenCount = json['children_count']?.toString() ?? '';
    totalServices = json['total_services']?.toString() ?? '';
  }

  String? id;
  String? name;
  String? slug;
  String? categoryImage;
  String? backgroundDarkColor;
  String? backgroundLightColor;
  String? totalProviders;
  String? childrenCount;
  String? totalServices;
}
