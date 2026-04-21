//app file
import 'package:fixit_user/screens/app_pages_screens/chat_history_screen/chat_history_screen.dart';
import 'package:fixit_user/screens/app_pages_screens/custom_job_request/add_job_request/add_job_request.dart';
import 'package:fixit_user/screens/app_pages_screens/custom_job_request/job_request_details/job_request_details.dart';
import 'package:fixit_user/screens/app_pages_screens/custom_job_request/job_request_list/job_request_list.dart';
import 'package:fixit_user/screens/app_pages_screens/maintenance_mode.dart';
import 'package:fixit_user/screens/app_pages_screens/maintenance_screen/maintenance_screen.dart';
import 'package:fixit_user/screens/app_pages_screens/payment_web_view.dart';
import 'package:fixit_user/screens/app_pages_screens/referral_screen/referral_list_screen.dart';
import 'package:fixit_user/screens/app_pages_screens/referral_screen/referral_screen.dart';
import 'package:fixit_user/screens/app_pages_screens/support_ticket_screen/support_ticket_list_screen.dart';
import '../config.dart';
import '../screens/app_pages_screens/provider_chat_screen/provider_chat_screen.dart';

class AppRoute {
  Map<String, Widget Function(BuildContext)> route = {
    routeName.splash: (p0) => const SplashScreen(),
    routeName.onBoarding: (p0) => const OnBoardingScreen(),
    routeName.login: (p0) => const LoginScreen(),
    routeName.loginWithPhone: (p0) => const LoginWithPhoneScreen(),
    routeName.verifyOtp: (p0) => const VerifyOtpScreen(),
    routeName.forgetPassword: (p0) => const ForgotPasswordScreen(),
    routeName.resetPass: (p0) => const ResetPasswordScreen(),
    routeName.registerUser: (p0) => const RegisterScreen(),
    routeName.dashboard: (p0) => const Dashboard(),
    routeName.changePass: (p0) => const ChangePasswordScreen(),
    routeName.appSetting: (p0) => const AppSettingScreen(),
    routeName.changeLanguage: (p0) => const ChangeLanguageScreen(),
    routeName.profileDetail: (p0) => const ProfileDetailScreen(),
    routeName.walletBalance: (p0) => const WalletBalanceScreen(),
    routeName.favoriteList: (p0) => const FavouriteListScreen(),
    routeName.myLocation: (p0) => const MyLocationScreen(),
    routeName.review: (p0) => const ReviewScreen(),
    routeName.editReview: (p0) => const EditReviewScreen(),
    routeName.appDetails: (p0) => const AppDetailsScreen(),
    routeName.rateApp: (p0) => const RateAppScreen(),
    routeName.contactUs: (p0) => const ContactUsScreen(),
    routeName.helpSupport: (p0) => const HelpSupportScreen(),
    routeName.notifications: (p0) => const NotificationScreen(),
    routeName.location: (p0) => const LocationScreen(),
    routeName.currentLocation: (p0) => const CurrentLocationScreen(),
    routeName.addNewLocation: (p0) => const AddNewLocation(),
    routeName.search: (p0) => const SearchScreen(),
    routeName.latestBlogViewAll: (p0) => const LatestBlogViewAll(),
    routeName.latestBlogDetails: (p0) => const LatestBlogDetailsScreen(),
    routeName.noInternet: (p0) => const NoInternetScreen(),
    routeName.bookingList: (p0) => const BookingScreen(),
    routeName.categoriesListScreen: (p0) => const CategoriesListScreen(),
    routeName.categoriesDetailsScreen: (p0) => const CategoryDetailScreen(),
    routeName.servicesDetailsScreen: (p0) => const ServicesDetailsScreen(),
    routeName.servicesReviewScreen: (p0) => const ServiceReviewScreen(),
    routeName.providerDetailsScreen: (p0) => const ProviderDetailsScreen(),
    routeName.slotBookingScreen: (p0) => const SlotBookingScreen(),
    routeName.cartScreen: (p0) => const CartScreen(),
    routeName.couponListScreen: (p0) => const CouponListScreen(),
    routeName.paymentScreen: (p0) => const PaymentScreen(),
    routeName.serviceSelectedUserScreen: (p0) =>
        const ServiceSelectedUserScreen(),
    routeName.servicemanListScreen: (p0) => const ServicemanListScreen(),
    routeName.servicemanDetailScreen: (p0) => const ServicemanDetailScreen(),
    routeName.featuredServiceScreen: (p0) => const FeaturedServiceScreen(),
    routeName.expertServiceScreen: (p0) => const ExpertServiceScreen(),
    routeName.servicePackagesScreen: (p0) => const ServicePackagesScreen(),
    routeName.packageDetailsScreen: (p0) => const PackageDetailsScreen(),
    routeName.selectServiceScreen: (p0) => const SelectServiceScreen(),
    routeName.pendingBookingScreen: (p0) => const PendingBookingScreen(),
    routeName.acceptedBookingScreen: (p0) => const AcceptedBookingScreen(),
    routeName.chatScreen: (p0) => const ChatScreen(),
    routeName.ongoingBookingScreen: (p0) => const OngoingBookingScreen(),
    routeName.completedServiceScreen: (p0) => const CompletedServiceScreen(),
    routeName.cancelledServiceScreen: (p0) => const CancelledBookingScreen(),
    routeName.checkoutWebView: (p0) => const CheckoutWebView(),
    routeName.chatHistory: (p0) => const ChatHistoryScreen(),
    routeName.jobRequestList: (p0) => const JobRequestList(),
    routeName.jobRequestDetail: (p0) => const JobRequestDetails(),
    routeName.addJobRequestList: (p0) => const AddJobRequest(),
    routeName.maintenanceMode: (p0) => const MaintenanceMode(),
    // routeName.audioCall  : (p0) => const AudioCall(),
    // routeName.videoCall  : (p0) => const VideoCall(),
    routeName.providerChatScreen: (p0) => const ProviderChatScreen(),
    routeName.referralScreen: (p0) => const ReferralScreen(),
    routeName.referralList: (p0) => const ReferralListScreen(),
    routeName.maintenance: (p0) => const MaintenanceScreen(),
    routeName.supportTicketListScreen: (p0) => const SupportTicketListScreen(),
    routeName.chatWithStaffScreen: (p0) => const ChatWithStaffScreen(),
  };
}
