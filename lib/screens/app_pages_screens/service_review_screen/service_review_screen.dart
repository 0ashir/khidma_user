import '../../../config.dart';

class ServiceReviewScreen extends StatelessWidget {
  const ServiceReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceReviewProvider>(
        builder: (context1, serviceCtrl, child) {
      return StatefulWrapper(
        onInit: () => Future.delayed(DurationClass.ms50)
            .then((s) => serviceCtrl.onReady(context)),
        child: Scaffold(
            appBar: AppBarCommon(title: translations!.review),
            body: serviceCtrl.services == null &&serviceCtrl.services?.reviewRatings==null
                ? EmptyLayout(title: translations!.noDataFound,subtitle: "",)
                : SingleChildScrollView(
                    child: Column(children: [
                      if(serviceCtrl.services!.reviewRatings!=null)
                    Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                          RatingLayout(
                              initialRating: double.tryParse(serviceCtrl.services?.ratingCount?.toString() ?? '') ?? 0.0
                          ),
                          Row(children: [
                            Text(language(context, translations!.averageRate),
                                style: appCss.dmDenseMedium12
                                    .textColor(appColor(context).primary)),
                            const HSpace(Sizes.s4),
                            Text("${serviceCtrl.services!.ratingCount}/5",
                                style: appCss.dmDenseSemiBold12
                                    .textColor(appColor(context).primary))
                          ])
                        ])
                        .paddingSymmetric(
                            vertical: Insets.i12, horizontal: Insets.i15)
                        .decorated(
                            color: appColor(context).primary.withOpacity(0.2),
                            border:
                                Border.all(color: appColor(context).primary),
                            borderRadius: BorderRadius.circular(AppRadius.r20))
                        .paddingSymmetric(horizontal: Insets.i40),
                    const VSpace(Sizes.s15),
                    if(serviceCtrl.services!.reviewRatings!=null)
                    Column(
                            children: serviceCtrl
                                .services!.reviewRatings!.reversed
                                .toList()
                                .asMap()
                                .entries
                                .map((e) => ProgressBarLayout(
                                    data: e.value,
                                    index: e.key,
                                    list: serviceCtrl.services!.reviewRatings!))
                                .toList())
                        .paddingSymmetric(
                            vertical: Insets.i15, horizontal: Insets.i20)
                        .boxBorderExtension(context, isShadow: true),
                      if(serviceCtrl.services!.reviewRatings!=null)
                    const VSpace(Sizes.s25),
                    Row(children: [
                      Expanded(
                          child: Text(language(context, translations!.reviews),
                              style: appCss.dmDenseMedium16
                                  .textColor(appColor(context).darkText))),
                      Expanded(
                          child: DropDownLayout(
                              isIcon: false,
                              val: serviceCtrl.exValue,
                              categoryList: appArray.reviewLowHighList,
                              onChanged: (val) => serviceCtrl.onReview(val)))
                    ]),
                    const VSpace(Sizes.s15),
                    ...serviceCtrl.reviewList.asMap().entries.map((e) =>
                        ServiceReviewLayout(
                            data: e.value,
                            index: e.key,
                            list: serviceCtrl.reviewList))
                  ]).paddingSymmetric(horizontal: Insets.i20))),
      );
    });
  }
}
