import '../../../../config.dart';

class ServicemanBottomLayout extends StatelessWidget {
  const ServicemanBottomLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(builder: (context, value, child) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(language(context, translations!.personalInfo),
            style:
                appCss.dmDenseMedium14.textColor(appColor(context).darkText)),
        const VSpace(Sizes.s10),
        Column(children: [
          PersonalInfoRowLayout(
              icon: eSvgAssets.mail,
              title: translations!.mail,
              content: "theodoret.c.calvin@gmail.com"),
          const VSpace(Sizes.s20),
          PersonalInfoRowLayout(
              icon: eSvgAssets.phone,
              title: translations!.call,
              content: "+1 236 236 5653")
        ])
            .paddingSymmetric(vertical: Insets.i12, horizontal: Insets.i15)
            .boxShapeExtension(color: appColor(context).fieldCardBg),
        Text(language(context, translations!.knowLanguage),
                style: appCss.dmDenseMedium14
                    .textColor(appColor(context).darkText))
            .alignment(Alignment.centerLeft)
            .paddingOnly(top: Insets.i20, bottom: Insets.i10),
        Wrap(
            direction: Axis.horizontal,
            children: appArray.languagesList
                .asMap()
                .entries
                .map((e) => LanguageLayout(title: e.value))
                .toList()),
        const VSpace(Sizes.s20),
        Text(language(context, translations!.expertiseIn),
                style: appCss.dmDenseMedium14
                    .textColor(appColor(context).darkText))
            .alignment(Alignment.centerLeft),
        const VSpace(Sizes.s10),
        Wrap(
            direction: Axis.horizontal,
            children: appArray.expertiseList
                .asMap()
                .entries
                .map((e) => Text(language(context, "\u2022  ${e.value}"),
                        style: appCss.dmDenseMedium12
                            .textColor(appColor(context).darkText))
                    .paddingOnly(right: Insets.i25))
                .toList()),
        const VSpace(Sizes.s20),
        Text(language(context, translations!.description),
                style: appCss.dmDenseMedium14
                    .textColor(appColor(context).darkText))
            .alignment(Alignment.centerLeft),
        const VSpace(Sizes.s10),
      ]);
    });
  }
}
