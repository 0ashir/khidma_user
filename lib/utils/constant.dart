import 'package:e_demand/app/generalImports.dart';

const String appName = "Khidma Plus";

// domainURL should look like:- your_web_domain or your_panel_domain
const String domain = 'khidmaplus.com'; //demo

//Add your baseURL
const String baseUrl = "https://admin.khidmaplus.com/api/v1/"; //demo
const bool isDemoMode = false;

const String defaultCountryCode = "AE";

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
const Map sliderAnimationDurationSettings = {
  "sliderAnimationDuration": 3000, // in milliseconds
  "changeSliderAnimationDuration": 300, //in milliseconds
};

/* INTRO SLIDER LIST*/
List<IntroScreen> introScreenList = [
  IntroScreen(
    introScreenTitle: "onboarding_heading_one",
    introScreenSubTitle: "onboarding_body_one",
    imagePath: AppAssets.introSliderImageFirst,
    animationDuration: 3 /* DURATION IS IN SECONDS*/,
  ),
  IntroScreen(
    introScreenTitle: "onboarding_heading_two",
    introScreenSubTitle: "onboarding_body_two",
    imagePath: AppAssets.introSliderImageSecond,
    animationDuration: 3 /* DURATION IS IN SECONDS*/,
  ),
  IntroScreen(
    introScreenTitle: "onboarding_heading_three",
    introScreenSubTitle: "onboarding_body_three",
    imagePath: AppAssets.introSliderImageThird,
    animationDuration: 3 /* DURATION IS IN SECONDS*/,
  ),
  IntroScreen(
    introScreenTitle: "onboarding_heading_four",
    introScreenSubTitle: "onboarding_body_four",
    imagePath: AppAssets.introSliderImageFourth,
    animationDuration: 3 /* DURATION IS IN SECONDS*/,
  ),
];

enum LogInType { google, apple, phone }
