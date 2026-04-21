import '../../../config.dart';

class RateAppScreen extends StatelessWidget {
  const RateAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, RateAppProvider>(
        builder: (context1, lang, value, child) {
      return StatefulWrapper(
        onInit: () => Future.delayed(DurationClass.ms50)
            .then((_) => value.onReady(context)),
        child: Scaffold(
          appBar: AppBar(
              leadingWidth: 80,
              title: Text(
                  language(
                      context,
                      value.isServiceRate
                          ? translations!.yourFeedback
                          : translations!.rateApp),
                  style: appCss.dmDenseBold18
                      .textColor(appColor(context).darkText)),
              centerTitle: true,
              leading: CommonArrow(
                      arrow: rtl(context)
                          ? eSvgAssets.arrowRight
                          : eSvgAssets.arrowLeft,
                      onTap: () => route.pop(context))
                  .paddingDirectional(vertical: Insets.i8)),
          body: ListView(
            children: [
              Form(
                key: value.rateKey,
                child: Column(children: [
                  Text(language(context, translations!.whatDoYouThink),
                          style: appCss.dmDenseMedium14
                              .textColor(appColor(context).lightText))
                      .paddingAll(Insets.i20),
                  const DottedLines(),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(language(context, translations!.explainEmoji),
                            style: appCss.dmDenseMedium14
                                .textColor(appColor(context).darkText)),
                        const VSpace(Sizes.s12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: appArray.editReviewList
                              .asMap()
                              .entries
                              .map((e) => EditReviewLayout(
                                  data: e.value,
                                  index: e.key,
                                  selectIndex: value.selectedIndex,
                                  onTap: () => value.onTapEmoji(e.key)))
                              .toList(),
                        ).width(MediaQuery.of(context).size.width),
                        const VSpace(Sizes.s25),
                        Text(language(context, translations!.saySomething),
                            style: appCss.dmDenseMedium14
                                .textColor(appColor(context).darkText)),
                        const VSpace(Sizes.s12),
                        TextFieldCommon(
                          hintText: translations!.writeHere!,
                          minLines: 8,
                          maxLines: 8,
                          maxLength: 150,
                          controller: value.rateController,
                          focusNode: value.rateFocus,
                          isNumber: true,
                          validator: (val) =>
                              validation.commonValidation(context, val),
                        )
                      ]).paddingAll(Insets.i20)
                ]).boxShapeExtension(
                    color: appColor(context).fieldCardBg,
                    radius: AppRadius.r12),
              ),
              const VSpace(Sizes.s40),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                decoration: ShapeDecoration(
                    color: appColor(context).primary,
                    shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                            cornerRadius: AppRadius.r8, cornerSmoothing: 1))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    value.isRateLoader
                        ? const CircularProgressIndicator(color: Colors.white)
                            .center()
                            .padding(vertical: Sizes.s5)
                        : Text(language(context, translations!.submit),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: appCss.dmDenseRegular16
                                .textColor(appColor(context).whiteColor)),
                  ],
                ),
              ).inkWell(onTap: () => value.onSubmit(context))
              /*  ButtonCommon(
                  title: translations!.submit,
                  onTap: () => value.onSubmit(context)) */
            ],
          ).paddingAll(Insets.i20),
        ),
      );
    });
  }
}
