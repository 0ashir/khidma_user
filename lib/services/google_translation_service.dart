import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GoogleTranslationService {
  static const String _apiKey = 'AIzaSyDb8zk-JshdVYLf3139WSoNZUh5DT6vl1w';
  static const String _endpoint =
      'https://translation.googleapis.com/language/translate/v2';

  // In-memory cache: "lang\x00text" -> translated
  static final Map<String, String> _cache = {};

  static String _cacheKey(String text, String lang) => '$lang\x00$text';

  /// Returns the user's preferred locale code from SharedPreferences.
  static Future<String> getCurrentLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locale = prefs.getString('selectedLocale') ?? 'en';
      log('[Translation] getCurrentLocale → "$locale"');
      return locale;
    } catch (e) {
      log('[Translation] getCurrentLocale error: $e — defaulting to "en"');
      return 'en';
    }
  }

  /// Translates [text] into [targetLang].
  /// Source language is auto-detected so this works regardless of what
  /// language the backend returned the text in.
  static Future<String> translate(String text, String targetLang) async {
    log('[Translation] translate called → target="$targetLang" text="${text.length > 50 ? '${text.substring(0, 50)}...' : text}"');
    if (text.trim().isEmpty) {
      log('[Translation] skipping — text is empty');
      return text;
    }

    final key = _cacheKey(text, targetLang);
    if (_cache.containsKey(key)) {
      log('[Translation] cache hit for "$text"');
      return _cache[key]!;
    }

    try {
      log('[Translation] calling API for single text → "$text"');
      final response = await http
          .post(
            Uri.parse('$_endpoint?key=$_apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'q': text,
              'target': targetLang,
              // no 'source' — Google auto-detects so Arabic→en and en→ar both work
              'format': 'text',
            }),
          )
          .timeout(const Duration(seconds: 5));

      log('[Translation] API response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final translated =
            data['data']['translations'][0]['translatedText'] as String;
        _cache[key] = translated;
        log('[Translation] success → "$translated"');
        return translated;
      }
      log('[Translation] HTTP ${response.statusCode}: ${response.body}');
    } catch (e) {
      log('[Translation] error: $e');
    }
    return text;
  }

  /// Translates multiple texts in a single API call.
  /// Source language is auto-detected — works for any source language.
  /// Respects the in-memory cache; only sends uncached texts.
  static Future<List<String>> translateBatch(
      List<String> texts, String targetLang) async {
    log('[Translation] translateBatch called → target="$targetLang", ${texts.length} texts');

    final results = List<String>.from(texts);
    final pendingIndices = <int>[];
    final pendingTexts = <String>[];

    for (int i = 0; i < texts.length; i++) {
      if (texts[i].trim().isEmpty) continue;
      final key = _cacheKey(texts[i], targetLang);
      if (_cache.containsKey(key)) {
        results[i] = _cache[key]!;
        log('[Translation] cache hit [$i]: "${texts[i]}"');
      } else {
        pendingIndices.add(i);
        pendingTexts.add(texts[i]);
      }
    }

    log('[Translation] batch: ${pendingTexts.length} uncached texts to translate');
    if (pendingTexts.isEmpty) {
      log('[Translation] all texts were cached, skipping API call');
      return results;
    }

    try {
      log('[Translation] calling batch API with ${pendingTexts.length} texts: $pendingTexts');
      final response = await http
          .post(
            Uri.parse('$_endpoint?key=$_apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'q': pendingTexts,
              'target': targetLang,
              // no 'source' — Google auto-detects so Arabic→en and en→ar both work
              'format': 'text',
            }),
          )
          .timeout(const Duration(seconds: 10));

      log('[Translation] batch API response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final translations = data['data']['translations'] as List;
        log('[Translation] batch API success — ${translations.length} results received');

        for (int i = 0; i < pendingIndices.length; i++) {
          final idx = pendingIndices[i];
          final translated = translations[i]['translatedText'] as String;
          _cache[_cacheKey(texts[idx], targetLang)] = translated;
          results[idx] = translated;
          log('[Translation] [$idx] "${texts[idx]}" → "$translated"');
        }
      } else {
        log('[Translation] batch API failed: ${response.statusCode} — ${response.body}');
      }
    } catch (e) {
      log('[Translation] batch error: $e');
    }

    return results;
  }

  /// Clears the in-memory cache (e.g. after a language switch).
  static void clearCache() {
    log('[Translation] cache cleared');
    _cache.clear();
  }
}
