import 'package:e_demand/app/generalImports.dart';
export 'appStoreLinks.dart';

const String appName = "Khidma Plus";

// Live eDemand backend; a build-time define can select another environment.
const String domain = String.fromEnvironment(
  'KHIDMA_BACKEND_ORIGIN',
  defaultValue: 'https://admin.khidmaplus.com',
);

// deepLinkDomainURL should look like:- your_web_domain or your_panel_domain
const String deepLinkDomain = String.fromEnvironment(
  'KHIDMA_LINK_ORIGIN',
  defaultValue: 'https://admin.khidmaplus.com',
);

const String baseUrl = "$domain/api/v1/";

const String microsoftClarityProjectId = '';

const bool enableAds = bool.fromEnvironment('KHIDMA_ENABLE_ADS');

const bool showCompanyLogoOnSplash = false;

//if you do not want user to select another country rather than default country,
//then make below variable true
bool allowOnlySingleCountry = false;

const int resendOTPCountDownTime = 30; //in seconds

//OTP hint CustomText
const String otpHintText = "123456"; /* MUST BE 6 CHARACTER REQUIRED */

Map<String, dynamic> dateAndTimeSetting = {
  "dateFormat": "dd/MM/yyyy",
  "use24HourFormat": false,
};

//slider on home screen
typedef SliderAnimationSettings = ({
  Duration sliderAnimationDuration,
  Duration changeSliderAnimationDuration,
});

const SliderAnimationSettings sliderAnimationDurationSettings = (
  sliderAnimationDuration: Duration(milliseconds: 3000),
  changeSliderAnimationDuration: Duration(milliseconds: 300),
);

/* INTRO SLIDER LIST*/
List<IntroScreen> introScreenList = [
  IntroScreen(
    introScreenTitle: "Find Trusted Home Services",
    introScreenSubTitle:
        "Discover reliable professionals for cleaning, repairs, painting, and more near you.",
    imagePath: AppAssets.introSliderImageFirst,
    animationDuration: 3 /* DURATION IS IN SECONDS*/,
  ),
  IntroScreen(
    introScreenTitle: "Book Services Easily",
    introScreenSubTitle:
        "Schedule services in minutes and manage all your bookings in one place.",
    imagePath: AppAssets.introSliderImageSecond,
    animationDuration: 3 /* DURATION IS IN SECONDS*/,
  ),
  IntroScreen(
    introScreenTitle: "Custom Requests & Chat",
    introScreenSubTitle:
        "Create custom service requests and connect with providers instantly.",
    imagePath: AppAssets.introSliderImageThird,
    animationDuration: 3 /* DURATION IS IN SECONDS*/,
  ),
  // IntroScreen(
  //   introScreenTitle: "onboarding_heading_four",
  //   introScreenSubTitle: "onboarding_body_four",
  //   imagePath: AppAssets.introSliderImageFourth,
  //   animationDuration: 3 /* DURATION IS IN SECONDS*/,
  // ),
];
