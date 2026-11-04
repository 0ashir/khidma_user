import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/cubits/authentication/logoutCubit.dart';
import 'package:e_demand/cubits/blogs/blogCategoryCubit.dart';
import 'package:e_demand/cubits/blogs/blogTagsCubit.dart';
import 'package:e_demand/cubits/blogs/blogsCubit.dart';
import 'package:e_demand/cubits/chat/reportReasonCubit.dart';
import 'package:e_demand/cubits/chat/submitReportCubit.dart';
import 'package:e_demand/data/repository/blogsRepository.dart';
import "package:flutter/material.dart";

List<BlocProvider> registerBlocks() {
  return [
    BlocProvider<AddTransactionCubit>(
      create: (_) =>
          AddTransactionCubit(bookingRepository: BookingRepository()),
    ),
    BlocProvider<ThemePaletteCubit>(
      create: (_) => ThemePaletteCubit(SettingRepository()),
    ),
    BlocProvider<MyRequestListCubit>(create: (_) => MyRequestListCubit()),
    BlocProvider<MyRequestCartCubit>(
      create: (_) =>
          MyRequestCartCubit(MyRequestRepository(), CartRepository()),
    ),
    BlocProvider<CancelCustomJobRequestCubit>(
      create: (_) => CancelCustomJobRequestCubit(),
    ),
    BlocProvider<MyRequestDetailsCubit>(create: (_) => MyRequestDetailsCubit()),
    BlocProvider<MyRequestCubit>(create: (_) => MyRequestCubit()),
    BlocProvider<CountryCodeCubit>(create: (_) => CountryCodeCubit()),
    BlocProvider<AuthenticationCubit>(create: (_) => AuthenticationCubit()),
    BlocProvider<SendVerificationCodeCubit>(
      create: (_) => SendVerificationCodeCubit(),
    ),
    BlocProvider<VerifyOtpCubit>(create: (_) => VerifyOtpCubit()),
    BlocProvider<CategoryCubit>(
      create: (_) => CategoryCubit(CategoryRepository()),
    ),
    BlocProvider<LogoutCubit>(
      create: (_) => LogoutCubit(AuthenticationRepository()),
    ),
    BlocProvider<AllCategoryCubit>(
      create: (_) => AllCategoryCubit(CategoryRepository()),
    ),

    BlocProvider<NotificationsCubit>(create: (_) => NotificationsCubit()),
    BlocProvider<AppThemeCubit>(
      create: (final _) => AppThemeCubit(SettingRepository()),
    ),
    BlocProvider<ResendOtpCubit>(create: (_) => ResendOtpCubit()),
    BlocProvider<ServiceReviewCubit>(
      create: (_) => ServiceReviewCubit(reviewRepository: ReviewRepository()),
    ),
    BlocProvider<ServiceDetailsCubit>(
      create: (_) =>
          ServiceDetailsCubit(serviceRepository: ServiceRepository()),
    ),
    BlocProvider<CountrySettingsCubit>(
      create: (final BuildContext context) =>
          CountrySettingsCubit(SettingRepository()),
    ),
    BlocProvider<SystemSettingCubit>(
      create: (final BuildContext context) => SystemSettingCubit(
        settingRepository: SettingRepository(),
        countrySettingsCubit: context.read<CountrySettingsCubit>(),
      ),
    ),
    BlocProvider<GeolocationCubit>(create: (_) => GeolocationCubit()),
    BlocProvider<LanguageListCubit>(
      create: (final BuildContext context) => LanguageListCubit(),
    ),
    BlocProvider<LanguageDataCubit>(
      create: (final BuildContext context) => LanguageDataCubit(),
    ),
    BlocProvider<ChangeBookingStatusCubit>(
      create: (final BuildContext context) =>
          ChangeBookingStatusCubit(bookingRepository: BookingRepository()),
    ),
    BlocProvider<DownloadInvoiceCubit>(
      create: (final BuildContext context) =>
          DownloadInvoiceCubit(BookingRepository()),
    ),
    BlocProvider<UserDetailsCubit>(create: (_) => UserDetailsCubit()),
    BlocProvider<AddAddressCubit>(create: (_) => AddAddressCubit()),
    BlocProvider<UpdateUserCubit>(create: (_) => UpdateUserCubit()),
    BlocProvider<DeleteAddressCubit>(create: (_) => DeleteAddressCubit()),
    BlocProvider<AddressesCubit>(
      create: (final BuildContext context) => AddressesCubit(),
    ),
    BlocProvider<GooglePlaceAutocompleteCubit>(
      create: (_) => GooglePlaceAutocompleteCubit(),
    ),

    BlocProvider<SubCategoryAndProviderCubit>(
      create: (_) => SubCategoryAndProviderCubit(
        subCategoryRepository: SubCategoryRepository(),
        providerRepository: ProviderRepository(),
      ),
    ),
    BlocProvider<ProviderCubit>(
      create: (_) => ProviderCubit(ProviderRepository()),
    ),
    BlocProvider<GetAddressCubit>(create: (_) => GetAddressCubit()),
    BlocProvider<ReviewCubit>(
      create: (final BuildContext context) => ReviewCubit(ReviewRepository()),
    ),
    BlocProvider<BookmarkCubit>(
      create: (_) => BookmarkCubit(BookmarkRepository()),
    ),
    BlocProvider<ServiceBookmarkCubit>(
      create: (_) => ServiceBookmarkCubit(BookmarkRepository()),
    ),
    BlocProvider<HomeScreenCubit>(
      create: (final BuildContext context) => HomeScreenCubit(
        HomeScreenRepository(),
        context.read<CountrySettingsCubit>(),
      ),
    ),
    BlocProvider<BookingCubit>(
      create: (_) => BookingCubit(BookingRepository()),
    ),
    BlocProvider<CartCubit>(create: (_) => CartCubit(CartRepository())),
    BlocProvider<CheckIsUserExistsCubit>(
      create: (_) => CheckIsUserExistsCubit(
        authenticationRepository: AuthenticationRepository(),
      ),
    ),
    BlocProvider<GetAllPromocodesCubit>(
      create: (_) => GetAllPromocodesCubit(cartRepository: CartRepository()),
    ),
    BlocProvider<GoogleLoginCubit>(create: (_) => GoogleLoginCubit()),
    BlocProvider<AppleLoginCubit>(create: (_) => AppleLoginCubit()),
    BlocProvider<GetReportReasonsCubit>(
      create: (context) => GetReportReasonsCubit(ChatRepository()),
    ),
    BlocProvider<SubmitReportCubit>(
      create: (context) => SubmitReportCubit(ChatRepository()),
    ),
    BlocProvider<BlogCategoryCubit>(
      create: (context) => BlogCategoryCubit(BlogsRepository()),
    ),
    BlocProvider<BlogsCubit>(
      create: (context) => BlogsCubit(BlogsRepository()),
    ),
    BlocProvider<BlogTagsCubit>(
      create: (context) => BlogTagsCubit(BlogsRepository()),
    ),

    BlocProvider<EnquiryChatUserCubit>(
      create: (context) => EnquiryChatUserCubit(ChatRepository()),
    ),
    BlocProvider<BookingChatUserCubit>(
      create: (context) => BookingChatUserCubit(ChatRepository()),
    ),
  ];
}
