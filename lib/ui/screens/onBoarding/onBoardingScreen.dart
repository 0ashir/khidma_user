import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/core/analytics/google_analytics_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();

  static Route route(final RouteSettings routeSettings) =>
      CupertinoPageRoute(builder: (final _) => const OnBoardingScreen());
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  int currentSliderImage = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  bool get _isLastSlide => currentSliderImage == introScreenList.length - 1;

  double _textSlotHeight(BuildContext context) {
    final double maxWidth =
        context.screenWidth -
        MediaQuery.paddingOf(context).horizontal -
        (_horizontalPadding(context) * 2);

    return introScreenList.fold<double>(0, (tallest, introScreen) {
      final CustomText title = _onBoardingTitle(context, introScreen);
      final CustomText description = _onBoardingDescription(
        context,
        introScreen,
      );

      final double height =
          _measureText(
            context: context,
            text: title.text,
            style: title.textStyle(context),
            maxWidth: maxWidth,
          ) +
          _titleToDescriptionGap +
          _measureText(
            context: context,
            text: description.text,
            style: description.textStyle(context),
            maxWidth: maxWidth,
          );

      return height > tallest ? height : tallest;
    }).ceilToDouble();
  }

  double _measureText({
    required BuildContext context,
    required String text,
    required TextStyle style,
    required double maxWidth,
  }) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);

    final TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: defaultTextStyle.style.merge(style)),
      textAlign: TextAlign.center,
      textDirection: Directionality.of(context),
      textScaler: TextScaler.noScaling,
      textWidthBasis: defaultTextStyle.textWidthBasis,
      textHeightBehavior:
          defaultTextStyle.textHeightBehavior ??
          DefaultTextHeightBehavior.maybeOf(context),
    )..layout(maxWidth: maxWidth);

    return painter.size.height;
  }

  @override
  void initState() {
    super.initState();

    _logSlideSeen(currentSliderImage);
  }

  void _finishOnBoarding(final String eventName) {
    GoogleAnalyticsService.logEvent(eventName);
    Navigator.of(context).pushNamedAndRemoveUntil(
      loginRoute,
      (final route) => false,
      arguments: {"source": "introSliderScreen"},
    );
  }

  double _horizontalPadding(BuildContext context) =>
      ResponsiveHelper.isTabletDevice(context) ? 36.rw(context) : 16;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness:
              context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
              ? Brightness.light
              : Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
        child: Builder(
          builder: (final context) => Stack(
            fit: StackFit.expand,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: context.screenHeight * 0.65,
                  width: context.screenWidth,
                  child: AnimatedSwitcher(
                    duration: sliderAnimationDurationSettings
                        .changeSliderAnimationDuration,
                    child: CustomContainer(
                      key: ValueKey<int>(currentSliderImage),
                      image: DecorationImage(
                        image: ExactAssetImage(
                          introScreenList[currentSliderImage].imagePath,
                        ),
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ),
              ),
              CustomContainer(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0, 0.4, 0.8, 1],
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    context.colors.backgroundPrimary,
                    context.colors.backgroundPrimary,
                  ],
                ),
              ),

              CarouselSlider(
                carouselController: _carouselController,
                options: CarouselOptions(
                  height: context.screenHeight,
                  viewportFraction: 1,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval:
                      sliderAnimationDurationSettings.sliderAnimationDuration,
                  autoPlayAnimationDuration: sliderAnimationDurationSettings
                      .changeSliderAnimationDuration,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: false,
                  pauseAutoPlayOnTouch: false,
                  enlargeFactor: 1,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (index, reason) {
                    setState(() => currentSliderImage = index);
                    _logSlideSeen(index);
                  },
                ),
                items: List.generate(
                  introScreenList.length,
                  (index) => _OnBoardingBottomArea(
                    horizontalPadding: _horizontalPadding(context),
                    indicators: const CustomSizedBox(height: 4),
                    textSlotHeight: _textSlotHeight(context),
                    text: _OnBoardingText(introScreen: introScreenList[index]),
                    actions: const CustomSizedBox(height: 48),
                    slotGap: 24,
                  ),
                ),
              ),
              _OnBoardingBottomArea(
                horizontalPadding: _horizontalPadding(context),
                indicators: _OnBoardingIndicators(
                  currentIndex: currentSliderImage,
                ),
                textSlotHeight: _textSlotHeight(context),
                text: const CustomSizedBox(),
                actions: _OnBoardingActions(
                  isLastSlide: _isLastSlide,
                  onSkip: () => _finishOnBoarding('onboarding_skip_tap'),
                  onNext: () {
                    GoogleAnalyticsService.logEvent('onboarding_next_tap');
                    _carouselController.nextPage(
                      duration: sliderAnimationDurationSettings
                          .changeSliderAnimationDuration,
                      curve: Curves.easeInOut,
                    );
                  },
                  onGetStarted: () =>
                      _finishOnBoarding('onboarding_get_started_tap'),
                ),
                slotGap: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const double _titleToDescriptionGap = 8;

CustomText _onBoardingTitle(BuildContext context, IntroScreen introScreen) =>
    CustomText(
      introScreen.introScreenTitle.translate(context: context),
      color: context.colors.textPrimary,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.normal,
      fontSize: ResponsiveHelper.isTabletDevice(context) ? 30 : 24,
      textAlign: TextAlign.center,
    );

CustomText _onBoardingDescription(
  BuildContext context,
  IntroScreen introScreen,
) => CustomText(
  introScreen.introScreenSubTitle.translate(context: context),
  color: context.colors.textSecondary,
  fontWeight: FontWeight.w400,
  fontStyle: FontStyle.normal,
  fontSize: ResponsiveHelper.isTabletDevice(context) ? 16 : 14,
  textAlign: TextAlign.center,
);

void _logSlideSeen(int index) {
  GoogleAnalyticsService.logEvent(
    'onboarding_slide_viewed',
    parameters: {'step_index': index},
  );
}

class _OnBoardingBottomArea extends StatelessWidget {
  const _OnBoardingBottomArea({
    required this.horizontalPadding,
    required this.indicators,
    required this.textSlotHeight,
    required this.text,
    required this.actions,
    required this.slotGap,
  });

  final double horizontalPadding;
  final Widget indicators;
  final double textSlotHeight;
  final Widget text;
  final Widget actions;
  final double slotGap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: slotGap,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              indicators,
              CustomSizedBox(height: slotGap),
              CustomSizedBox(height: textSlotHeight, child: text),
              CustomSizedBox(height: slotGap),
              actions,
            ],
          ),
        ),
      ),
    );
  }
}

