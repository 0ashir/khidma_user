///Same model is used for the Slider Image & banner of featured sections in Home Screen
class SliderImage {
  SliderImage({
    required this.id,
    required this.type,
    required this.typeId,
    required this.sliderImage,
    required this.categoryName,
    required this.providerName,
    required this.url,
  });

  SliderImage.fromJson(final Map<String?, dynamic> json) {
    id = json["id"]?.toString() ?? '';
    final String rawType = (json["type"]?.toString() ?? '').toLowerCase();
    type = switch (rawType) {
      'category' => SliderImagesType.category,
      'sub_category' || 'subcategory' => SliderImagesType.subCategory,
      'provider' => SliderImagesType.provider,
      'url' => SliderImagesType.url,
      _ =>
        json["link"] != null
            ? SliderImagesType.url
            : SliderImagesType.defaultType,
    };
    typeId = json["type_id"]?.toString() ?? '';
    sliderImage =
        json["slider_app_image"]?.toString() ??
        json["slider_web_image"]?.toString() ??
        json["image"]?.toString() ??
        '';
    categoryName = json["category_name"]?.toString() ?? '';
    providerName = json["provider_name"]?.toString() ?? '';
    url = json["url"]?.toString() ?? json["link"]?.toString() ?? '';
  }

  String? id;
  SliderImagesType? type;
  String? typeId;
  String? sliderImage;
  String? categoryName;
  String? providerName;
  String? url;
}

enum SliderImagesType { category, subCategory, provider, url, defaultType }
