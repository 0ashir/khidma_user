import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/ui/widgets/scheduledMaintainanceContainer.dart';
import 'package:flutter/material.dart';

import 'widgets/homeHeader.dart';
import 'widgets/homeScreenShimmer.dart';
import 'widgets/homeSections.dart';
import 'widgets/sliderImageWidget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.scrollController, final Key? key})
    : super(key: key);

  final ScrollController scrollController;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    AppQuickActions.initAppQuickActions();
    AppQuickActions.createAppQuickActions();

    checkLocationPermission();

    LocalAwesomeNotification.init(context);
  }

  Future<void> fetchHomeScreenData() async {
    await context.read<SystemSettingCubit>().getSystemSettings();
    if (!mounted) return;
    final futureAPIs = <Future>[
      context.read<HomeScreenCubit>().fetchHomeScreenData(),
      if (HiveRepository.getUserToken != '') ...[
        context.read<CartCubit>().getCartDetails(isReorderCart: false),
        context.read<BookmarkCubit>().fetchBookmark(type: 'list'),
      ],
    ];

    await Future.wait(futureAPIs);
  }

  Future<void> checkLocationPermission() async {
    final LocationPermission permission = await Geolocator.checkPermission();
    if (!mounted) return;

    if ((permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) &&
        ((HiveRepository.getLatitude == "0.0" ||
                HiveRepository.getLatitude == '') &&
            (HiveRepository.getLongitude == "0.0" ||
                HiveRepository.getLongitude == ''))) {
      Future.delayed(Duration.zero, () {
        if (!mounted) return;
        Navigator.pushNamed(context, allowLocationScreenRoute);
      });
    }
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      Position position;

      if (HiveRepository.getLatitude != null &&
          HiveRepository.getLongitude != null &&
          HiveRepository.getLatitude != '' &&
          HiveRepository.getLongitude != '') {
        final latitude = HiveRepository.getLatitude ?? "0.0";
        final longitude = HiveRepository.getLongitude ?? "0.0";

        await Geocoding().placemarkFromCoordinates(
          double.parse(latitude.toString()),
          double.parse(longitude.toString()),
        );
      } else {
        position = await Geolocator.getCurrentPosition();
        await Geocoding().placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
      }

      if (!mounted) return;
      setState(() {});
    }
  }

  void locationOnTap() {
    Navigator.pushNamed(context, setLocationRoute).then((final result) {
      final Map? value = result as Map?;
      if (!mounted) return;
      if (value != null) {
        if (value['navigateToMap'] == true) {
          Navigator.pushNamed(
            context,
            googleMapRoute,
            arguments: {
              "defaultLatitude": value['latitude'].toString(),
              "defaultLongitude": value['longitude'].toString(),
              'showAddressForm': false,
              'screenType': GoogleMapScreenType.selectLocationOnMap,
            },
          );
        }
      }
    });
  }

  Widget _buildErrorContainer(final String errorMessage) => ErrorContainer(
    errorMessage: errorMessage.translate(context: context),
    onTapRetry: fetchHomeScreenData,
  );

  Widget _buildHomeContent(
    final HomeScreenDataFetchSuccess homeScreenState,
    final SystemSettingFetchSuccess systemSettingState,
  ) {
    final homeScreenData = homeScreenState.homeScreenData;
    final sections = homeScreenData.sections ?? const <Sections>[];
    final sliders = homeScreenData.sliders ?? const <SliderImage>[];
    final appSetting = systemSettingState.systemSettingDetails.appSetting;

    if (sections.isEmpty && sliders.isEmpty) {
      return Center(
        child: NoDataFoundWidget(
          titleKey: 'weAreNotAvailableHere'.translate(context: context),
          subtitleKey: 'weAreNotAvailableHereSubTitle'.translate(
            context: context,
          ),
          buttonName: "changeLocation".translate(context: context),
          onTapRetry: locationOnTap,
          showRetryButton: true,
        ),
      );
    }

    final Widget content = Column(
      children: [
        const CustomSizedBox(height: 25),
        if (appSetting != null)
          ScheduledMaintenanceContainer(appSettings: appSetting),
        if (sliders.isNotEmpty) ...[
          SliderImageWidget(sliderImages: sliders),
          const CustomSizedBox(height: 24),
        ],
        HomeSections(sectionsList: sections),
      ],
    );

    return CustomRefreshIndicator(
      onRefreshCallback: fetchHomeScreenData,
      displacment: 12,
      child: BlocSelector<CartCubit, CartState, bool>(
        selector: (_) =>
            context.read<CartCubit>().getProviderIDFromCartData() != '0',
        builder: (final BuildContext context, final bool hasCart) {
          final double cartButtonHeight = hasCart
              ? kBottomNavigationBarHeight.rh(context) + 30.rf(context)
              : 0;
          return SingleChildScrollView(
            controller: widget.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsetsDirectional.only(
              bottom:
                  UiUtils.getScrollViewBottomPadding(context) +
                  24.rh(context) +
                  cartButtonHeight,
            ),
            child: content,
          );
        },
      ),
    );
  }

  Widget _buildHomeBody(final SystemSettingState systemSettingState) {
    if (systemSettingState is SystemSettingFetchFailure) {
      return _buildErrorContainer(systemSettingState.errorMessage.toString());
    }
    if (systemSettingState is! SystemSettingFetchSuccess) {
      return const HomeScreenShimmer();
    }

    return BlocBuilder<HomeScreenCubit, HomeScreenState>(
      builder: (context, homeScreenState) {
        if (homeScreenState is HomeScreenDataFetchSuccess) {
          return _buildHomeContent(homeScreenState, systemSettingState);
        }
        if (homeScreenState is HomeScreenDataFetchFailure) {
          return _buildErrorContainer(homeScreenState.errorMessage);
        }
        return const HomeScreenShimmer();
      },
    );
  }

  @override
  Widget build(final BuildContext context) =>
      AnnotatedRegion<SystemUiOverlayStyle>(
        value: UiUtils.getSystemUiOverlayStyle(context: context).copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: SafeArea(
          top: false,
          child: Scaffold(
            body: Stack(
              children: [
                Column(
                  children: [
                    HomeHeader(
                      scrollController: widget.scrollController,
                      onLocationTap: locationOnTap,
                    ),
                    Expanded(
                      child:
                          BlocBuilder<SystemSettingCubit, SystemSettingState>(
                            builder: (context, systemSettingState) =>
                                _buildHomeBody(systemSettingState),
                          ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsetsDirectional.only(
                    bottom: kBottomNavigationBarHeight + 18,
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: CartSubDetailsContainer(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
