import 'dart:convert';
import 'dart:io';

import 'package:e_demand/data/repository/hiveRepository.dart';
import 'package:e_demand/utils/api/apiClient.dart';
import 'package:e_demand/utils/api/apiException.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late Directory storage;
  late HttpServer server;
  late String url;
  Map<String, dynamic> response = {};
  int status = 200;
  String? authorization;

  setUpAll(() async {
    storage = await Directory.systemTemp.createTemp('khidma-api-test-');
    Hive.init(storage.path);
    await Hive.openBox(HiveRepository.userDetailBoxKey);
    await Hive.openBox(HiveRepository.languageBoxKey);
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    url = 'http://127.0.0.1:${server.port}/api';
    server.listen((request) async {
      authorization = request.headers.value(HttpHeaders.authorizationHeader);
      await request.drain<void>();
      request.response
        ..statusCode = status
        ..headers.contentType = ContentType.json
        ..write(jsonEncode(response));
      await request.response.close();
    });
  });

  setUp(() async {
    await Hive.box(HiveRepository.userDetailBoxKey).clear();
    status = 200;
    response = {'error': false, 'data': <String, dynamic>{}};
    authorization = null;
  });

  tearDownAll(() async {
    await server.close(force: true);
    await Hive.close();
    await storage.delete(recursive: true);
  });

  test('guest POST omits empty bearer credentials', () async {
    await ApiClient.post(url: url, parameter: {}, useAuthToken: true);
    expect(authorization, isNull);
  });

  test('signed-in POST includes the saved bearer token', () async {
    await Hive.box(
      HiveRepository.userDetailBoxKey,
    ).put(HiveRepository.tokenIdKey, 'test-session-token');
    await ApiClient.post(url: url, parameter: {}, useAuthToken: true);
    expect(authorization, 'Bearer test-session-token');
  });

  test('public GET never sends the saved bearer token', () async {
    await Hive.box(
      HiveRepository.userDetailBoxKey,
    ).put(HiveRepository.tokenIdKey, 'test-session-token');
    await ApiClient.get(url: url, useAuthToken: false);
    expect(authorization, isNull);
  });

  test('GET retains backend validation codes', () async {
    response = {'error': true, 'code': 'locationRequired'};
    await expectLater(
      ApiClient.get(url: url, useAuthToken: false),
      throwsA(
        isA<ApiException>().having(
          (e) => e.errorMessage,
          'message',
          'locationRequired',
        ),
      ),
    );
  });

  test('GET retains backend messages when there is no code', () async {
    response = {'error': true, 'message': 'No service available'};
    await expectLater(
      ApiClient.get(url: url, useAuthToken: false),
      throwsA(
        isA<ApiException>().having(
          (e) => e.errorMessage,
          'message',
          'No service available',
        ),
      ),
    );
  });

  test('POST retains backend validation messages', () async {
    response = {'error': true, 'message': 'Address is required'};
    await expectLater(
      ApiClient.post(url: url, parameter: {}, useAuthToken: false),
      throwsA(
        isA<ApiException>().having(
          (e) => e.errorMessage,
          'message',
          'Address is required',
        ),
      ),
    );
  });

  for (final entry in {
    401: 'authenticationFailed',
    500: 'internalServerError',
  }.entries) {
    test('HTTP ${entry.key} maps to the expected app error', () async {
      status = entry.key;
      await expectLater(
        ApiClient.get(url: url, useAuthToken: false),
        throwsA(
          isA<ApiException>().having(
            (e) => e.errorMessage,
            'message',
            entry.value,
          ),
        ),
      );
    });
  }
}
