import 'package:dio/dio.dart';
import 'package:e_demand/app/generalImports.dart';

class ApiClient {
  /// One shared client: reuses connections and applies timeouts to every call.
  static final Dio _dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final backend = Uri.tryParse(domain);
          if (backend == null ||
              backend.scheme != 'https' ||
              backend.host.isEmpty) {
            return handler.reject(
              DioException(
                requestOptions: options,
                error: 'serviceUnavailable',
              ),
            );
          }
          handler.next(options);
        },
      ),
    );
    // cURL log includes the Authorization header, so keep it out of release.
    if (kDebugMode) {
      dio.interceptors.add(CurlLoggerInterceptor());
    }
    return dio;
  }

  static Map<String, dynamic> headers({bool includeAuth = true}) {
    final String jwtToken = HiveRepository.getUserToken;
    final lang = HiveRepository.getCurrentLanguage();

    final headers = <String, dynamic>{};

    if (includeAuth && jwtToken.trim().isNotEmpty) {
      headers["Authorization"] = "Bearer $jwtToken";
    }

    if (lang?.languageCode != null && lang!.languageCode.isNotEmpty) {
      headers["Content-Language"] = lang.languageCode;
    }

    return headers;
  }

  ///post method for API calling
  static Future<Map<String, dynamic>> post({
    required final String url,
    required final Map<String, dynamic> parameter,
    required final bool useAuthToken,
  }) async {
    try {
      final Dio dio = _dio;

      final FormData formData = FormData.fromMap(
        parameter,
        ListFormat.multiCompatible,
      );

      final response = await dio.post(
        url,
        data: formData,
        options: Options(headers: headers(includeAuth: useAuthToken)),
      );

      if (response.data['error']) {
        throw ApiException(response.data['message']);
      }

      return Map.from(response.data);
    } on DioException catch (e) {
      if (e.error == 'serviceUnavailable') {
        throw ApiException('serviceUnavailable');
      }
      if (kDebugMode) {
        print("error API is $url");

        print("HTTP status: ${e.response?.statusCode}");
      }
      if (e.response?.statusCode == 401) {
        UiUtils.authenticationError = true;
        throw ApiException("authenticationFailed");
      } else if (e.response?.statusCode == 500) {
        throw ApiException("internalServerError");
      }
      throw ApiException(
        e.error is SocketException ? "noInternetFound" : "somethingWentWrong",
      );
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e, st) {
      if (kDebugMode) {
        print("api $e ${st.toString()}");
      }
      throw ApiException("somethingWentWrong");
    }
  }

  ///post method for API calling
  static Future<List<int>> downloadAPI({
    required final String url,
    required final Map<String, dynamic> parameter,
    required final bool useAuthToken,
    final bool? isInvoiceAPI,
  }) async {
    try {
      final Dio dio = _dio;
      final FormData formData = FormData.fromMap(
        parameter,
        ListFormat.multiCompatible,
      );

      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            ...headers(includeAuth: useAuthToken),
            'Accept': 'application/pdf',
          },
          responseType: ResponseType.bytes,
        ),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.error == 'serviceUnavailable') {
        throw ApiException('serviceUnavailable');
      }
      if (e.response?.statusCode == 401) {
        UiUtils.authenticationError = true;
        throw ApiException("authenticationFailed");
      } else if (e.response?.statusCode == 500) {
        throw ApiException("internalServerError");
      } else if (e.response?.statusCode == 503) {
        throw ApiException("internalServerError");
      }
      throw ApiException(
        e.error is SocketException ? "noInternetFound" : "somethingWentWrong",
      );
    } on ApiException {
      throw ApiException("somethingWentWrong");
    } catch (e) {
      throw ApiException("somethingWentWrong");
    }
  }

  static Future<Map<String, dynamic>> get({
    required final String url,
    required final bool useAuthToken,
    final Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final Dio dio = _dio;
      final response = await dio.get(
        url,
        queryParameters: queryParameters,
        options: Options(headers: headers(includeAuth: useAuthToken)),
      );

      if (response.data['error'] == true) {
        throw ApiException(
          (response.data['code'] ??
                  response.data['message'] ??
                  'somethingWentWrong')
              .toString(),
        );
      }

      return Map.from(response.data);
    } on DioException catch (e) {
      if (e.error == 'serviceUnavailable') {
        throw ApiException('serviceUnavailable');
      }
      if (e.response?.statusCode == 401) {
        UiUtils.authenticationError = true;
        throw ApiException("authenticationFailed");
      } else if (e.response?.statusCode == 500) {
        throw ApiException("internalServerError");
      }
      throw ApiException(
        e.error is SocketException ? "noInternetFound" : "somethingWentWrong",
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException("somethingWentWrong");
    }
  }
}
