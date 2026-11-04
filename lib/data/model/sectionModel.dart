import 'package:e_demand/app/generalImports.dart';

class Sections {
  Sections({
    required this.id,
    required this.title,
    required this.translatedTitle,
    required this.sectionType,
    this.providers = const <Providers>[],
    this.services = const <Services>[],
    this.categoryId,
    this.previousBookings = const <BookingListItem>[],
    this.onGoingBookings = const <BookingListItem>[],
    this.offers = const <SliderImage>[],
    this.offersLayoutType,
    this.providersLayoutType,
    this.description,
    this.categories = const <CategoryModel>[],
    this.bannerImage,
    this.bannerType,
  });

  Sections.fromJson(final Map<String?, dynamic> json) {
    id = json['id']?.toString() ?? '';
    title = json['title']?.toString() ?? '';
    translatedTitle = (json['translated_title']?.toString() ?? '').isNotEmpty
        ? json['translated_title']!.toString()
        : (json['title']?.toString() ?? '');
    sectionType = json['section_type']?.toString() ?? '';
    description = json['description']?.toString() ?? '';

    switch (sectionType) {
      case 'top_rated_partner':
      case 'near_by_provider':
      case 'partners':
        final List providersJson = json['providers'] is List
            ? json['providers'] as List
            : [];
        providers = providersJson
            .map((final e) => Providers.fromJson(Map<String?, dynamic>.from(e)))
            .toList();
        providersLayoutType = json['layout_type']?.toString();
      case 'recommended_service':
      case 'popular_service':
      case 'category_wise_service':
        final List servicesJson = json['services'] is List
            ? json['services'] as List
            : [];
        services = servicesJson
            .map((final e) => Services.fromJson(Map<String?, dynamic>.from(e)))
            .toList();
        categoryId = json['category_id']?.toString();
      case 'previous_order':
      case 'ongoing_order':
        final List ordersJson = json['orders'] is List
            ? json['orders'] as List
            : [];
        final List<BookingListItem> orders = ordersJson
            .map(
              (final e) =>
                  BookingListItem.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList();
        if (sectionType == 'previous_order') {
          previousBookings = orders;
        } else {
          onGoingBookings = orders;
        }
      case 'offers':
        final List offersJson = json['offers'] is List
            ? json['offers'] as List
            : [];
        offers = offersJson
            .map(
              (final e) => SliderImage.fromJson(Map<String?, dynamic>.from(e)),
            )
            .toList();
        offersLayoutType = json['layout_type']?.toString() ?? 'one_image';
      case 'all_categories':
      case 'categories':
        final List categoriesJson = json['categories'] is List
            ? json['categories'] as List
            : [];
        categories = categoriesJson
            .map(
              (final e) =>
                  CategoryModel.fromJson(Map<String?, dynamic>.from(e)),
            )
            .toList();
      case 'banner':
        bannerImage = json['image']?.toString() ?? '';
        bannerType = json['banner_type']?.toString() ?? '';
      case 'custom_job_requests':
        break;
      default:
      // other informational sections have no home-screen widget yet.
    }
  }

  String? id;
  String? title;
  String? translatedTitle;
  String? sectionType;
  List<Providers> providers = <Providers>[];
  String? providersLayoutType;
  List<Services> services = <Services>[];
  String? categoryId;
  List<BookingListItem> previousBookings = <BookingListItem>[];
  List<BookingListItem> onGoingBookings = <BookingListItem>[];
  List<SliderImage> offers = <SliderImage>[];
  String? offersLayoutType;
  String? description;
  List<CategoryModel> categories = <CategoryModel>[];
  String? bannerImage;
  String? bannerType;
}
