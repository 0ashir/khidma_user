import 'package:e_demand/app/generalImports.dart';

class ProviderRepository {
  /// This method is used to fetch Provider List
  Future<Map<String, dynamic>> fetchProviderList({
    required final bool isAuthTokenRequired,
    final String? categoryId,
    final String? providerIdOrSlug,
    final String? subCategoryId,
    final String? filter,
    final String? promocode,
    final ProviderDetailsParamType? type,
    final int? availableToday,
    final int? maxDuration,
    final String? providerType,
    final String? sortBy,
    final double? ratingMin,
    final double? priceMax,
    final String? search,
    final String? offset,
    final String? limit,
  }) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        ApiParam.latitude: HiveRepository.getLatitude,
        ApiParam.longitude: HiveRepository.getLongitude,
        if (search != null && search.isNotEmpty) ApiParam.search: search.trim(),
        if (offset != null) ApiParam.offset: offset,
        if (limit != null) ApiParam.limit: limit,
      };

      if (categoryId != '' && categoryId != null) {
        parameter[ApiParam.categoryId] = categoryId;
      }
      if (providerIdOrSlug != '' && providerIdOrSlug != null) {
        if (type == ProviderDetailsParamType.slug) {
          parameter[ApiParam.slug] = providerIdOrSlug;
        } else {
          parameter[ApiParam.partnerId] = providerIdOrSlug;
        }
      }
      if (subCategoryId != '' && subCategoryId != null) {
        parameter[ApiParam.subCategoryId] = subCategoryId;
      }
      if (filter != '' && filter != null) {
        parameter[ApiParam.filter] = filter;
        // parameter[Api.order] = "desc";
      }
      if (promocode != '' && promocode != null) {
        parameter[ApiParam.promocode] = promocode;
      }
      if (availableToday != null) {
        parameter[ApiParam.availableToday] = availableToday;
      }
      if (maxDuration != null) {
        parameter[ApiParam.maxDuration] = maxDuration;
      }
      if (providerType != null && providerType.isNotEmpty) {
        parameter[ApiParam.providerType] = providerType;
      }
      if (sortBy != null && sortBy.isNotEmpty) {
        parameter[ApiParam.sortBy] = sortBy;
      }
      if (ratingMin != null) {
        parameter[ApiParam.ratingMin] = ratingMin;
      }
      if (priceMax != null) {
        parameter[ApiParam.priceMax] = priceMax;
      }

      final providers = await ApiClient.post(
        url: ApiUrl.getProviders,
        parameter: parameter,
        useAuthToken: isAuthTokenRequired && HiveRepository.getUserToken != '',
      );
      if (providers['data'] == null || providers['data'] == []) {
        return {
          'totalProviders': "0",
          'providerList': [],
          'serviceMinPrice': null,
          'serviceMaxPrice': null,
        };
      } else {
        return {
          'totalProviders': providers['total'].toString(),
          'providerList': (providers['data'] as List).map((providerData) {
            return Providers.fromJson(providerData);
          }).toList(),
          'serviceMinPrice': providers['service_min_price']?.toString(),
          'serviceMaxPrice': providers['service_max_price']?.toString(),
        };
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// This method is used to fetch a single provider's full details
  Future<ProviderDetailsModel> getProviderDetails({
    final String? slug,
    final String? partnerId,
  }) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        if (slug != null && slug.isNotEmpty) ApiParam.slug: slug,
        if (partnerId != null && partnerId.isNotEmpty)
          ApiParam.partnerId: partnerId,
        ApiParam.latitude: HiveRepository.getLatitude,
        ApiParam.longitude: HiveRepository.getLongitude,
      };

      final response = await ApiClient.post(
        parameter: parameter,
        url: ApiUrl.getProviderDetails,
        useAuthToken: HiveRepository.getUserToken != '',
      );

      return ProviderDetailsModel.fromJson(Map.from(response['data']));
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// This method is used to search Provider
  Future<Map<String, dynamic>> searchProvider({
    required final String searchKeyword,
    required final String offset,
    required final String limit,
  }) async {
    try {
      final parameter = <String, dynamic>{
        ApiParam.latitude: HiveRepository.getLatitude,
        ApiParam.longitude: HiveRepository.getLongitude,
        ApiParam.search: searchKeyword.trim(),
        ApiParam.limit: limit,
        ApiParam.offset: offset,
        ApiParam.type: "provider",
      };

      final providers = await ApiClient.post(
        url: ApiUrl.searchServicesAndProvider,
        parameter: parameter,
        useAuthToken: false,
      );

      return {
        'totalProviders': providers["data"]['total'].toString(),
        'providerList': (providers['data']["providers"] as List).map((
          providerData,
        ) {
          return Providers.fromJson(providerData);
        }).toList(),
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// This method is used to check providers are available at selected latitude longitude
  Future<Map<String, dynamic>> checkProviderAvailability({
    required final String latitude,
    required final String longitude,
    required final String checkingAtCheckOut,
    final String? orderId,
    final String? customJobRequestId,
    final String? bidderId,
    required final bool isAuthTokenRequired,
    final String? providerId,
  }) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        ApiParam.latitude: latitude,
        ApiParam.longitude: longitude,
        ApiParam.isCheckoutProcess: checkingAtCheckOut,
        ApiParam.orderId: orderId,
        ApiParam.customJobRequestId: customJobRequestId,
        ApiParam.bidderId: bidderId,
        if (providerId != null && providerId.isNotEmpty)
          ApiParam.providerId: providerId,
      };
      parameter.removeWhere(
        (key, value) => value == null || value == "null" || value == '',
      );

      final response = await ApiClient.post(
        url: ApiUrl.checkProviderAvailability,
        parameter: parameter,
        useAuthToken: isAuthTokenRequired,
      );
      return {
        'error': response['error'],
        'message': response['message'].toString(),
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// This method is used to request area coverage when no providers are available at the selected location
  Future<Map<String, dynamic>> requestAreaCoverage({
    required final String latitude,
    required final String longitude,
    required final String address,
    required final bool isAuthTokenRequired,
  }) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        ApiParam.latitude: latitude,
        ApiParam.longitude: longitude,
        ApiParam.address: address,
      };

      final response = await ApiClient.post(
        url: ApiUrl.requestAreaCoverage,
        parameter: parameter,
        useAuthToken: isAuthTokenRequired,
      );
      return {
        'error': response['error'],
        'message': response['message'].toString(),
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// This method is to fetch the location-based provider list for map
  Future<List<Providers>> getMapProviderList({
    required String latitude,
    required String longitude,
  }) async {
    try {
      final parameter = <String, dynamic>{
        ApiParam.latitude: latitude,
        ApiParam.longitude: longitude,
      };

      final providers = await ApiClient.post(
        url: ApiUrl.getProviders,
        parameter: parameter,
        useAuthToken: false,
      );

      if (providers['data'] == null) return [];

      return (providers['data'] as List).map((providerData) {
        return Providers.fromJson(Map.from(providerData));
      }).toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
