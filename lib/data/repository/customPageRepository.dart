import 'package:e_demand/app/generalImports.dart';

class CustomPageRepository {
  Future<List<CustomPageModel>> getCustomPages() async {
    try {
      final response = await ApiClient.post(
        url: ApiUrl.getCustomPages,
        parameter: {
          ApiParam.latitude: HiveRepository.getLatitude,
          ApiParam.longitude: HiveRepository.getLongitude,
        },
        useAuthToken: false,
      );

      final List data = response['data'] ?? [];
      return data
          .map((final e) => CustomPageModel.fromJson(Map.from(e)))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<String> getPageSetting(String pageKey) async {
    try {
      final response = await ApiClient.post(
        url: ApiUrl.getPageSetting,
        parameter: {
          'page': pageKey,
          ApiParam.latitude: HiveRepository.getLatitude,
          ApiParam.longitude: HiveRepository.getLongitude,
        },
        useAuthToken: false,
      );

      final data = response['data'];

      // Since system page returns {"about_us": "<html...>"} and
      // custom page returns {"id": "1", "title": "...", "content": "<html...>"}
      if (data is Map) {
        if (data.containsKey('content')) {
          return data['content'].toString();
        } else if (data.containsKey(pageKey)) {
          return data[pageKey].toString();
        }
      }
      return "";
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
