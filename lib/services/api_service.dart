import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fixit_user/config.dart';
import 'package:http/http.dart' as http;
import '../screens/app_pages_screens/server_error_screen/server_error.dart';
import 'environment.dart';
import 'error/exceptions.dart';
import 'google_translation_service.dart';

class ApiServices {
  static var client = http.Client();
  final dio = Dio()
    ..interceptors.add(_LanguageInterceptor())
    ..interceptors.add(TranslationResponseInterceptor());
  static List<Map<String, String>> conversationHistory = [];

  //to get full path with paramiters
  static Future<String> getFullUrl(String apiName, List params) async {
    String url0 = "";
    if (params.isNotEmpty) {
      url0 = "$apiName?";
      for (int i = 0; i < params.length; i++) {
        url0 = '$url0${params[i]["key"]}=${params[i]["value"]}';
        if (i + 1 != params.length) url0 = "$url0&";
      }
    } else {
      url0 = apiName;
    }

    String url = '$apiUrl$url0';

    return url;
  }

  /*  Future<APIDataClass> dioException(e) async {
    APIDataClass apiData =
        APIDataClass(message: 'No data', isSuccess: false, data: '0');
    if (e is DioException) {
      log("EROROROROROR :${e.type}");
      if (e.type == DioExceptionType.badResponse) {
        final response = e.response;
        if (response!.statusCode == 403) {
          apiData.message = response.data.toString();
          apiData.isSuccess = false;
          apiData.data = response.statusCode;

          return apiData;
        } else {
          if (response.data != null) {
            apiData.message = response.data['message'];
            apiData.isSuccess = false;
            apiData.data = 0;
            return apiData;
          } else {
            log("EROROROROROR :$response");
            apiData.message = response.data.toString();
            apiData.isSuccess = false;
            apiData.data = 0;
            return apiData;
          }
        }
      } else {
        final response = e.response;
        if (response != null && response.data != null) {
          final Map responseData = json.decode(response.data as String) as Map;
          apiData.message = responseData['message'] as String;
          apiData.isSuccess = false;
          apiData.data = 0;
          return apiData;
        } else {
          log("EROROROROROR :${response!.statusCode}");
          apiData.message = response!.statusCode.toString();
          apiData.isSuccess = false;
          apiData.data = 0;
          return apiData;
        }
      }
    } else {
      log("EROROROROROR :$apiData.message");
      apiData.message = "";
      apiData.isSuccess = false;
      apiData.data = 0;
      return apiData;
    }
  } */

  Future<APIDataClass> dioException(e) async {
    APIDataClass apiData =
        APIDataClass(message: 'No data', isSuccess: false, data: '0');

    if (e is DioException) {
      log("ERROR TYPE : ${e.type}");

      final response = e.response;

      if (e.type == DioExceptionType.badResponse && response != null) {
        if (response.statusCode == 403) {
          apiData.message = response.data.toString();
          apiData.isSuccess = false;
          apiData.data = response.statusCode ?? 0;
          return apiData;
        } else {
          if (response.data != null) {
            if (response.data is Map && response.data['message'] != null) {
              apiData.message = response.data['message'].toString();
            } else {
              apiData.message = response.data.toString();
            }
            apiData.isSuccess = false;
            apiData.data = response.statusCode ?? 0;
            return apiData;
          }
        }
      } else {
        if (response != null && response.data != null) {
          try {
            if (response.data is String) {
              final Map responseData = json.decode(response.data) as Map;
              apiData.message =
                  responseData['message']?.toString() ?? "Unknown error";
            } else if (response.data is Map) {
              apiData.message =
                  response.data['message']?.toString() ?? "Unknown error";
            } else {
              apiData.message = response.data.toString();
            }
          } catch (err) {
            apiData.message = "Parsing error: $err";
          }
          apiData.isSuccess = false;
          apiData.data = response.statusCode ?? 0;
          return apiData;
        } else {
          log("ERROR: Response is null");
          apiData.message = "Unknown network error";
          apiData.isSuccess = false;
          apiData.data = 0;
          return apiData;
        }
      }
    }

    // Non-DioException case
    log("ERROR (non-Dio): $e");
    apiData.message = e.toString();
    apiData.isSuccess = false;
    apiData.data = 0;
    return apiData;
  }