class _OnBoardingText extends StatelessWidget {
  const _OnBoardingText({required this.introScreen});

  final IntroScreen introScreen;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _onBoardingTitle(context, introScreen),
        const CustomSizedBox(height: _titleToDescriptionGap),
        _onBoardingDescription(context, introScreen),
      ],
    );
  }
}

class _OnBoardingIndicators extends StatelessWidget {
  const _OnBoardingIndicators({required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        introScreenList.length,
        (dotIndex) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: AnimatedContainer(
            duration:
                sliderAnimationDurationSettings.changeSliderAnimationDuration,
            width: ResponsiveHelper.isTabletDevice(context) ? 60 : 16,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf50),
              color: currentIndex == dotIndex
                  ? context.colors.backgroundBrand
                  : context.colors.backgroundTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

class _OnBoardingActions extends StatelessWidget {
  const _OnBoardingActions({
    required this.isLastSlide,
    required this.onSkip,
    required this.onNext,
    required this.onGetStarted,
  });

  final bool isLastSlide;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    if (isLastSlide) {
      return CustomRoundedButton(
        buttonTitle: "getStarted".translate(context: context),
        showBorder: false,
        widthPercentage: 1,
        backgroundColor: context.colors.backgroundBrand,
        onTap: onGetStarted,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomInkWellContainer(
          onTap: onSkip,
          child: CustomText(
            "skip".translate(context: context),
            color: context.colors.textBrand,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        CustomInkWellContainer(
          onTap: onNext,
          borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf50),
          child: CustomContainer(
            width: 48,
            height: 48,
            avoideResponsive: true,
            shape: BoxShape.circle,
            color: context.colors.backgroundBrand,
            alignment: Alignment.center,
            child: CustomSvgPicture(
              svgImage:
                  Directionality.of(
                    context,
                  ).toString().contains(TextDirection.RTL.value.toLowerCase())
                  ? AppAssets.backArrow
                  : AppAssets.backArrowLtr,
              color: context.colors.iconInverse,
            ),
          ),
        ),
      ],
    );
  }
}
