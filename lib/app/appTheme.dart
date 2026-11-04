import 'package:e_demand/theme/kigen/kigen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppTheme { dark, light }

const String _fontFamily = "Outfit";

/// The app's [ThemeData] for [appTheme], painted from [palette].
///
/// Everything colour-related comes from Kigen; this function only adds what is
/// eDemand's own — the font, and the time picker, which Material gives no
/// sensible token-driven default for.
///
/// [palette] is [KigenPrimitives.fallback] until `/api/theme` exists. When it
/// does, `ThemePaletteCubit` supplies the admin's ramp here and every screen
/// follows without a single call-site edit.
ThemeData buildAppTheme(
  AppTheme appTheme, [
  KigenPrimitives palette = KigenPrimitives.fallback,
]) {
  final Brightness brightness = appTheme == AppTheme.dark
      ? Brightness.dark
      : Brightness.light;

  final ThemeData theme = buildKigenTheme(
    brightness,
    primitives: palette,
    fontFamily: _fontFamily,
  );
  final KigenSemanticColors s = theme.extension<KigenColors>()!.semantic;

  return theme.copyWith(
    textTheme: GoogleFonts.outfitTextTheme(theme.textTheme),
    secondaryHeaderColor: s.textPrimary,
    timePickerTheme: TimePickerThemeData(
      backgroundColor: s.backgroundPrimary,
      helpTextStyle: TextStyle(color: s.textPrimary),
      dialBackgroundColor: s.backgroundBrandSubtle,
      dialHandColor: s.backgroundBrand,
      hourMinuteTextColor: s.textBrand,
      hourMinuteColor: s.backgroundBrandSubtle,
      dayPeriodColor: s.backgroundBrand,
      dayPeriodTextColor: s.textPrimary,
      cancelButtonStyle: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll<Color>(s.textBrand),
      ),
      confirmButtonStyle: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll<Color>(s.textBrand),
      ),
    ),
  );
}
