import 'dart:async';
import '../../../config.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, OnBoardingProvider>(
        builder: (context, lang, onBoardPro, child) {
      return StatefulWrapper(
          onInit: () => Timer(const Duration(milliseconds: 200),
              () => onBoardPro.onReady(context, this)),
          onDispose: () => onBoardPro.onDispose(),
          child: Scaffold(
              body: SafeArea(
                  child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(eImageAssets.onBoardBox,
                        color: appColor(context).darkText)
                    .padding(
                        bottom: Insets.i50,
                        left: Insets.i20,
                        right: Insets.i20),
              ),
              Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const LanguageDropDownLayout()
                        .paddingSymmetric(horizontal: Insets.i20)
                        .paddingOnly(top: Insets.i20, bottom: Insets.i20),
                    /* onBoardPro.selectIndex == 0
                                          ? Image.network(
                        onboardingScreens[0].imageUrl,
                        height: 325,
                        width: 320,
                      )
                                          : onBoardPro.selectIndex == 1
                        ? Image.network(
                            onboardingScreens[1].imageUrl,
                            height: 325,
                            width: 320,
                          )
                        : onBoardPro.selectIndex == 2
                            ? Image.network(
                                onboardingScreens[2].imageUrl,
                                height: 325,
                                width: 320,
                              )
                            : Image.network(
                                onboardingScreens[3].imageUrl,
                                height: 325,
                                width: 320,
                              ),
                                      VSpace(Sizes.s20), */
                    /* onBoardPro.selectIndex == 0
                                          ? const AnimationLayoutOne()
                                          : onBoardPro.selectIndex == 1
                        ? const AnimationLayoutSecond()
                        : onBoardPro.selectIndex == 2
                            ? const AnimationLayoutThree()
                            : const AnimationFourthLayout(), */
                    Expanded(
                        child: PageView.builder(
                            onPageChanged: (index) =>
                                onBoardPro.onPageChange(index),
                            itemCount: onBoardPro.onBoardingList.length,
                            controller: onBoardPro.pageController,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (pageContext, index) {
                              return Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // CachedNetworkImage(
                                    //     imageUrl: onboardingScreens[
                                    //     onBoardPro.selectIndex]
                                    //         .image,
                                    //     imageBuilder: (context, imageProvider) => Image(
                                    //         image: imageProvider,
                                    //         height: 325,
                                    //         width: 320),
                                    //     errorWidget: (context, url, error) => Image.asset(
                                    //         "assets/images/ob-1.png",
                                    //         height: 325,
                                    //         width: 320)),
                                    onBoardPro.selectIndex >= 0 &&
                                            onBoardPro.selectIndex <
                                                onboardingScreens.length
                                        ? Image.network(
                                            onboardingScreens[
                                                    onBoardPro.selectIndex]
                                                .image,
                                            height: 325,
                                            width: 320,
                                          )
                                        : const SizedBox.shrink(),
                                    // or a placeholder widget

                                    const VSpace(Sizes.s20),
                                    BottomLayout(
                                            title: onboardingScreens.isEmpty
                                                ? language(
                                                    context,
                                                    appArray.onBoardingList[
                                                        index]["title"])
                                                : language(
                                                    context,
                                                    onboardingScreens[index]
                                                        .title
                                                        .toUpperCase()),
                                            subText: onboardingScreens.isEmpty
                                                ? language(
                                                    context,
                                                    appArray.onBoardingList[
                                                        index]["subtext"])
                                                : language(
                                                    context,
                                                    onboardingScreens[index]
                                                        .description))
                                        .padding(top: Insets.i70)
                                  ]).paddingSymmetric(horizontal: Insets.i20);
                            })),
                    const VSpace(Sizes.s20),
                    const DotIndicatorLayout().padding(
                        horizontal: Insets.i15,
                        bottom: MediaQuery.of(context).size.height * 0.1),

                    /* const VSpace(Sizes.s10), */
                    /*   const DotIndicatorLayout(), */
                    /*   const VSpace(Sizes.s17) */
                    /* Stack(alignment: Alignment.center, children: [
                                        Image.asset(eImageAssets.onBoardBox,
                          color: appColor(context)
                              .darkText /* .withOpacity(0.5) */)
                      .paddingOnly(bottom: Insets.i20),
                                        Column(children: [
                                          SizedBox(
                        height: Sizes.s120,
                        child: PageView.builder(
                            onPageChanged: (index) =>
                                onBoardPro.onPageChange(index),
                            itemCount: onBoardPro.onBoardingList.length,
                            controller: onBoardPro.pageController,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (pageContext, index) {
                              return BottomLayout(
                                  title: onboardingScreens.isEmpty
                                      ? language(
                                          context,
                                          appArray.onBoardingList[index]
                                              ["title"])
                                      : language(
                                          context,
                                          onboardingScreens[index].title == null
                                              ? appArray.onBoardingList[index]
                                                  ["title"]
                                              : onboardingScreens[index]
                                                  .title
                                                  .toUpperCase() /* appArray.onBoardingList[index]["title"] */),
                                  subText: onboardingScreens.isEmpty
                                      ? language(
                                          context,
                                          appArray.onBoardingList[index]
                                              ["subtext"])
                                      : language(
                                          context,
                                          onboardingScreens[index]
                                                      .description ==
                                                  null
                                              ? appArray.onBoardingList[index]
                                                  ["subtext"]
                                              : onboardingScreens[index]
                                                  .description
                                          /* appArray.onBoardingList[index]
                                          ["subtext"] */
                                          ));
                            })),
                                          const VSpace(Sizes.s10),
                                          const DotIndicatorLayout()
                                        ])
                                      ]).paddingSymmetric(horizontal: Insets.i20) */
                  ]),
              /*  DotIndicatorLayout()
                  /* .padding(top: 600, bottom: Sizes.s20) */
                  .paddingSymmetric(horizontal: Insets.i20), */
            ],
          ))));
    });
  }
}
