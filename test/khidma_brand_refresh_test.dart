import 'package:e_demand/app/appAssets.dart';
import 'package:e_demand/ui/widgets/customCachedNetworkImage.dart';
import 'package:e_demand/ui/widgets/customSvgPicture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('latest K+ PNGs and SVG icons render in ${brightness.name}', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: const Scaffold(
            body: Column(
              children: [
                CustomSvgPicture(
                  svgImage: AppAssets.loginLogoLight,
                  width: 96,
                  height: 96,
                  color: Colors.red,
                  avoideResponsive: true,
                ),
                CustomSvgPicture(
                  svgImage: AppAssets.placeHolder,
                  width: 64,
                  height: 64,
                  avoideResponsive: true,
                ),
                CustomSvgPicture(
                  svgImage: AppAssets.googleIcon,
                  width: 24,
                  height: 24,
                  avoideResponsive: true,
                ),
                CustomCachedNetworkImage(
                  networkImageUrl: 'assets/images/flags/aus.png',
                  width: 48,
                  height: 32,
                  avoideResponsive: true,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        final context = tester.element(find.byType(Scaffold));
        await precacheImage(
          const AssetImage(AppAssets.loginLogoLight),
          context,
        );
        if (!context.mounted) return;
        await precacheImage(
          const AssetImage('assets/images/flags/aus.png'),
          context,
        );
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(SvgPicture), findsOneWidget);
      final images = tester.widgetList<Image>(find.byType(Image)).toList();
      expect(images, hasLength(3));
      // The inherited colour argument must not flatten the full-colour logo.
      expect(images.first.color, isNull);
      expect(
        (images.first.image as AssetImage).assetName,
        AppAssets.loginLogoLight,
      );
      expect(images.first.width, 96);
      expect(images.first.height, 96);
    });
  }
}
