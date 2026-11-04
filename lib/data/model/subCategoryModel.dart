class SubCategory {
  SubCategory({
    this.id,
    this.name,
    this.slug,
    this.categoryImage,
    this.darkBackgroundColor,
    this.lightBackgroundColor,
    this.totalProviders,
    this.totalServices,
    this.childrenCount,

  });

  SubCategory.fromJson(final Map<String, dynamic> json)
    : id = json["id"]?.toString() ?? '',
      name = json["name"]?.toString() ?? '',
      slug = json["slug"]?.toString() ?? '',
      darkBackgroundColor = json["dark_color"]?.toString() ?? '',
      lightBackgroundColor = json["light_color"]?.toString() ?? '',
      categoryImage = json["category_image"]?.toString() ?? '',
      totalProviders = json["total_providers"]?.toString() ?? '0',
      totalServices = json["total_services"]?.toString() ?? '0',
      childrenCount = json["children_count"]?.toString() ?? '0';
  final String? id;
  final String? name;
  final String? slug;
  final String? categoryImage;
  final String? darkBackgroundColor;
  final String? lightBackgroundColor;
  final String? totalProviders;
  final String? totalServices;
  final String? childrenCount;

}
