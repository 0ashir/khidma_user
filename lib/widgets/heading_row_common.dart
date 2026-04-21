import '../config.dart';

class HeadingRowCommon extends StatelessWidget {
  final String? title;
  final GestureTapCallback? onTap;
  final bool isTextSize;
  final bool isViewAll;
  const HeadingRowCommon(
      {super.key,
      this.title,
      this.onTap,
      this.isTextSize = false,
      this.isViewAll = true});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Expanded(
          child: Text(language(context, title!),
              overflow: TextOverflow.clip,
              style: isTextSize
                  ? appCss.dmDenseBold18.textColor(appColor(context).darkText)
                  : appCss.dmDenseBold16
                      .textColor(appColor(context).darkText))),
      if (isViewAll == true)
        Text(language(context, translations!.viewAll),
                style: appCss.dmDenseRegular14
                    .textColor(appColor(context).primary))
            .inkWell(onTap: onTap)
    ]);
  }
}
