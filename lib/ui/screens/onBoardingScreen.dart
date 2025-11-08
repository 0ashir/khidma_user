import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();

  static Route route(final RouteSettings routeSettings) => CupertinoPageRoute(
        builder: (final _) => const OnBoardingScreen(),
      );
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  int currentSliderImage = 0;

  @override
  void initState() {
    super.initState();

    // /// loading country codes before we load login screen
    // context.read<CountryCodeCubit>().loadAllCountryCode(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness:
              context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                  ? Brightness.light
                  : Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
          statusBarIconBrightness:
              context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                  ? Brightness.light
                  : Brightness.dark,
        ),
        child: Column(
          children: [
            const ImageSliderWithBlurEffectAndIndicators(),
            SizedBox(
              height: context.screenHeight * 0.05,
            ),
            Padding(
              padding: ResponsiveHelper.isLargeTablet(context) ||
                      ResponsiveHelper.isTablet(context)
                  ? const EdgeInsets.symmetric(horizontal: 15).copyWith(
                      right: 100.rh(context),
                      left: 100.rh(context),
                    )
                  : const EdgeInsets.symmetric(horizontal: 15),
              child: CustomRoundedButton(
                  buttonTitle: "getStarted".translate(context: context),
                  showBorder: false,
                  widthPercentage: 1,
                  backgroundColor: context.colorScheme.accentColor,
                  onTap: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (final route) => false,
                      arguments: {"source": "introSliderScreen"},
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageSliderWithBlurEffectAndIndicators extends StatefulWidget {
  const ImageSliderWithBlurEffectAndIndicators({super.key});

  @override
  State<ImageSliderWithBlurEffectAndIndicators> createState() =>
      _ImageSliderWithBlurEffectAndIndicatorsState();
}

class _ImageSliderWithBlurEffectAndIndicatorsState
    extends State<ImageSliderWithBlurEffectAndIndicators> {
  int currentSliderImage = 0;

  final ScrollController _scrollController = ScrollController();
  var totalScroll;
  var currentScroll;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.screenHeight * 0.85,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CarouselSlider(
              options: CarouselOptions(
                height: context.screenHeight * 0.85,
                viewportFraction: 1,
                initialPage: 0,
                enableInfiniteScroll: true,
                reverse: false,
                autoPlay: true,
                autoPlayInterval: Duration(
                    milliseconds: sliderAnimationDurationSettings[
                        "sliderAnimationDuration"]),
                autoPlayAnimationDuration: Duration(
                    milliseconds: sliderAnimationDurationSettings[
                        "changeSliderAnimationDuration"]),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: false,
                pauseAutoPlayOnTouch: false,
                enlargeFactor: 1,
                aspectRatio: 1,
                scrollDirection: Axis.horizontal,
                onPageChanged: (index, reason) {
                  setState(() {
                    currentSliderImage = index;
                  });
                },
              ),
              items: List.generate(
                introScreenList.length,
                (index) => Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CustomContainer(
                          alignment: Alignment.topCenter,
                          child: CustomContainer(
                            borderRadiusStyle: const BorderRadius.only(
                              bottomRight: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                            image: DecorationImage(
                              image: ExactAssetImage(
                                  introScreenList[index].imagePath),
                              fit: BoxFit.cover,
                            ),
                            width: context.screenWidth,
                            height: context.screenHeight * 0.6 - 14,
                          ),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                                sigmaX: 4.0,
                                sigmaY: 4.0,
                                tileMode: TileMode.decal),
                            child: CustomContainer(
                              borderRadiusStyle: const BorderRadius.only(
                                bottomRight: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                              image: DecorationImage(
                                image: ExactAssetImage(
                                    introScreenList[index].imagePath),
                                fit: BoxFit.cover,
                              ),
                              width: context.screenWidth,
                              height: context.screenHeight * 0.6 - 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: context.screenHeight * 0.05,
                    ),
                    SizedBox(
                      height: context.screenHeight * 0.2,
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: CustomText(
                                  introScreenList[index]
                                      .introScreenTitle
                                      .translate(context: context),
                                  color:
                                      Theme.of(context).colorScheme.blackColor,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 26,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: CustomText(
                                  introScreenList[index]
                                      .introScreenSubTitle
                                      .translate(context: context),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .lightGreyColor,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 16,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )),
          //indicators
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
                height: context.screenHeight * 0.6,
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      child: CustomContainer(
                        height: 24,
                        child: LayoutBuilder(
                          builder: (p0, p1) {
                            return Center(
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                scrollDirection: Axis.horizontal,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 13, sigmaY: 13),
                                    child: CustomContainer(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(
                                          introScreenList.length,
                                          (index) {
                                            return getIndicator(
                                                index: index, p1: p1);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ))),
          ),
        ],
      ),
    );
  }

  Widget getIndicator({required int index, required BoxConstraints p1}) {
    return Stack(
      children: [
        AnimatedContainer(
          alignment: AlignmentDirectional.centerStart,
          curve: Curves.easeIn,
          duration: Duration(
              milliseconds: sliderAnimationDurationSettings[
                  "changeSliderAnimationDuration"]),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          height: 8,
          width: currentSliderImage == index ? 30 : 8,
          decoration: BoxDecoration(
            color: context.colorScheme.secondaryColor,
            borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf50),
          ),
          child: currentSliderImage == index
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    //we will get total available scroll with (padding between indicator + indicator size)
                    // + added 22, because active indicator extra width of 22
                    totalScroll = (introScreenList.length * 18) + 22;
                    currentScroll = (index * 18) + 22;
                    if (currentScroll >= p1.maxWidth) {
                      final currentScrolls = _scrollController.position.pixels;
                      _scrollController.animateTo(
                        currentScrolls + 5,
                        duration: const Duration(milliseconds: 10),
                        curve: Curves.easeInOut,
                      );
                    } else if (index == 0 &&
                        _scrollController.position.pixels != 0) {
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 10),
                        curve: Curves.easeInOut,
                      );
                    }
                    return const SizedBox();
                  },
                )
              : const SizedBox(),
        ),
        AnimatedContainer(
          duration: currentSliderImage == index
              ? Duration(
                  milliseconds: sliderAnimationDurationSettings[
                      "sliderAnimationDuration"])
              : Duration.zero,
          width: currentSliderImage == index ? 30 : 8,
          curve: Curves.easeIn,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          height: 8,
          decoration: BoxDecoration(
            color: currentSliderImage == index
                ? context.colorScheme.accentColor
                : context.colorScheme.secondaryColor,
            borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf50),
          ),
        )
      ],
    );
  }
}
