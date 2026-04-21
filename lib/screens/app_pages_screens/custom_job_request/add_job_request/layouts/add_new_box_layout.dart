import '../../../../../config.dart';

class AddNewBoxLayout extends StatelessWidget {
  final GestureTapCallback? onAdd;
  final double? width;
  final String? title;
  const AddNewBoxLayout({super.key, this.onAdd, this.width, this.title});

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
        color: appColor(context).stroke,
        borderType: BorderType.RRect,
        radius: const Radius.circular(AppRadius.r10),
        child: ClipRRect(
                borderRadius:
                    const BorderRadius.all(Radius.circular(AppRadius.r8)),
                child: Container(
                    alignment: Alignment.center,
                    width: width ?? Sizes.s70,
                    height: Sizes.s70,
                    color: appColor(context).whiteBg,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      SvgPicture.asset(eSvgAssets.add),
                      const VSpace(Sizes.s6),
                      Expanded(
                        child: Text(
                            language(
                                context, title ?? translations!.chooseImages),
                            overflow: TextOverflow.clip,
                            textAlign: TextAlign.center,
                            style: appCss.dmDenseMedium12
                                .textColor(appColor(context).lightText)),
                      )
                    ]).paddingSymmetric(vertical: Insets.i15)))
            .inkWell(onTap: onAdd));
  }
}
