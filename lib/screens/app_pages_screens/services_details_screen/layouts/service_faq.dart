import '../../../../config.dart';

class ServiceFaq extends StatelessWidget {
  const ServiceFaq({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ServicesDetailsProvider>(
        builder: (context, serviceCtrl, _) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const VSpace(Sizes.s10),
          Text(language(context, translations!.faq),
                  overflow: TextOverflow.clip,
                  style: appCss.dmDenseBold16
                      .textColor(appColor(context).darkText))
              .paddingSymmetric(horizontal: Sizes.s20),
          const VSpace(Sizes.s10),
          ...serviceCtrl.serviceFaq.asMap().entries.map((e) => Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: Sizes.s20, vertical: Sizes.s8),
                padding: const EdgeInsets.symmetric(horizontal: Sizes.s20),
                decoration: ShapeDecoration(
                    shadows: [
                      BoxShadow(
                          blurRadius: 2,
                          spreadRadius: 2,
                          color: appColor(context).darkText.withOpacity(0.06))
                    ],
                    color: appColor(context).whiteBg,
                    shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                            cornerRadius: 8, cornerSmoothing: 1))),
                child: ExpansionTile(
                    expansionAnimationStyle:
                        const AnimationStyle(curve: Curves.fastOutSlowIn),
                    key: Key(serviceCtrl.selected.toString()),
                    initiallyExpanded: e.key == serviceCtrl.selected,
                    onExpansionChanged: (newState) =>
                        serviceCtrl.onExpansionChange(newState, e.key),
                    //atten
                    tilePadding: EdgeInsets.zero,
                    collapsedIconColor: appColor(context).darkText,
                    dense: true,
                    iconColor: appColor(context).darkText,
                    title: Text(e.value.question ?? '',
                        style: appCss.dmDenseMedium14
                            .textColor(appColor(context).darkText)),
                    children: <Widget>[
                      Divider(
                        color: appColor(context).stroke,
                        height: .5,
                        thickness: 0,
                      ),
                      ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: Sizes.s5),
                          title: Text(e.value.answer ?? '',
                              style: appCss.dmDenseLight14.textColor(
                                  appColor(context).darkText.withOpacity(.8))))
                    ]),
              ))
        ],
      ).marginOnly(top: Sizes.s10);
    });
  }
}
