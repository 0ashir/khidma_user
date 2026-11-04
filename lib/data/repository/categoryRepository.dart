import 'package:e_demand/app/generalImports.dart';

class CategoryRepository {
  ///This method is used to fetch categories
  Future<List<CategoryModel>> fetchCategory({
    final int? limitOfAPIData,
    final int? offset,
    final String? search,
  }) async {
    try {
      final Map<String, dynamic> parameters = <String, dynamic>{
        ApiParam.longitude: HiveRepository.getLongitude,
        // HiveRepository.getLongitude,
        ApiParam.latitude: HiveRepository.getLatitude,
        if (limitOfAPIData != null) ApiParam.limit: limitOfAPIData,
        if (offset != null) ApiParam.offset: offset,
        if (search != null && search.isNotEmpty) ApiParam.search: search,
      };
      final result = await ApiClient.post(
        parameter: parameters,
        url: ApiUrl.getCategories,
        useAuthToken: false,
      );

      return (result['data'] as List)
          .map((final e) => CategoryModel.fromJson(Map.from(e)))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future fetchAllCategory({final String? providerId}) async {
    try {
      final Map<String, dynamic> parameters = <String, dynamic>{
        if (providerId != null && providerId.isNotEmpty)
          ApiParam.providerId: providerId,
      };
      final result = await ApiClient.post(
        parameter: parameters,
        url: ApiUrl.getCategoryHierarchical,
        useAuthToken: true,
      );

      return (result['data'] as List)
          .map((final e) => AllCategoryModel.fromJson(Map.from(e)))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
