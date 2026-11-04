import 'package:flutter/material.dart';

import 'kigen_colors.dart';
import 'kigen_primitives.dart';
import 'kigen_semantic.dart';

/// Builds a [ThemeData] for [brightness] from the Kigen palette.
///
/// Does two things at once, and both matter:
///
/// 1. Attaches [KigenColors] as a theme extension, which is what makes
///    `context.colors` work.
/// 2. Fills Material's own [ColorScheme] from the same semantic layer, so
///    Flutter's built-in widgets (dialogs, pickers, ripples) and `context.colors`
///    never disagree about what the brand colour is.
///
/// Pure and portable — Flutter plus the Kigen layers, nothing else. The caller
/// decides [brightness], supplies [primitives] once `/api/theme` is live, and
/// passes [fontFamily] if the app has one.
ThemeData buildKigenTheme(
  Brightness brightness, {
  KigenPrimitives primitives = KigenPrimitives.fallback,
  String? fontFamily,
}) {
  final KigenColors colors = KigenColors.of(brightness, primitives);
  final KigenSemanticColors s = colors.semantic;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: fontFamily,
    primaryColor: s.backgroundBrand,
    scaffoldBackgroundColor: s.backgroundSecondary,
    cardColor: s.surfaceElevated,
    dividerColor: s.borderDefault,
    iconTheme: IconThemeData(color: s.iconPrimary),
    appBarTheme: AppBarTheme(
      backgroundColor: s.backgroundPrimary,
      foregroundColor: s.textPrimary,
      iconTheme: IconThemeData(color: s.iconPrimary),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: s.backgroundBrand,
      selectionHandleColor: s.backgroundBrand,
    ),
    // fromSeed fills the long tail of Material roles the app never names; the
    // copyWith pins the handful it does, so those come from Figma rather than
    // from Material's tonal maths.
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: s.backgroundBrand,
          brightness: brightness,
        ).copyWith(
          primary: s.backgroundBrand,
          onPrimary: s.textInverseLight,
          secondary: s.backgroundBrand,
          onSecondary: s.textInverseLight,
          error: s.textError,
          onError: s.textInverseLight,
          surface: s.backgroundPrimary,
          onSurface: s.textPrimary,
          surfaceBright: s.surfaceElevated,
          primaryContainer: s.backgroundSecondary,
          outline: s.borderDefault,
        ),
    extensions: <ThemeExtension<dynamic>>[colors],
  );
}
