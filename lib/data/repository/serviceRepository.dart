import 'package:e_demand/app/generalImports.dart';

class ServiceRepository {
  ///This method is used to fetch available services form database
  Future<Map<String, dynamic>> getServices({
    required final String offset,
    required final String limit,
    required final bool isAuthTokenRequired,
    required final ProviderDetailsParamType type,
    required final String providerIdOrSlug,
    final String? search,
    final String? categoryIds,
    final String? categorySlugs,
    final double? priceMin,
    final double? priceMax,
    final double? ratingMin,
    final int? durationMin,
    final int? durationMax,
    final String? sortBy,
    final String? serviceMode,
    final int? payLaterAllowed,
  }) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        ApiParam.latitude: HiveRepository.getLatitude,
        ApiParam.longitude: HiveRepository.getLongitude,
        if (type == ProviderDetailsParamType.slug)
          ApiParam.providerSlug: providerIdOrSlug
        else
          ApiParam.providerId: providerIdOrSlug,
        ApiParam.limit: limit,
        ApiParam.offset: offset,
        if (search != null && search.isNotEmpty) ApiParam.search: search.trim(),
        if (categoryIds != null && categoryIds.isNotEmpty)
          ApiParam.categoryIds: categoryIds,
        if (categorySlugs != null && categorySlugs.isNotEmpty)
          ApiParam.categorySlugs: categorySlugs,
        if (priceMin != null) ApiParam.priceMin: priceMin,
        if (priceMax != null) ApiParam.priceMax: priceMax,
        if (ratingMin != null) ApiParam.ratingMin: ratingMin,
        if (durationMin != null) ApiParam.durationMin: durationMin,
        if (durationMax != null) ApiParam.durationMax: durationMax,
        if (sortBy != null && sortBy.isNotEmpty) ApiParam.sortBy: sortBy,
        if (serviceMode != null && serviceMode.isNotEmpty)
          ApiParam.serviceMode: serviceMode,
        if (payLaterAllowed != null) ApiParam.payLaterAllowed: payLaterAllowed,
      };

      final response = await ApiClient.post(
        parameter: parameter,
        url: ApiUrl.getServices,
        useAuthToken: isAuthTokenRequired,
      );

      return {
        "serviceCategories": _parseServiceCategories(
          response['data'] is List ? response['data'] as List : [],
        ),
        "totalServices": response['total'],
        "serviceMaxPrice":
            response['service_max_price'] ?? response['max_price'],
        "serviceMinPrice": response['service_min_price'],
        "otherServices": _parseServiceCategories(
          response['other_services'] is List
              ? response['other_services'] as List
              : [],
        ),
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  List<ServiceCategoryGroup> _parseServiceCategories(final List data) {
    if (data.isEmpty) return [];

    final bool isGrouped = (data.first as Map).containsKey('services');
    if (isGrouped) {
      return data
          .map(
            (final e) =>
                ServiceCategoryGroup.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
    }

    final List<Services> flatServices = data
        .map((final e) => Services.fromJson(Map.from(e)))
        .toList();
    final Map<String, String> categoryNames = <String, String>{};
    final Map<String, List<Services>> servicesByCategory =
        <String, List<Services>>{};
    for (final Services service in flatServices) {
      final String key = service.categoryId ?? '';
      categoryNames.putIfAbsent(key, () => service.categoryName ?? '');
      servicesByCategory.putIfAbsent(key, () => []).add(service);
    }
    return servicesByCategory.entries
        .map(
          (final entry) => ServiceCategoryGroup(
            categoryId: entry.key,
            categoryName: categoryNames[entry.key] ?? '',
            totalServices: entry.value.length,
            services: entry.value,
          ),
        )
        .toList();
  }

  ///Fetches a flat list of services within a category, across all
  ///providers (no `provider_id`/`provider_slug` sent) — used by the
  ///category-details "services" view (`category_details_view_type` setting).
  Future<Map<String, dynamic>> getServicesForCategory({
    required final String offset,
    required final String limit,
    final String? categoryId,
    final String? search,
    final String? sortBy,
    final int? payLaterAllowed,
    final double? priceMax,
    final double? ratingMin,
    final int? durationMin,
    final int? durationMax,
    final String? serviceMode,
    final int? availableToday,
  }) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        ApiParam.latitude: HiveRepository.getLatitude,
        ApiParam.longitude: HiveRepository.getLongitude,
        ApiParam.limit: limit,
        ApiParam.offset: offset,
        if (categoryId != null && categoryId.isNotEmpty)
          ApiParam.categoryIds: categoryId,
        if (search != null && search.isNotEmpty) ApiParam.search: search.trim(),
        if (sortBy != null && sortBy.isNotEmpty) ApiParam.sortBy: sortBy,
        if (payLaterAllowed != null) ApiParam.payLaterAllowed: payLaterAllowed,
        if (priceMax != null) ApiParam.priceMax: priceMax,
        if (ratingMin != null) ApiParam.ratingMin: ratingMin,
        if (durationMin != null) ApiParam.durationMin: durationMin,
        if (durationMax != null) ApiParam.durationMax: durationMax,
        if (serviceMode != null && serviceMode.isNotEmpty)
          ApiParam.serviceMode: serviceMode,
        if (availableToday != null) ApiParam.availableToday: availableToday,
      };

      final response = await ApiClient.post(
        parameter: parameter,
        url: ApiUrl.getServices,
        useAuthToken: HiveRepository.getUserToken != '',
      );

      final List rawServices = response['data'] is List
          ? response['data'] as List
          : [];

      return {
        "services": rawServices
            .map((final e) => Services.fromJson(Map<String?, dynamic>.from(e)))
            .toList(),
        "totalServices": response['total'],
        "serviceMinPrice":
            response['service_min_price'] ?? response['min_price'],
        "serviceMaxPrice":
            response['service_max_price'] ?? response['max_price'],
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<ServiceDetailsModel> getServiceDetails({
    final String? id,
    final String? slug,
  }) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        if (id != null && id.isNotEmpty) ApiParam.id: id,
        if (slug != null && slug.isNotEmpty) ApiParam.slug: slug,
        ApiParam.latitude: HiveRepository.getLatitude,
        ApiParam.longitude: HiveRepository.getLongitude,
      };

      final response = await ApiClient.post(
        parameter: parameter,
        url: ApiUrl.getServiceDetails,
        useAuthToken: HiveRepository.getUserToken != '',
      );

      return ServiceDetailsModel.fromJson(Map.from(response['data']));
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  ///This method is used to search services
  Future<Map<String, dynamic>> searchServicesWithProviders({
    required final String offset,
    required final String limit,
    required final bool isAuthTokenRequired,
    required String searchText,
  }) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        ApiParam.latitude: HiveRepository.getLatitude,
        ApiParam.longitude: HiveRepository.getLongitude,
        ApiParam.search: searchText.trim(),
        ApiParam.type: "service",
        ApiParam.limit: limit,
        ApiParam.offset: offset,
      };

      final response = await ApiClient.post(
        parameter: parameter,
        url: ApiUrl.searchServicesAndProvider,
        useAuthToken: isAuthTokenRequired,
      );

      if (response.isEmpty) {
        return {"providersWithServices": [], "totalProvidersWithServices": 0};
      }
      return {
        "providersWithServices": (response['data']["Services"] as List).map((
          final e,
        ) {
          final Providers provider = Providers.fromJson(
            Map.from(e["provider"]),
          );
          return provider;
        }).toList(),
        "totalProvidersWithServices": response["data"]['total'],
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
