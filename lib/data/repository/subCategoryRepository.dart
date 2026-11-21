import 'package:e_demand/app/generalImports.dart';

class SubCategoryRepository {
  static Map<String, dynamic> _parameters(final String categoryID) =>
      <String, dynamic>{
        ApiParam.categoryId: categoryID,
        ApiParam.longitude: HiveRepository.getLongitude,
        ApiParam.latitude: HiveRepository.getLatitude,
      };

  static Map<String, dynamic> _parse(final Map<String, dynamic> result) => {
    "subCategoryList": (result['data'] as List)
        .map(
          (final subCategoryData) =>
              SubCategory.fromJson(Map.from(subCategoryData)),
        )
        .toList(),
    "fingerprint": ApiResponseCache.fingerprint(result),
  };

  /// Last saved subcategories of [categoryID] at this location (same shape
  /// as [fetchSubCategory]), or null.
  Map<String, dynamic>? cachedSubCategory({required final String categoryID}) {
    final Map<String, dynamic>? raw = ApiResponseCache.read(
      ApiResponseCache.keyFor(
        ApiUrl.getSubCategories,
        _parameters(categoryID),
        userSpecific: false,
      ),
    );
    if (raw == null) return null;
    try {
      return _parse(raw);
    } catch (_) {
      return null;
    }
  }

  ///This method is used to fetch subCategories
  Future<Map<String, dynamic>> fetchSubCategory({
    required final bool isAuthTokenRequired,
    required final String categoryID,

    /// Save the response for [cachedSubCategory].
    final bool saveToCache = false,
  }) async {
    try {
      final Map<String, dynamic> parameters = _parameters(categoryID);

      final Map<String, dynamic> result = Map<String, dynamic>.from(
        await ApiClient.post(
          url: ApiUrl.getSubCategories,
          parameter: parameters,
          useAuthToken: false,
        ),
      );
      final Map<String, dynamic> parsed = _parse(result);
      if (saveToCache) {
        ApiResponseCache.write(
          ApiResponseCache.keyFor(
            ApiUrl.getSubCategories,
            parameters,
            userSpecific: false,
          ),
          result,
        );
      }
      return parsed;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
