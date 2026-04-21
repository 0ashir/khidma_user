import '../../../../config.dart';

class ProviderRatingReviewScreen extends StatefulWidget {
  const ProviderRatingReviewScreen({super.key});

  @override
  State<ProviderRatingReviewScreen> createState() =>
      _ProviderRatingReviewScreenState();
}

class _ProviderRatingReviewScreenState extends State<ProviderRatingReviewScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Consumer<MyReviewProvider>(builder: (context1, value, child) {
      return Scaffold(
          appBar: AppBar(
              leadingWidth: 80,
              title: Text(language(context, translations!.providerReviews),
                  style: appCss.dmDenseBold18
                      .textColor(appColor(context).darkText)),
              centerTitle: true,
              leading: CommonArrow(
                  arrow: rtl(context)
                      ? eSvgAssets.arrowRight
                      : eSvgAssets.arrowLeft,
                  onTap: () => route.pop(context)).paddingAll(Insets.i8)),
          body: ListView(children: [
            /*  if(value.isLoading==true)
              Center(
                  child: Image.asset(
                    eGifAssets.loader,
                    height: Sizes.s100,
                  )),
            if (value.isLoading==false&&value.reviews.isEmpty)
              const CommonEmpty()
                  .paddingOnly(top: MediaQuery.of(context).size.height / 8),*/
            // if (value.reviews.isNotEmpty)
            value.isLoading
                ? Center(
                    child: Image.asset(
                    eGifAssets.loader,
                    color: appColor(context).primary,
                    height: Sizes.s100,
                  )).paddingDirectional(top: Sizes.s250)
                : value.providerReviews.isEmpty
                    ? const CommonEmpty().paddingOnly(
                        top: MediaQuery.of(context).size.height / 8)
                    : Column(children: [
                        ...value.providerReviews.asMap().entries.map((e) =>
                            ReviewLayout(data: e.value, isEditDelete: false))
                      ])
          ])
              .height(MediaQuery.of(context).size.height)
              .paddingAll(Insets.i20));
    });
  }
}
