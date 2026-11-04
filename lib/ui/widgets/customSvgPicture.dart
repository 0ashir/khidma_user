import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class CustomSvgPicture extends StatelessWidget {
  final String svgImage;
  final VoidCallback? onTap;
  final Color? color;
  final double? height;
  final double? width;
  final BoxFit? boxFit;
  final bool? avoideResponsive;
  final ColorMapper? colorMapper;

  const CustomSvgPicture({
    super.key,
    required this.svgImage,
    this.onTap,
    this.color,
    this.height,
    this.width,
    this.boxFit,
    this.avoideResponsive = false,
    this.colorMapper,
  });

  @override
  Widget build(BuildContext context) {
    return CustomInkWellContainer(
      onTap: onTap,
      // Branding uses the original full-colour K+ PNG; do not tint its artwork.
      child: !svgImage.toLowerCase().endsWith('.svg')
          ? Image.asset(
              svgImage,
              height: avoideResponsive == true ? height : height?.rs(context),
              width: avoideResponsive == true ? width : width?.rs(context),
              fit: boxFit ?? BoxFit.contain,
            )
          : SvgPicture.asset(
              svgImage,
              height: avoideResponsive == true ? height : height?.rs(context),
              width: avoideResponsive == true ? width : width?.rs(context),
              colorFilter: color != null
                  ? ColorFilter.mode(color!, BlendMode.srcIn)
                  : null,
              colorMapper: colorMapper,
              fit: boxFit ?? BoxFit.contain,
            ),
    );
  }
}

/// Remaps the fixed brand colors baked into the illustration SVG exports
/// (`#0079FF` / `#E5F2FF`, the Figma fallback brand primaries) to the app's
/// current theme brand colors, leaving every other illustration color
/// (greys, skin tones, etc.) untouched.
class IllustrationBrandColorMapper extends ColorMapper {
  const IllustrationBrandColorMapper({
    required this.primaryColor,
    required this.primaryLightColor,
  });

  final Color primaryColor;
  final Color primaryLightColor;

  static const Color _illustrationPrimary = Color(0xFF5465FF);
  static const Color _illustrationPrimaryLight = Color(0xFFEEEFFF);

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    if (color.toARGB32() == _illustrationPrimary.toARGB32()) {
      return primaryColor;
    }
    if (color.toARGB32() == _illustrationPrimaryLight.toARGB32()) {
      return primaryLightColor;
    }
    return color;
  }
}
