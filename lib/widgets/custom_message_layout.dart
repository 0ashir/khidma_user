import '../config.dart';

class CustomMessageLayout extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final GestureTapCallback? onTap;
  const CustomMessageLayout(
      {super.key, this.controller, this.focusNode, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(rtl(context) ? "ملاحظات اضافيه ( رقم لوحه السياره)" : "Additional Instruction (Car Plate No)",
          style: appCss.dmDenseMedium14.textColor(appColor(context).darkText)),
      const VSpace(Sizes.s10),
      TextFieldCommon(
          focusNode: focusNode,
          controller: controller,
          isNumber: true,
          onTap: onTap,
          hintText: translations!.writeHere!,
          maxLines: 4,
          minLines: 4,
          fillColor: appColor(context).fieldCardBg),
    ]).paddingSymmetric(horizontal: Insets.i20);
  }
}