  Future<APIDataClass> getApi(
    String apiName,
    dynamic params, {
    isToken = false,
    isData = false,
    isMessage = true,
  }) async {
    //default data to class
    APIDataClass apiData = APIDataClass(
      message: 'No data',
      isSuccess: false,
      data: '0',
    );
    //Check For Internet
    bool isInternet = await isNetworkConnection();
    if (!isInternet) {
      apiData.message = "No Internet Access";
      apiData.isSuccess = false;
      apiData.data = 0;
      return apiData;
    } else {
      log("URL Name For Call: $apiName");

      try {
        //dio.options.headers["authtoken"] = authtoken;
        SharedPreferences pref = await SharedPreferences.getInstance();
        String? token = pref.getString(session.accessToken);
        log("token : $token");
        // log("sharedPreferences : ${headersToken(token)}/// $headers");
        Response? response;
        response = await dio.get(
          apiName,
          data: params,
          options: Options(headers: isToken ? headersToken(token) : headers),
        );
        log("STATUSS : ${response.statusCode}");
        if (response.statusCode == 500) {
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (_) => const ServerErrorScreen()),
          );
          return apiData;
        }
        if (response.statusCode == 200 || response.statusCode == 201) {
          //get response
          var responseData = response.data;
          // log("$apiName Response: $responseData");
          //set data to class
          if (isData) {
            apiData.message = isMessage
                ? apiName.contains("highest-ratings")
                    ? ""
                    : responseData["message"] ?? ""
                : "";
            apiData.isSuccess = true;
            log("dskyghvjryb//${apiData.isSuccess}");
            apiData.data = responseData;
            return apiData;
          } else {
            apiData.message = responseData["message"] ?? "";
            apiData.isSuccess = true;
            apiData.data = apiName.contains("self")
                ? responseData['user']
                : responseData["data"];
            return apiData;
          }
        } else {
          log("EEEEEEEEERRRRRROOORRR");
          apiData.message = "No Internet Access";
          apiData.isSuccess = false;
          apiData.data = 0;
          return apiData;
        }
      } catch (e) {
        apiData = await dioException(e);
        log("DDDD :$apiName :: ${apiData.message}");
        return apiData;
      }
    }
  }

  Future<APIDataClass> postApi(String apiName, body,
      {isToken = false, isData = false}) async {
    //default data to class
    APIDataClass apiData = APIDataClass(
      message: 'No data',
      isSuccess: false,
      data: '0',
    );
    //Check For Internet
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      apiData.message = "No Internet Access";
      apiData.isSuccess = false;
      apiData.data = 0;
      return apiData;
    } else {
      log("URL: $apiName");

      //dio.options.headers["authtoken"] = authtoken;
      SharedPreferences pref = await SharedPreferences.getInstance();
      String? token = pref.getString(session.accessToken);
      log("AUTH : $token");
      log("AUTH : ${headersToken(token)}");
      try {
        final response = await dio.post(
          apiName,
          data: body,
          options: Options(headers: isToken ? headersToken(token) : headers),
        );

        var responseData = response.data;
        log("response 1: ${response.statusCode}");
        if (response.statusCode == 200 || response.statusCode == 201) {
          //get response

          if (apiName.contains("login") ||
              apiName.contains("register") ||
              apiName.contains("social/login") ||
              apiName.contains("social/verifyOtp") ||
              apiName.contains("social/verifySendOtp")) {
            log("RESPONJSE : ${response.data}");
            await pref.setString(
                session.accessToken, responseData['access_token']);
            //set data to class
            apiData.message =
                apiName.contains("login") || apiName.contains("social/login")
                    ? ""
                    : "Register Successfully";
            apiData.isSuccess = true;
            apiData.data = "";
            return apiData;
          } else {
            if (isData) {
              // log("AAA :$responseData");
              apiData.message = responseData["message"] ?? "";
              apiData.isSuccess = true;
              apiData.data = responseData;
              return apiData;
            } else {
              apiData.message = responseData["message"] ?? "";
              apiData.isSuccess = true;
              apiData.data = responseData["data"];
              return apiData;
            }
          }
        } else {
          log("RESPONJSE 1: ${response.data}");
          apiData.message = responseData["message"];
          apiData.isSuccess = false;
          apiData.data = 0;
          return apiData;
        }
      } catch (e) {
        if (e is DioException) {
          if (e.type == DioExceptionType.badResponse) {
            final response = e.response;
            log("EEEEE : $response");

            if (response!.data != null) {
              apiData.message = response.data['message'];
              apiData.isSuccess = false;
              apiData.data = 0;
              return apiData;
            } else {
              apiData.message = response.data.toString();
              apiData.isSuccess = false;
              apiData.data = 0;
              return apiData;
            }
          } else {
            final response = e.response;
            if (response != null && response.data != null) {
              final Map responseData =
                  json.decode(response.data as String) as Map;
              apiData.message =
                  responseData['message'] as String? ?? 'Unknown error';
              apiData.isSuccess = false;
              apiData.data = 0;
              return apiData;
            } else if (response != null) {
              apiData.message = response.statusCode.toString();
              apiData.isSuccess = false;
              apiData.data = 0;
              return apiData;
            } else {
              apiData.message = 'No response from server';
              apiData.isSuccess = false;
              apiData.data = 0;
              return apiData;
            }
          }
        } else {
          apiData.message = "";
          apiData.isSuccess = false;
          apiData.data = 0;
          return apiData;
        }
      }
    }
  }

  Future<APIDataClass> deleteApi(String apiName, body,
      {isToken = false}) async {
    //default data to class
    APIDataClass apiData = APIDataClass(
      message: 'No data',
      isSuccess: false,
      data: '0',
    );
    //Check For Internet
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      apiData.message = "No Internet Access";
      apiData.isSuccess = false;
      apiData.data = 0;
      return apiData;
    } else {
      log("URL: $apiName");

      //dio.options.headers["authtoken"] = authtoken;
      SharedPreferences pref = await SharedPreferences.getInstance();
      String? token = pref.getString(session.accessToken);
      log("AUTH : $token");
      log("AUTH : ${headersToken(token)}");
      try {
        final response = await dio.delete(
          apiName,
          data: body,
          options: Options(headers: isToken ? headersToken(token) : headers),
        );
        var responseData = response.data;
        log("response 1: $responseData");
        if (response.statusCode == 200 || response.statusCode == 201) {
          //set data to class
          log("RESPONJSE :2 ${response.data}");
          apiData.message = responseData["message"] ?? "";
          apiData.isSuccess = true;
          apiData.data = responseData["data"];
          return apiData;
        } else {
          log("RESPONJSE 1: ${response.data}");
          apiData.message = responseData["message"];
          apiData.isSuccess = false;
          apiData.data = 0;
          return apiData;
        }
      } catch (e) {
        if (e is DioException) {
          if (e.type == DioExceptionType.badResponse) {
            final response = e.response;
            log("RESPONJSE 1: ${response!.data}");
            if (response.data != null) {
              apiData.message = response.data['message'];
              apiData.isSuccess = false;
              apiData.data = 0;
              return apiData;
            } else {
              apiData.message = response.data.toString();
              apiData.isSuccess = false;
              apiData.data = 0;
              return apiData;
            }
          } else {
            final response = e.response;
            if (response != null && response.data != null) {
              final Map responseData =
                  json.decode(response.data as String) as Map;
              apiData.message = responseData['message'] as String;
              apiData.isSuccess = false;
              apiData.data = 0;
              return apiData;
            } else {
              apiData.message = response!.statusCode.toString();
              apiData.isSuccess = false;
              apiData.data = 0;
              return apiData;
            }
          }
        } else {
          apiData.message = "";
          apiData.isSuccess = false;
          apiData.data = 0;
          return apiData;
        }
      }
    }
  }

  Future<APIDataClass> putApi(String apiName, body,
      {isToken = false, isData = false}) async {
    //default data to class
    APIDataClass apiData = APIDataClass(
      message: 'No data',
      isSuccess: false,
      data: '0',
    );
    //Check For Internet
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      apiData.message = "No Internet Access";
      apiData.isSuccess = false;
      apiData.data = 0;
      return apiData;
    } else {
      log("URL: $apiName");

      //dio.options.headers["authtoken"] = authtoken;
      SharedPreferences pref = await SharedPreferences.getInstance();
      String? token = pref.getString(session.accessToken);
      log("AUTH : $token");
      log("AUTH : ${headersToken(token)}");
      try {
        final response = await dio.put(
          apiName,
          data: jsonEncode(body),
          options: Options(headers: isToken ? headersToken(token) : headers),
        );
        var responseData = response.data;
        log("response : ${response.statusCode}");
        if (response.statusCode == 200 || response.statusCode == 201) {
          //get response

          if (isData) {
            /*  await pref.setString(
                session.accessToken, responseData['access_token']);*/
            //set data to class
            apiData.message = "";
            apiData.isSuccess = true;
            apiData.data = responseData;
            return apiData;
          } else {
            //set data to class
            log("RESPONJSE :2 ${response.data}");
            apiData.message = responseData["message"] ?? "";
            apiData.isSuccess = true;
            apiData.data = responseData["data"];
            return apiData;
          }
        } else {
          log("RESPONJSE 1: ${response.data}");
          apiData.message = responseData["message"];
          apiData.isSuccess = false;
          apiData.data = 0;
          return apiData;
        }
      } catch (e) {
        if (e is DioException) {
          if (e.type == DioExceptionType.badResponse) {
            final response = e.response;
            log("EEEEresponse :$response");
            if (response != null && response.data != null) {
              apiData.message = response.data['message'];
              apiData.isSuccess = false;
              apiData.data = 0;
              return apiData;
            } else {
              apiData.message = response!.data.toString();
              apiData.isSuccess = false;
              apiData.data = 0;
              return apiData;
            }
          } else {
            final response = e.response;
            if (response != null && response.data != null) {
              final Map responseData =
                  json.decode(response.data as String) as Map;
              apiData.message = responseData['message'] as String;
              apiData.isSuccess = false;
              apiData.data = 0;
              return apiData;
            } else {
              apiData.message = response!.statusCode.toString();
              apiData.isSuccess = false;
              apiData.data = 0;
              return apiData;
            }
          }
        } else {
          apiData.message = "";
          apiData.isSuccess = false;
          apiData.data = 0;
          return apiData;
        }
      }
    }
  }
}

