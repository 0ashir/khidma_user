import 'package:e_demand/app/generalImports.dart';

class MyRequestRepository {
  Future<Map<String, dynamic>> submitCustomJobRequest({
    required Map<String, dynamic> parameters,
  }) async {
    try {
      final response = await ApiClient.post(
        parameter: parameters,
        url: ApiUrl.makeCustomJobRequest,
        useAuthToken: true,
      );
      return response;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> fetchMyCustomJobRequests({
    final String? status,
    final dynamic limit,
    final dynamic offset,
  }) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        if (status != null) ApiParam.status: status,
        if (limit != null) ApiParam.limit: limit,
        if (offset != null) ApiParam.offset: offset,
      };
      final response = await ApiClient.post(
        parameter: parameter,
        url: ApiUrl.myCustomJobRequests,
        useAuthToken: true,
      );
      return {
        "data": (response['data'] as List)
            .map(
              (final e) =>
                  MyRequestListModel.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList(),
        "total": int.tryParse(response['total']?.toString() ?? '') ?? 0,
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<CustomJob> fetchCustomJobRequestDetails({
    required final String id,
  }) async {
    try {
      final response = await ApiClient.post(
        parameter: {ApiParam.id: id},
        url: ApiUrl.customJobRequestDetails,
        useAuthToken: true,
      );
      return CustomJob.fromJson(Map<String, dynamic>.from(response['data']));
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future cancelMyBooking({
    required String customJobRequestId,
    String? cancelReasonId,
    String? additionalInfo,
  }) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        ApiParam.customJobRequestId: customJobRequestId,
        if (cancelReasonId != null) ApiParam.cancelReasonId: cancelReasonId,
        if (additionalInfo != null && additionalInfo.isNotEmpty)
          ApiParam.additionalInfo: additionalInfo,
      };
      final response = await ApiClient.post(
        parameter: parameter,
        url: ApiUrl.cancelCustomJobRequest,
        useAuthToken: true,
      );
      if (response['error'] == 'true') {
        return {"error": response['error'], "message": response['message']};
      }
      return response;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<BidProvider>> fetchCustomJobRequestProviders({
    required final String customJobRequestId,
    final String? sortBy,
    final String? latitude,
    final String? longitude,
  }) async {
    try {
      final Map<String, dynamic> parameter = {
        ApiParam.id: customJobRequestId,
        ApiParam.latitude: latitude ?? HiveRepository.getLatitude,
        ApiParam.longitude: longitude ?? HiveRepository.getLongitude,
      };
      if (sortBy != null && sortBy.isNotEmpty) {
        parameter[ApiParam.sortBy] = sortBy;
      }
      final response = await ApiClient.post(
        parameter: parameter,
        url: ApiUrl.customJobRequestProviders,
        useAuthToken: true,
      );
      final List<dynamic> raw = response['data'] is List
          ? response['data']
          : (response['data']?['providers'] ??
                response['data']?['bidders'] ??
                []);
      return raw
          .map((e) => BidProvider.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<BidProvider> getUserBidderFromBidderId({
    required final bool useAuthToken,
    required final String customJobRequestId,
    required final String bidderId,
  }) async {
    try {
      final providers = await fetchCustomJobRequestProviders(
        customJobRequestId: customJobRequestId,
      );

      if (providers.length == 1) {
        return providers.first;
      }

      for (var provider in providers) {
        if (provider.providerId.toString() == bidderId.toString() ||
            provider.customJobId.toString() == bidderId.toString()) {
          return provider;
        }
      }

      throw ApiException('Bidder not found');
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
