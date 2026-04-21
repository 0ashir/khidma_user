import 'dart:developer';

import 'package:fixit_user/models/service_details_model.dart';

import '../../../../config.dart';

class ServiceDescription extends StatelessWidget {
  final ServiceDetailsModel? services;

  const ServiceDescription({super.key, this.services});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(builder: (context, lang, child) {
      log("services?.categories?[0].title::${services?.description}");
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
              child: DescriptionLayout(
                  icon: eSvgAssets.clock,
                  title: translations!.time,
                  subtitle:
                      "${services?.duration} ${services?.durationUnit != null ? services!.durationUnit : "hours"}")),
          Container(
            color: appColor(context).stroke,
            width: 2,
            height: Sizes.s78,
          ),
          /* if (services!.relatedServices.isNotEmpty && services!.relatedServices[0].categories.isNotEmpty)*/
          /* Expanded(
            child: DescriptionLayout(
              icon: eSvgAssets.categories,
              title: translations?.category ?? "",
              subtitle: services?.categories != null &&
                      services!.categories.isNotEmpty
                  ? services?.categories.first.title ?? ""
                  : "",
              */ /* services?.relatedServices != null &&
                      services!.relatedServices.isNotEmpty &&
                      services?.relatedServices.first.categories != null &&
                      services!.relatedServices.first.categories.isNotEmpty
                  ? services?.relatedServices.first.categories.first.title
                  : "" */ /*

              */ /* subtitle: services?.relatedServices != null &&
                            services!.relatedServices.isNotEmpty
                        ? services?.relatedServices.first.categories == null
                            ? ""
                            : services
                                ?.relatedServices.first.categories.first.title
                        : "" */ /*
            ).paddingOnly(
                left: lang.locale?.languageCode == "ar" ? 0 : Insets.i20,
                right: lang.locale?.languageCode == "ar" ? 0 : Insets.i20),
          )*/
          Expanded(
            child: DescriptionLayout(
                    icon: eSvgAssets.accountTag,
                    title: translations!.requiredServicemen,
                    subtitle:
                        "${services?.requiredServicemen ?? '1'} ${capitalizeFirstLetter(language(context, translations!.serviceman))}")
                .paddingOnly(left: Insets.i20),
          )
        ]).paddingSymmetric(horizontal: Insets.i25),
        const DottedLines(),
        const VSpace(Sizes.s17),
        DescriptionLayout(
          icon: eSvgAssets.categories,
          title: translations?.category ?? "",
          subtitle:
              services?.categories != null && services!.categories!.isNotEmpty
                  ? services!.categories!
                      .map((cat) => cat.title ?? '')
                      .where((title) => title.isNotEmpty)
                      .join(' • ')
                  : "",
        ).paddingOnly(
            left: lang.locale?.languageCode == "ar" ? 0 : Insets.i20,
            right: lang.locale?.languageCode == "ar" ? 0 : Insets.i20),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Text("${language(context, translations!.serviceType)} : ",
                  style: appCss.dmDenseMedium12
                      .textColor(appColor(context).lightText)),
              const HSpace(Sizes.s6),
              Text(
                services?.type == "fixed"
                    ? language(context, translations!.userSite)
                    : services?.type?.capitalizeFirst() ?? "",
                style: TextStyle(
                    color: appColor(context).darkText,
                    fontFamily: GoogleFonts.dmSans().fontFamily,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const VSpace(Sizes.s20),
          if (services?.content != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(language(context, translations!.content),
                    style: appCss.dmDenseMedium12
                        .textColor(appColor(context).lightText)),
                const VSpace(Sizes.s6),
                ReadMoreLayout(
                  text: services!.content,
                  isHtml: true,
                ),
                const VSpace(Sizes.s20),
              ],
            ),

          ProviderDetailsLayout(
              image: (services?.user?.media != null &&
                      services!.user!.media.isNotEmpty)
                  ? services!.user!.media[0].originalUrl
                  : "",
              pName: services?.user?.name ?? '',
              rating: services?.user?.reviewRatings != null
                  ? services!.user?.reviewRatings.toString()
                  : "0.0",
              experience:
                  "${services?.user?.experienceDuration ?? ""} ${capitalizeFirstLetter(services?.user?.experienceInterval ?? 'Hours')} ${language(context, translations!.of)} ${language(context, translations!.experience)}",
              onTap: () {
                Provider.of<ProviderDetailsProvider>(context, listen: false)
                    .getProviderById(context, services!.user!.id);
                route.pushNamed(context, routeName.providerDetailsScreen,
                    arg: {'providerId': services!.user!.id});
              },
              service: services?.user?.served.toString() ?? "0"),
          // if (services?.reviews.isNotEmpty ?? false)
          //   HeadingRowCommon(
          //           title: translations!.review,
          //           onTap: () => route.pushNamed(
          //               context, routeName.servicesReviewScreen,
          //               arg: services!))
          //       .paddingOnly(top: Insets.i20, bottom: Insets.i12),
          // if (services?.reviews.isNotEmpty ?? false)
          //   Column(
          //       children: services!.reviews.asMap().entries.map((e) {
          //     log("e.value::${e.value}");
          //     return ServiceReviewLayout(
          //         data: e.value, index: e.key, list: appArray.reviewList);
          //   }).toList())
        ]).paddingSymmetric(horizontal: Insets.i20, vertical: Insets.i20)
      ]).boxBorderExtension(context, isShadow: true);
    });
  }
}