Exception handleErrorResponse(http.Response response) {
  var data = jsonDecode(response.body);

  return RemoteException(
    statusCode: response.statusCode,
    message: data['message'] ?? response.statusCode == 422
        ? 'Validation failed'
        : 'Server exception',
  );
}

/// Interceptor that forces Accept-Lang to English on every request so the
/// backend always returns English content. Dynamic translation is handled
/// in-app via GoogleTranslationService.
class _LanguageInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept-Lang'] = 'en';
    log('[Translation] Interceptor → ${options.uri} | Accept-Lang: en');
    handler.next(options);
  }
}

/// Response interceptor that auto-translates human-readable text fields
/// in every API response when the user's language is not English.
/// Only translates fields whose JSON key is in [_translatableKeys].
/// All other fields (IDs, slugs, URLs, status codes) pass through untouched.
class TranslationResponseInterceptor extends Interceptor {
  // JSON keys whose values should be translated
  static const _translatableKeys = {
    'title', 'name', 'description', 'detail', 'short_description',
    'content', 'bio', 'sub_title', 'subtitle', 'tag_line',
    'overview', 'category_name', 'service_name', 'about',
  };

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    try {
      final locale = await GoogleTranslationService.getCurrentLocale();
      if (response.data != null) {
        log('[Translation] ResponseInterceptor → translating response for ${response.realUri} | locale=$locale');
        response.data = await _translateNode(response.data, locale);
      }
    } catch (e) {
      log('[Translation] ResponseInterceptor error: $e');
    }
    handler.next(response);
  }

  static Future<dynamic> _translateNode(dynamic node, String locale) async {
    if (node is Map<String, dynamic>) {
      // Collect all translatable key-value pairs in this map
      final keys = <String>[];
      final texts = <String>[];
      for (final entry in node.entries) {
        if (_translatableKeys.contains(entry.key) &&
            entry.value is String &&
            (entry.value as String).trim().isNotEmpty) {
          keys.add(entry.key);
          texts.add(entry.value as String);
        }
      }

      // Translate the collected texts in one batch call
      final Map<String, dynamic> result = Map.from(node);
      if (texts.isNotEmpty) {
        final translated =
            await GoogleTranslationService.translateBatch(texts, locale);
        for (int i = 0; i < keys.length; i++) {
          result[keys[i]] = translated[i];
        }
      }

      // Recurse into nested maps and lists
      for (final entry in result.entries) {
        if (entry.value is Map<String, dynamic> || entry.value is List) {
          result[entry.key] = await _translateNode(entry.value, locale);
        }
      }
      return result;
    } else if (node is List) {
      return Future.wait(
          node.map((item) => _translateNode(item, locale)).toList());
    }
    return node;
  }
}
