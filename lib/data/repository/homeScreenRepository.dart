import 'package:e_demand/app/generalImports.dart';

/// Raw home response plus its parsed model.
class HomeScreenResponse {
  const HomeScreenResponse({required this.model, required this.fingerprint});

  final HomeScreenModel model;

  /// Encoded `data`, used to skip UI updates when nothing changed.
  final String fingerprint;
}

class HomeScreenRepository {
  Map<String, dynamic> _parameter(
    final String latitude,
    final String longitude,
  ) => <String, dynamic>{
    ApiParam.platform: 'app',
    if (latitude.isNotEmpty && latitude != "0.0") ApiParam.latitude: latitude,
    if (longitude.isNotEmpty && longitude != "0.0")
      ApiParam.longitude: longitude,
  };

  String _cacheKey(final String latitude, final String longitude) =>
      ApiResponseCache.keyFor(
        ApiUrl.getHomeScreenData,
        _parameter(latitude, longitude),
      );

  static HomeScreenModel parse(final Map data) {
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
  }

  /// Last saved home data for this location / language / user, if any.
  HomeScreenResponse? cachedHomeScreenData({
    required final String latitude,
    required final String longitude,
  }) {
    final Map<String, dynamic>? data = ApiResponseCache.read(
      _cacheKey(latitude, longitude),
    );
    if (data == null) return null;
    try {
      return HomeScreenResponse(
        model: parse(data),
        fingerprint: ApiResponseCache.fingerprint(data),
      );
    } catch (_) {
      return null; // Unreadable (e.g. older format): fetch fresh instead.
    }
  }

  /// Fetches from the server and saves the response for the next launch.
  Future<HomeScreenResponse> fetchHomeScreenResponse({
    required final String latitude,
    required final String longitude,
  }) async {
    try {
      final Map<String, dynamic> parameter = _parameter(latitude, longitude);
      final String cacheKey = _cacheKey(latitude, longitude);

      final result = await ApiClient.post(
        parameter: parameter,
        url: ApiUrl.getHomeScreenData,
        useAuthToken: true,
      );

      final Map<String, dynamic> data = result['data'] is Map
          ? Map<String, dynamic>.from(result['data'] as Map)
          : <String, dynamic>{};
      final HomeScreenModel model = parse(data);
      ApiResponseCache.write(cacheKey, data);
      return HomeScreenResponse(
        model: model,
        fingerprint: ApiResponseCache.fingerprint(data),
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  ///This method is used to fetch sectionList
  Future<HomeScreenModel> fetchHomeScreenData({
    required final String latitude,
    required final String longitude,
  }) async => (await fetchHomeScreenResponse(
    latitude: latitude,
    longitude: longitude,
  )).model;
}
