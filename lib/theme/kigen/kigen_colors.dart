import 'package:flutter/material.dart';

import 'kigen_component.dart';
import 'kigen_primitives.dart';
import 'kigen_semantic.dart';

/// The whole Kigen colour system as a [ThemeExtension], so any widget can read
/// it off the ambient theme — `context.colors.textPrimary`.
///
/// It bundles the three Figma layers: [primitives] (the raw palette),
/// [semantic] (roles, and the only layer that knows about light vs dark) and
/// [component] (per-control tokens).
///
/// The call syntax encodes which layer you meant:
///
/// ```dart
/// context.colors.textPrimary                  // semantic — the default
/// context.colors.component.buttonPrimaryBg    // component — extra hop
/// context.colors.primitives.neutral900        // primitive — extra hop
/// ```
///
/// Plain name = semantic. An extra hop means you deliberately left the default,
/// and the reader can see it.
///
/// [primitives] defaults to [KigenPrimitives.fallback] (the committed Figma
/// export, brand #5465FF). When `/api/theme` ships, the admin palette is parsed
/// into a [KigenPrimitives] and passed to [of] — every role and control token
/// reflows with no change at any call site.
@immutable
class KigenColors extends ThemeExtension<KigenColors> {
  final KigenPrimitives primitives;
  final KigenSemanticColors semantic;
  final KigenComponentColors component;

  const KigenColors({
    required this.primitives,
    required this.semantic,
    required this.component,
  });

  /// Light-mode colours for [primitives].
  factory KigenColors.light([
    KigenPrimitives primitives = KigenPrimitives.fallback,
  ]) {
    final KigenSemanticColors semantic = KigenSemanticColors.light(primitives);
    return KigenColors(
      primitives: primitives,
      semantic: semantic,
      component: KigenComponentColors.from(semantic),
    );
  }

  /// Dark-mode colours for [primitives].
  factory KigenColors.dark([
    KigenPrimitives primitives = KigenPrimitives.fallback,
  ]) {
    final KigenSemanticColors semantic = KigenSemanticColors.dark(primitives);
    return KigenColors(
      primitives: primitives,
      semantic: semantic,
      component: KigenComponentColors.from(semantic),
    );
  }

  /// Colours for [brightness] — the single entry point for theme wiring.
  factory KigenColors.of(
    Brightness brightness, [
    KigenPrimitives primitives = KigenPrimitives.fallback,
  ]) => brightness == Brightness.dark
      ? KigenColors.dark(primitives)
      : KigenColors.light(primitives);

  @override
  KigenColors copyWith({
    KigenPrimitives? primitives,
    KigenSemanticColors? semantic,
    KigenComponentColors? component,
  }) => KigenColors(
    primitives: primitives ?? this.primitives,
    semantic: semantic ?? this.semantic,
    component: component ?? this.component,
  );

  // ── Semantic shorthands ────────────────────────────────────────────────
  //
  // `context.colors.textPrimary` rather than
  // `context.colors.semantic.textPrimary`. The semantic layer is what screen
  // code reads almost without exception, so naming it at every call site costs
  // nine characters and says nothing — whereas [component] and [primitives]
  // keep their hop precisely because reaching for them is the unusual move.
  //
  // Forwarders, not a flattened copy: [semantic] stays the single definition
  // and both spellings resolve to the same field.

  // background — the page itself
  Color get backgroundPrimary => semantic.backgroundPrimary;
  Color get backgroundSecondary => semantic.backgroundSecondary;
  Color get backgroundTertiary => semantic.backgroundTertiary;
  Color get backgroundBrand => semantic.backgroundBrand;
  Color get backgroundBrandSubtle => semantic.backgroundBrandSubtle;
  Color get backgroundBrandHover => semantic.backgroundBrandHover;
  Color get backgroundBrandPressed => semantic.backgroundBrandPressed;
  Color get backgroundBrandDisabled => semantic.backgroundBrandDisabled;
  Color get backgroundInverse => semantic.backgroundInverse;
  Color get backgroundSuccess => semantic.backgroundSuccess;
  Color get backgroundSuccessSubtle => semantic.backgroundSuccessSubtle;
  Color get backgroundWarning => semantic.backgroundWarning;
  Color get backgroundWarningSubtle => semantic.backgroundWarningSubtle;
  Color get backgroundError => semantic.backgroundError;
  Color get backgroundErrorSubtle => semantic.backgroundErrorSubtle;
  Color get backgroundInfo => semantic.backgroundInfo;
  Color get backgroundInfoSubtle => semantic.backgroundInfoSubtle;
  Color get backgroundInverseDark => semantic.backgroundInverseDark;

