import 'package:e_demand/ui/widgets/imageLoadingPlaceholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<Size> sizeOf(final WidgetTester tester, final Widget child) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
    return tester.getSize(find.byType(Container).last);
  }

  testWidgets('uses the image size when given', (tester) async {
    expect(
      await sizeOf(
        tester,
        const Center(
          child: ImageLoadingPlaceholder(
            width: 60,
            height: 40,
            avoideResponsive: true,
          ),
        ),
      ),
      const Size(60, 40),
    );
  });

  testWidgets('fills a sized parent (e.g. a banner)', (tester) async {
    expect(
      await sizeOf(
        tester,
        const Center(
          child: SizedBox(
            width: 300,
            height: 140,
            child: ImageLoadingPlaceholder(avoideResponsive: true),
          ),
        ),
      ),
      const Size(300, 140),
    );
  });

  testWidgets('stays narrow along an unbounded axis', (tester) async {
    final Size size = await sizeOf(
      tester,
      const Row(children: [ImageLoadingPlaceholder(avoideResponsive: true)]),
    );
    expect(size.width, 24);
    expect(tester.takeException(), isNull);
  });
}
