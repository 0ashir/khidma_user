import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class TopRoundedUnderlineTabBar extends StatelessWidget
    implements PreferredSizeWidget {
  const TopRoundedUnderlineTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.height = 48,
    this.labelPadding = const EdgeInsets.symmetric(horizontal: 12),
    this.border,
    this.boxShadow,
    this.tabHeight,
  });

  final TabController controller;
  final List<Widget> tabs;
  final double height;
  final EdgeInsetsGeometry labelPadding;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  /// Height of each tab. Uses the Material default when null.
  final double? tabHeight;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: context.colors.surfacePrimary,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      border: border,
      boxShadow: boxShadow,
      child: TabBar(
        controller: controller,
        isScrollable: false,
        indicatorSize: TabBarIndicatorSize.tab,
        labelPadding: labelPadding,
        indicator: TopRoundedTabIndicator(
          color: context.colors.backgroundBrand,
        ),
        dividerColor: Colors.transparent,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        labelColor: context.colors.textBrand,
        unselectedLabelColor: context.colors.textPrimary,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 20 / 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 20 / 14,
        ),
        tabs: tabs.map((tab) => Tab(height: tabHeight, child: tab)).toList(),
      ),
    );
  }
}

class TopRoundedTabIndicator extends Decoration {
  const TopRoundedTabIndicator({
    required this.color,
    this.height = 4,
    this.radius = 8,
  });

  final Color color;
  final double height;
  final double radius;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _TopRoundedTabIndicatorPainter(
      color: color,
      height: height,
      radius: radius,
      onChanged: onChanged,
    );
  }
}

class _TopRoundedTabIndicatorPainter extends BoxPainter {
  _TopRoundedTabIndicatorPainter({
    required this.color,
    required this.height,
    required this.radius,
    VoidCallback? onChanged,
  }) : super(onChanged);

  final Color color;
  final double height;
  final double radius;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Size size = configuration.size!;
    final Rect rect =
        Offset(offset.dx, offset.dy + size.height - height) &
        Size(size.width, height);
    final RRect rRect = RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(radius),
      topRight: Radius.circular(radius),
    );
    canvas.drawRRect(rRect, Paint()..color = color);
  }
}
