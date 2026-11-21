import 'package:e_demand/app/generalImports.dart';

/// Disk cache of raw API responses for stale-while-revalidate screens (home,
/// category providers): show the last response instantly, refresh in the
/// background, and only touch the UI when the data actually changed.
///
/// Entries are keyed by URL + parameters + language + signed-in user, so a
/// cached page never leaks between accounts, languages or locations.
class ApiResponseCache {
  static const String boxName = 'apiResponseCache';

  /// Older entries are ignored (and pruned) so a long-unused app does not
  /// flash very stale content.
  static const Duration maxAge = Duration(days: 7);
  static const int maxEntries = 60;

  static Box? get _box => Hive.isBoxOpen(boxName) ? Hive.box(boxName) : null;

  static Future<void> init() async {
    try {
      await Hive.openBox(boxName);
    } catch (_) {
      // A corrupt cache must never block start-up: drop it and start empty.
      try {
        await Hive.deleteBoxFromDisk(boxName);
        await Hive.openBox(boxName);
      } catch (_) {}
    }
  }

  /// Cache key for a request as the current user / language would send it.
  static String keyFor(
    final String url,
    final Map<String, dynamic> parameter, {
    final bool userSpecific = true,
  }) {
    final List<String> keys = parameter.keys.toList()..sort();
    final String params = keys.map((k) => '$k=${parameter[k]}').join('&');
    // Caching is best-effort: if the stores are not readable, use a key no
    // entry is ever saved under (reads miss, writes are skipped).
    if (_box == null) return '';
    try {
      final String language =
          HiveRepository.getCurrentLanguage()?.languageCode ?? '';
      final String user = userSpecific
          ? (HiveRepository.getUserToken.isEmpty
                ? 'guest'
                : '${Hive.box(HiveRepository.userDetailBoxKey).get(HiveRepository.userIdKey) ?? 'user'}')
          : '';
      return '$url?$params|$language|$user';
    } catch (_) {
      return '';
    }
  }

  /// Cached response body, or null when missing, expired or unreadable.
  static Map<String, dynamic>? read(final String key) {
    if (key.isEmpty) return null;
    final dynamic entry = _box?.get(key);
    if (entry is! Map) return null;
    try {
      final int savedAt = entry['savedAt'] as int;
      if (DateTime.now().millisecondsSinceEpoch - savedAt >
          maxAge.inMilliseconds) {
        return null;
      }
      return Map<String, dynamic>.from(
        jsonDecode(entry['body'] as String) as Map,
      );
    } catch (_) {
      return null;
    }
  }

  /// Encoded form used to tell whether a fresh response differs from the cache.
  static String fingerprint(final Map<String, dynamic> body) =>
      jsonEncode(body);

  static Future<void> write(
    final String key,
    final Map<String, dynamic> body,
  ) async {
    final Box? box = _box;
    if (box == null || key.isEmpty) return;
    try {
      await box.put(key, {
        'savedAt': DateTime.now().millisecondsSinceEpoch,
        'body': jsonEncode(body),
      });
      await _prune(box);
    } catch (_) {
      // Caching is best-effort.
    }
  }

  static Future<void> _prune(final Box box) async {
    if (box.length <= maxEntries) return;
    final List<MapEntry<dynamic, int>> entries = [
      for (final dynamic k in box.keys)
        MapEntry(k, (box.get(k) is Map ? box.get(k)['savedAt'] : 0) as int),
    ]..sort((a, b) => a.value.compareTo(b.value));
    for (final e in entries.take(box.length - maxEntries)) {
      await box.delete(e.key);
    }
  }

  /// Wiped on logout so the next account never sees the previous one's data.
  static Future<void> clear() async => _box?.clear();
}
