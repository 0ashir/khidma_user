import '../../../../../config.dart';

class JobRequestServiceDescription extends StatelessWidget {
  final JobRequestModel? services;

  const JobRequestServiceDescription({super.key, this.services});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(builder: (context, lang, child) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
              child: DescriptionLayout(
                      icon: eSvgAssets.clock,
                      title: translations!.time,
                      subtitle:
                          "${services!.duration} ${services!.durationUnit}")
                  .paddingDirectional(
                      vertical: services!.bids!.isNotEmpty ? 0 : 15)),
          if (services!.bids!.isNotEmpty)
            Container(
              color: appColor(context).stroke,
              width: 2,
              height: Sizes.s78,
            ),
          if (services!.bids!.isNotEmpty)
            Expanded(
              child: DescriptionLayout(
                      icon: eSvgAssets.categories,
                      title: translations!.category,
                      subtitle: services!.category![0]['title'])
                  .paddingOnly(
                      left: lang.locale?.languageCode == "ar" ? 0 : Insets.i20,
                      right:
                          lang.locale?.languageCode == "ar" ? 0 : Insets.i20),
            )
        ]).paddingSymmetric(horizontal: Insets.i25),
        const DottedLines(),
        const VSpace(Sizes.s17),
        DescriptionLayout(
                icon: eSvgAssets.accountTag,
                title: translations!.requiredServicemen,
                subtitle:
                    "${services!.requiredServicemen ?? '1'} ${capitalizeFirstLetter(language(context, translations!.serviceman))}")
            .paddingSymmetric(horizontal: Insets.i25),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(language(context, translations!.description),
              style: appCss.dmDenseMedium12
                  .textColor(appColor(context).lightText)),
          const VSpace(Sizes.s6),
          if (services!.description != null)
            ReadMoreLayout(text: services!.description!),
          const VSpace(Sizes.s20),
        ]).paddingSymmetric(horizontal: Insets.i20, vertical: Insets.i20)
      ]).boxBorderExtension(context, isShadow: true);
    });
  }
}
