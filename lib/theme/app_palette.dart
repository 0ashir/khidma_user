import 'package:flutter/material.dart';

/// Holding pen for colours Kigen has no token for.
///
/// The point of this file is that entries **leave** it. Every getter here is a
/// colour the design system does not model yet; each carries a note saying what
/// should replace it. One file of named getters beats the same literals spread
/// across thirty widgets, but it is a waiting room, not a destination.
///
/// Nothing here follows the admin palette. That is the cost of being outside the
/// token set, and the reason to keep the list short.
class AppPalette {
  AppPalette._();

  // ── Splash ────────────────────────────────────────────────────────────
  //
  // A fixed brand gradient painted before the theme exists, so it cannot read
  // tokens even in principle. Replace when the design system gains gradient
  // tokens; until then this is the one place these two hexes live.

  // Mirrors Kigen `Background/Brand` and `Background/BrandPressed` defaults.
  static const Color splashGradientTop = Color(0xFF5465FF);
  static const Color splashGradientBottom = Color(0xFF323D99);

  // ── Rating stars ──────────────────────────────────────────────────────
  //
  // A fixed illustration colour, deliberately not the warning token: stars stay
  // gold whatever the admin picks for "warning". Kept literal for the same
  // reason a logo is.

  static const Color ratingStar = Colors.amber;

  // ── Shimmer ───────────────────────────────────────────────────────────
  //
  // Loading placeholders, which are alpha over whatever is behind them rather
  // than a colour with a role. No token models this. Read them through
  // `AppPalette.shimmerBase(brightness)` and friends directly.

  static Color shimmerBase(Brightness brightness) =>
      brightness == Brightness.dark
      ? Colors.grey.withValues(alpha: 0.5)
      : Colors.black.withValues(alpha: 0.05);

  static Color shimmerHighlight(Brightness brightness) =>
      brightness == Brightness.dark
      ? Colors.grey.withValues(alpha: 0.005)
      : Colors.black.withValues(alpha: 0.005);

  static Color shimmerContent(Brightness brightness) =>
      brightness == Brightness.dark
      ? Colors.black.withValues(alpha: 0.3)
      : Colors.white;
}
