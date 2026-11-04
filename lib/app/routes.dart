import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/ui/screens/blogs/blogScreen.dart';
import 'package:e_demand/ui/screens/blogs/blogDetailsScreen.dart';
import 'package:e_demand/ui/screens/chat/blockChatScreen.dart';
import 'package:e_demand/ui/screens/chat/chatMessagesScreen.dart';
import 'package:e_demand/ui/screens/chat/widgets/imagesFullScreen.dart';
import 'package:e_demand/ui/screens/contactUs.dart';
import 'package:e_demand/ui/screens/auth/accountScreen.dart';
import 'package:e_demand/ui/screens/supportHelp/supportHelpScreen.dart';
import 'package:e_demand/ui/screens/legalInformation/legalInformationScreen.dart';
import 'package:e_demand/ui/screens/sectionDetails/sectionDetailsScreen.dart';
import 'package:e_demand/ui/screens/auth/changePasswordScreen.dart';
import 'package:e_demand/ui/screens/auth/setPasswordScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const String navigationRoute = "/navigationBar";
const String allowLocationScreenRoute = "/allowLocationScreenRoute";
const String setLocationRoute = "/setLocationRoute";
const String splashRoute = "/";
const String onBoardingRoute = "/onboarding";
const String loginRoute = "/login";
const String registerRoute = "/register";
const String sectionDetailsRoute = "/sectionDetails";
const String countryCodePickerRoute = "/countryCodePicker";
const String otpVerificationRoute = "/login/OtpVerification";
const String changePasswordRoute = "/changePassword";
const String accountRoute = "/account";
const String supportHelpRoute = "/supportHelp";
const String legalInformationRoute = "/legalInformation";
const String languageRoute = "/language";
const String setPasswordRoute = "/setPassword";
const String allCategoriesRoute = "/allCategoriesScreen";
const String categoryServicesRoute = "/categoryServicesScreen";
const String categoryProvidersRoute = "/categoryProvidersScreen";

const String contactUsRoute = "/contactUs";
const String notificationRoute = "/notifications";
const String faqsRoute = "/faqs";
const String profileRoute = "/profile";
const String editProfileRoute = "/editProfile";
const String googleMapRoute = "/googleMapScreen";
const String scheduleScreenRoute = "/scheduleScreen";
const String providerRoute = "/providerRoute";
const String notAvailable = "/notAvailable";
const String bookmarkRoute = "/bookmarkRoute";
const String orderConfirmation = "/orderConfirmation";
const String promocodeScreen = "/promocodeScreen";
const String searchScreen = "/searchScreen";
const String searchCategoriesScreen = "/searchCategoriesScreen";
const String searchResultScreen = "/searchResultScreen";
const String searchResultMapScreen = "/searchResultMapScreen";
const String bookingDetails = "/bookingDetails";
const String paymentDetailsScreen = "/paymentDetailsScreen";
const String manageAddressScreen = "/manageAddressScreen";
const String maintenanceModeScreen = "/maintenanceModeScreen";
const String appUpdateScreen = "/appUpdateScreen";
const String imagePreview = "/imagePreview";
const String webviewPaymentScreen = "/paypalPaymentScreen";
const String reviewScreen = "/reviewScreen";
const String providerServiceDetails = "/providerServiceDetails";
const String providerServiceSearchScreen = "/providerServiceSearchScreen";
const String liveTrackingRoute = "/liveTracking";
const String rescheduleServiceRoute = "/rescheduleService";

//blogs
const String blogsRoute = "/blogsRoute";
const String blogDetailsScreen = "/blogDetailsScreen";

//chat
const String chatMessages = "/chatMessages";
const String chatUserProfile = "/chatUserProfile";
const String chatUsersList = "/chatUsersList";
const String blockUserScreen = "/blockUserScreen";

const String imagesFullScreenView = "/imagesFullScreenView";

//my request
const String myRequestDetailsScreen = "/myRequestDetailsScreen";
const String requestServiceFormScreen = "/requestServiceFormScreen";
const String requestServiceCategorySelectionScreen =
    "/requestServiceCategorySelectionScreen";
const String customJobRequestSuccessScreen = "/customJobRequestSuccessScreen";

//custom pages
const String customPageDetailsRoute = "/customPageDetailsRoute";

class Routes {
  static String currentRoute = '';
  static String previousRoute = '';
  static String secondPreviousRoute = '';
  static String globelProviderSlugForDeeplink = '';

