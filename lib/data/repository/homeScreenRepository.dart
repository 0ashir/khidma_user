import 'package:e_demand/app/generalImports.dart';

class HomeScreenRepository {
  ///This method is used to fetch sectionList
  Future<HomeScreenModel> fetchHomeScreenData({
    required final String latitude,
    required final String longitude,
  }) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        ApiParam.platform: 'app',
        if (latitude.isNotEmpty && latitude != "0.0")
          ApiParam.latitude: latitude,
        if (longitude.isNotEmpty && longitude != "0.0")
          ApiParam.longitude: longitude,
      };

      final result = await ApiClient.post(
        parameter: parameter,
        url: ApiUrl.getHomeScreenData,
        useAuthToken: true,
      );

      final Map data = result['data'] is Map ? result['data'] as Map : {};
      final List slidersJson = data['sliders'] is List
          ? data['sliders'] as List
          : [];
      final List sectionsJson = data['featured_sections'] is List
          ? data['featured_sections'] as List
          : [];

      final List<SliderImage> sliders = slidersJson
          .map((final e) => SliderImage.fromJson(Map<String?, dynamic>.from(e)))
          .toList();

      final List<Sections> sections = sectionsJson
          .map(
            (final rawSection) =>
                Sections.fromJson(Map<String?, dynamic>.from(rawSection)),
          )
          .toList();

      return HomeScreenModel(sections, sliders);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
