import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';

class UnreadChatCounterBadgeContainer extends StatelessWidget {
  final int count;
  final double fontSize;
  final double padding;
  final EdgeInsetsGeometry? margin;
  const UnreadChatCounterBadgeContainer({
    super.key,
    required this.count,
    this.fontSize = 12,
    this.padding = 6,
    this.margin = const EdgeInsets.symmetric(horizontal: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.textError,
      ),
      margin: margin,
      padding: EdgeInsets.all(
        padding,
      ).add(const EdgeInsetsGeometry.only(bottom: 1)),
      child: CustomText(
        count > 99 ? "99+" : count.toString(),
        color: context.colors.textInverseLight,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        height: 1,
      ),
    );
  }
}
