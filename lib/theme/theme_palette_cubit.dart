import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;

import '../data/repository/hiveRepository.dart';
import '../data/repository/settingRepository.dart';
import 'kigen/kigen.dart';

/// The palette the app is currently painted with.
///
/// One [KigenPrimitives] ramp serves both modes — the admin seeds a primary and
/// a neutral, and light/dark differ only in which stop each role reads, which
/// [KigenSemanticColors] already owns.
@immutable
class ThemePaletteState {
  final KigenPrimitives primitives;

  const ThemePaletteState({required this.primitives});

  /// The committed Figma export (brand #5465FF) — what the app runs on offline,
  /// on a fresh install, and until the first [ThemePaletteCubit.refresh] lands.
  static const ThemePaletteState fallback = ThemePaletteState(
    primitives: KigenPrimitives.fallback,
  );
}

/// Owns the palette lifecycle: warm-start from the Hive cache, then a background
/// refresh via `GET get_theme_colors` that only emits when the payload differs.
///
/// **The app never waits on this.** It renders on the cache (or the fallback)
/// immediately; a palette that arrives later just rebuilds the theme. That is
/// why [refresh] is fire-and-forget and swallows every failure — a theme poll
/// must never be able to block or break a launch.
///
/// `appTheme.dart` reads [primitives] and feeds it to `buildKigenTheme`, so the
/// semantic and component layers reflow with no change at any call site.
class ThemePaletteCubit extends Cubit<ThemePaletteState> {
  ThemePaletteCubit(this.settingRepository)
    : super(ThemePaletteState.fallback) {
    _loadCache();
  }

  final SettingRepository settingRepository;

  /// The raw payload behind the currently-applied state, used to skip a
  /// redundant emit when a refresh brings back exactly what's already applied
  /// — the endpoint carries no timestamp/etag to diff against instead.
  String _lastRaw = "";

  /// Passthrough to the applied palette.
  KigenPrimitives get primitives => state.primitives;

  /// Warm-start from the last good payload. Silent on a parse miss: a corrupt
  /// cache just leaves the fallback standing until [refresh] replaces it.
  void _loadCache() {
    final String raw = HiveRepository.getThemePalette;
    if (raw.isEmpty) {
      debugPrint("THEME no cache — starting on the #5465FF fallback");
      return;
    }
    try {
      emit(_parse(json.decode(raw) as Map<String, dynamic>));
      _lastRaw = raw;
      debugPrint("THEME warm-started from cache");
    } catch (e) {
      debugPrint("THEME cache parse failed: $e");
    }
  }

  /// Fetch the palette and, if it changed, cache it and emit.
  Future<void> refresh() async {
    try {
      final Map<String, dynamic> data = await settingRepository
          .getThemeColors();
      final String raw = json.encode(data);
      if (raw == _lastRaw) {
        debugPrint("THEME unchanged — cache stands");
        return;
      }

      // Parse before caching, so a payload the app cannot read never becomes
      // the thing it warm-starts from next launch.
      final ThemePaletteState parsed = _parse(data);
      HiveRepository.setThemePalette = raw;
      _lastRaw = raw;
      debugPrint("THEME applied: primary500 ${parsed.primitives.primary500}");
      emit(parsed);
    } catch (e) {
      // Network or parse failure: keep whatever is already painted.
      debugPrint("THEME refresh failed: $e");
    }
  }

  /// `data` -> a primitive ramp. The six hue maps sit at the top level;
  /// `seed_primary`/`seed_neutral` are the admin's raw inputs and are ignored,
  /// because the server has already expanded them into the 11 stops.
  ThemePaletteState _parse(Map<String, dynamic> data) {
    Map<String, dynamic> ramp(dynamic value) =>
        Map<String, dynamic>.from(value as Map);

    final KigenPrimitives primitives = KigenPrimitives.fromApiMaps(
      primary: const {
        '50': '#EEEFFF',
        '100': '#DDE0FF',
        '200': '#BBC1FF',
        '300': '#98A3FF',
        '400': '#7684FF',
        '500': '#5465FF',
        '600': '#4351CC',
        '700': '#323D99',
        '800': '#222866',
        '900': '#111433',
        '950': '#080A19',
      },
      neutral: ramp(data['neutral']),
      success: ramp(data['success']),
      warn: ramp(data['warn']),
      error: ramp(data['error']),
      info: ramp(data['info']),
    );

    return ThemePaletteState(primitives: primitives);
  }
}
