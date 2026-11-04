import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class BookmarkRepository {
  ///This method is used to fetch available Bookmark from database.
  ///Pass [bookmarkType] as `provider` (default) or `service` to select
  ///which model the response rows are parsed into.
  Future<Map<String, dynamic>> getBookmark({
    required final bool isAuthTokenRequired,
    required final Map<String, dynamic> parameter,
    final String bookmarkType = "provider",
  }) async {
    try {
      final response = await ApiClient.post(
        parameter: parameter,
        url: ApiUrl.bookMark,
        useAuthToken: isAuthTokenRequired,
      );
      final List<dynamic> data = response['data'] as List;
      return {
        "bookmark": bookmarkType == "service"
            ? data.map((final e) => Services.fromJson(Map.from(e))).toList()
            : data.map((final e) => Providers.fromJson(Map.from(e))).toList(),
        "totalBookmark": (response['total'] ?? "0").toString(),
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future _setBookmark({
    required final String type,
    final String? providerID,
    final String? serviceId,
  }) async {
    final Map<String, dynamic> parameter = <String, dynamic>{
      if (serviceId != null) ApiParam.serviceId: serviceId,
      if (providerID != null) ApiParam.partnerId: providerID,
      ApiParam.bookmarkType: serviceId != null ? "service" : "provider",
      ApiParam.type: type,
    };
    try {
      return await ApiClient.post(
        url: ApiUrl.bookMark,
        parameter: parameter,
        useAuthToken: true,
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future addBookmark({
    required final bool isAuthTokenRequired,
    final String? providerID,
    final String? serviceId,
    required final BuildContext context,
  }) => _setBookmark(type: "add", providerID: providerID, serviceId: serviceId);

  Future removeBookmark({
    required final bool isAuthTokenRequired,
    final String? providerID,
    final String? serviceId,
    required final BuildContext context,
  }) => _setBookmark(
    type: "remove",
    providerID: providerID,
    serviceId: serviceId,
  );
}
