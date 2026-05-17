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
/// in every API response. Uses a single-pass collect + one batch API call
/// strategy so the entire response tree is translated in one round-trip.
class TranslationResponseInterceptor extends Interceptor {
  static const _translatableKeys = {
    'title', 'name', 'description', 'detail', 'short_description',
    'content', 'bio', 'sub_title', 'subtitle', 'tag_line',
    'overview', 'category_name', 'service_name', 'about',
  };

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    try {
      // Read locale from the in-memory variable — no async SharedPreferences call
      final locale = local;
      if (response.data != null) {
        // Pass 1: collect every translatable (map, key) pair from the whole tree
        final refs = <_TranslationRef>[];
        _collect(response.data, refs);

        if (refs.isNotEmpty) {
          // ONE batch call for the entire response
          final texts = refs.map((r) => r.text).toList();
          final translated =
              await GoogleTranslationService.translateBatch(texts, locale);
          // Pass 2: apply translations back in-place
          for (int i = 0; i < refs.length; i++) {
            refs[i].map[refs[i].key] = translated[i];
          }
          log('[Translation] translated ${refs.length} fields for ${response.realUri}');
        }
      }
    } catch (e) {
      log('[Translation] ResponseInterceptor error: $e');
    }
    handler.next(response);
  }

  /// Recursively walks [node] and appends a [_TranslationRef] for every
  /// map entry whose key is in [_translatableKeys] and value is non-empty.
  static void _collect(dynamic node, List<_TranslationRef> refs) {
    if (node is Map<String, dynamic>) {
      for (final key in node.keys) {
        final value = node[key];
        if (_translatableKeys.contains(key) &&
            value is String &&
            value.trim().isNotEmpty) {
          refs.add(_TranslationRef(map: node, key: key, text: value));
        }
        // Always recurse into nested structures
        if (value is Map<String, dynamic> || value is List) {
          _collect(value, refs);
        }
      }
    } else if (node is List) {
      for (final item in node) {
        _collect(item, refs);
      }
    }
  }
}

/// Holds a mutable reference to a map entry so translation can be applied
/// back in-place without rebuilding the entire JSON tree.
class _TranslationRef {
  final Map<String, dynamic> map;
  final String key;
  final String text;
  _TranslationRef({required this.map, required this.key, required this.text});
}
