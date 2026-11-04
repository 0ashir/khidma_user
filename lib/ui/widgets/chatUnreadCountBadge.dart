import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';

class ChatUnreadCountBadge extends StatelessWidget {
  final int count;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;

  const ChatUnreadCountBadge({
    super.key,
    required this.count,
    this.fontSize = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: context.colors.backgroundBrand,
        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf50),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 0.5)
            : null,
      ),
      child: CustomText(
        count > 99 ? "99+" : count.toString(),
        color: context.colors.textInverseLight,
        fontSize: fontSize,
        height: 1,
      ),
    );
  }
}