  // surface — cards and sheets that sit ON the page
  Color get surfaceTransparent => semantic.surfaceTransparent;
  Color get surfacePrimary => semantic.surfacePrimary;
  Color get surfaceSecondary => semantic.surfaceSecondary;
  Color get surfaceElevated => semantic.surfaceElevated;
  Color get surfaceBrand => semantic.surfaceBrand;
  Color get surfaceHover => semantic.surfaceHover;
  Color get surfacePressed => semantic.surfacePressed;

  // text
  Color get textPrimary => semantic.textPrimary;
  Color get textSecondary => semantic.textSecondary;
  Color get textTertiary => semantic.textTertiary;
  Color get textDisabled => semantic.textDisabled;
  Color get textBrand => semantic.textBrand;
  Color get textSuccess => semantic.textSuccess;
  Color get textWarning => semantic.textWarning;
  Color get textError => semantic.textError;
  Color get textInfo => semantic.textInfo;
  Color get textInverseDark => semantic.textInverseDark;
  Color get textInverseLight => semantic.textInverseLight;

  // border
  Color get borderDefault => semantic.borderDefault;
  Color get borderMuted => semantic.borderMuted;
  Color get borderStrong => semantic.borderStrong;
  Color get borderBlack => semantic.borderBlack;
  Color get borderWhite => semantic.borderWhite;
  Color get borderBrand => semantic.borderBrand;
  Color get borderSuccess => semantic.borderSuccess;
  Color get borderWarning => semantic.borderWarning;
  Color get borderError => semantic.borderError;
  Color get borderInfo => semantic.borderInfo;
  Color get borderFocus => semantic.borderFocus;

  // icon — kept separate from text because the export gives the status icons a
  // different stop than the status labels
  Color get iconPrimary => semantic.iconPrimary;
  Color get iconSecondary => semantic.iconSecondary;
  Color get iconTertiary => semantic.iconTertiary;
  Color get iconDisabled => semantic.iconDisabled;
  Color get iconBrand => semantic.iconBrand;
  Color get iconSuccess => semantic.iconSuccess;
  Color get iconWarning => semantic.iconWarning;
  Color get iconError => semantic.iconError;
  Color get iconInfo => semantic.iconInfo;
  Color get iconInverse => semantic.iconInverse;
  Color get iconInverseLight => semantic.iconInverseLight;
  Color get iconInverseDark => semantic.iconInverseDark;

  // overlay — scrims; the only semantic tokens carrying alpha
  Color get overlayDefault => semantic.overlayDefault;
  Color get overlayStrong => semantic.overlayStrong;
  Color get overlayHeaderShadow => semantic.overlayHeaderShadow;
  Color get overlayFooterShadow => semantic.overlayFooterShadow;

  /// Tokens are a discrete set that swaps wholesale when the theme changes, so
  /// there is no meaningful per-colour interpolation. Snap at the midpoint
  /// rather than blending 250-odd colours through in-between states that match
  /// no design.
  @override
  KigenColors lerp(ThemeExtension<KigenColors>? other, double t) {
    if (other is! KigenColors) return this;
    return t < 0.5 ? this : other;
  }
}

/// `context.colors` — the ambient Kigen colours.
///
/// Throws if the extension is not on the theme. Intentional: a missing
/// extension is a wiring bug in `buildKigenTheme`, not something to paper over
/// with a default colour that would then ship to a user.
extension KigenColorsX on BuildContext {
  KigenColors get colors => Theme.of(this).extension<KigenColors>()!;
}
