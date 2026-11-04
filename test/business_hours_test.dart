import 'dart:io';
import 'package:e_demand/app/generalImports.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late Directory storage;
  setUpAll(() async {
    await initializeDateFormatting('en');
    storage = await Directory.systemTemp.createTemp('khidma-hours-');
    Hive.init(storage.path);
    await Hive.openBox(HiveRepository.languageBoxKey);
  });
  tearDownAll(() async {
    await Hive.close();
    await storage.delete(recursive: true);
  });

  test('provider wall-clock hours retain their hour in 12-hour display', () {
    dateAndTimeSetting['use24HourFormat'] = false;
    expect('09:00:00'.formatTime(), '09:00 AM');
    expect('20:00:00'.formatTime(), '08:00 PM');
  });
  test('provider wall-clock hours retain their hour in 24-hour display', () {
    dateAndTimeSetting['use24HourFormat'] = true;
    expect('09:00:00'.formatTime(), '09:00');
    expect('20:00:00'.formatTime(), '20:00');
  });
}
