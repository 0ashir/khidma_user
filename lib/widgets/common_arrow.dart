import '../config.dart';

class CommonArrow extends StatelessWidget {
  final bool? isThirteen;
  final String? arrow;
  final Color? color, svgColor;
  final GestureTapCallback? onTap;
  final double? padding;

  const CommonArrow(
      {super.key,
      this.arrow,
      this.color,
      this.svgColor,
      this.onTap,
      this.padding,
      this.isThirteen = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isThirteen == true ? Sizes.s30 : Sizes.s40,
      width: isThirteen == true ? Sizes.s30 : Sizes.s40,
      child: SvgPicture.asset(
        arrow!,
        fit: BoxFit.scaleDown,
        colorFilter: ColorFilter.mode(
            svgColor ?? appColor(context).darkText, BlendMode.srcIn),
      ),
    )
        .padding(all: padding ?? 0)
        .decorated(
            shape: BoxShape.circle,
            color: color ?? appColor(context).fieldCardBg)
        .inkWell(onTap: onTap);
  }
}