  static Route<dynamic>? onGeneratedRoute(final RouteSettings routeSettings) {
    secondPreviousRoute = previousRoute;
    previousRoute = currentRoute;
    currentRoute = routeSettings.name ?? '';
    if (routeSettings.name!.contains('/provider-details/')) {
      final providerSlug = routeSettings.name!.split('/').last;
      if (previousRoute.isEmpty) {
        globelProviderSlugForDeeplink = providerSlug;
        return SplashScreen.route(routeSettings);
      } else {
        if (previousRoute == providerRoute) {
          UiUtils.rootNavigatorKey.currentState?.pop();
        }
        return ProviderDetailsScreen.route(
          RouteSettings(
            arguments: {
              "providerId": providerSlug,
              'type': ProviderDetailsParamType.slug,
            },
          ),
        );
      }
    }

    if (routeSettings.name!.contains('/link')) {
      return null;
    }

    switch (routeSettings.name) {
      case navigationRoute:
        return CustomNavigationBar.route(routeSettings);

      case splashRoute:
        return SplashScreen.route(routeSettings);

      case onBoardingRoute:
        return OnBoardingScreen.route(routeSettings);

      case loginRoute:
        return LogInScreen.route(routeSettings);

      case registerRoute:
        return RegisterScreen.route(routeSettings);

      case countryCodePickerRoute:
        return CountryCodePickerScreen.route(routeSettings);

      case otpVerificationRoute:
        return OtpVerificationScreen.route(routeSettings);

      case changePasswordRoute:
        return ChangePasswordScreen.route(routeSettings);

      case accountRoute:
        return AccountScreen.route(routeSettings);

      case supportHelpRoute:
        return SupportHelpScreen.route(routeSettings);

      case legalInformationRoute:
        return LegalInformationScreen.route(routeSettings);

      case languageRoute:
        return LanguageScreen.route(routeSettings);

      case setPasswordRoute:
        return SetPasswordScreen.route(routeSettings);

      case allCategoriesRoute:
        return AllCategoriesScreen.route(routeSettings);

      case sectionDetailsRoute:
        return SectionDetailsScreen.route(routeSettings);

      case categoryServicesRoute:
        return CategoryServicesScreen.route(routeSettings);

      case categoryProvidersRoute:
        return CategoryProvidersScreen.route(routeSettings);

      case notificationRoute:
        return NotificationScreen.route(routeSettings);

      case faqsRoute:
        return FaqsScreen.route(routeSettings);

      case allowLocationScreenRoute:
        return AllowLocationScreen.route(routeSettings);

      case setLocationRoute:
        return SetLocationScreen.route(routeSettings);

      case editProfileRoute:
        return EditProfileScreen.route(routeSettings);

      case googleMapRoute:
        return GoogleMapScreen.route(routeSettings);

      case scheduleScreenRoute:
        return CheckoutScreen.route(routeSettings);

      case providerRoute:
        return ProviderDetailsScreen.route(routeSettings);

      case bookmarkRoute:
        return BookmarkScreen.route(routeSettings);

      case orderConfirmation:
        return OrderConfirm.route(routeSettings);

      case reviewScreen:
        return ReviewScreen.route(routeSettings);

      case promocodeScreen:
        return PromoCodeScreen.route(routeSettings);

      case notAvailable:
        return CupertinoPageRoute(
          settings: routeSettings,
          builder: (final _) => const NotAvailable(),
        );

      case manageAddressScreen:
        return ManageAddress.route(routeSettings);

      case contactUsRoute:
        return ContactUsScreen.route(routeSettings);

      case webviewPaymentScreen:
        return WebviewPaymentScreen.route(routeSettings);

      case searchScreen:
        return SearchScreen.route(routeSettings);

      case searchCategoriesScreen:
        return SearchCategoriesScreen.route(routeSettings);

      case searchResultScreen:
        return SearchResultScreen.route(routeSettings);

      case searchResultMapScreen:
        return SearchResultMapScreen.route(routeSettings);

      case bookingDetails:
        return BookingDetails.route(routeSettings);

      case paymentDetailsScreen:
        return PaymentsScreen.route(routeSettings);

      case maintenanceModeScreen:
        return MaintenanceModeScreen.route(routeSettings);

      case appUpdateScreen:
        return AppUpdateScreen.route(routeSettings);

      case imagePreview:
        return ImagePreview.route(routeSettings);

      case chatMessages:
        return ChatMessagesScreen.route(routeSettings);

      case chatUsersList:
        return ChatUsersScreen.route(routeSettings);

      case imagesFullScreenView:
        return ImagesFullScreen.route(routeSettings);

      case providerServiceDetails:
        return ProviderServiceDetailsScreen.route(routeSettings);

      case providerServiceSearchScreen:
        return ProviderServiceSearchScreen.route(routeSettings);

      case liveTrackingRoute:
        return LiveTrackingScreen.route(routeSettings);

      case rescheduleServiceRoute:
        return RescheduleServiceScreen.route(routeSettings);

      //my request
      case myRequestDetailsScreen:
        return MyRequestDetailsScreen.route(routeSettings);
      case requestServiceFormScreen:
        return RequestServiceFormScreen.route(routeSettings);
      case requestServiceCategorySelectionScreen:
        return RequestServiceCategorySelectionScreen.route(routeSettings);
      case customJobRequestSuccessScreen:
        return CustomJobRequestSuccessScreen.route(routeSettings);
      case blockUserScreen:
        return BlockChatScreen.route(routeSettings);
      case blogsRoute:
        return BlogsScreen.route(routeSettings);
      case blogDetailsScreen:
        return BlogDetailsScreen.route(routeSettings);
      case customPageDetailsRoute:
        return CustomPageDetailsScreen.route(routeSettings);

      default:
        return CupertinoPageRoute(
          settings: routeSettings,
          builder: (final _) => const Scaffold(
            body: Center(child: CustomText("something went wrong")),
          ),
        );
    }
  }
}
