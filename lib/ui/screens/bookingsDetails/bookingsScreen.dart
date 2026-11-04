// ignore_for_file: file_names

import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({required this.scrollController, final Key? key})
    : super(key: key);
  final ScrollController scrollController;

  @override
  State<BookingsScreen> createState() => BookingsScreenState();
}

class BookingsScreenState extends State<BookingsScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _bookingTypeTabController;
  String? _selectedStatus;

  bool get isCustomBooking => _bookingTypeTabController.index == 1;

  static const List<(String labelKey, String? status)> _quickFilters = [
    ('all', null),
    ('awaiting', 'awaiting'),
    ('confirmed', 'confirmed'),
    ('onTheWay', 'on_the_way'),
    ('arrived', 'arrived'),
    ('started', 'started'),
    ('cancelled', 'cancelled'),
    ('rescheduled', 'rescheduled'),
    ('completed', 'completed'),
    ('booking_ended', 'booking_ended'),
  ];

  void fetchBookingDetails() {
    final AuthenticationState authStatus = context
        .read<AuthenticationCubit>()
        .state;
    if (authStatus is! AuthenticatedState) return;

    Future.delayed(Duration.zero).then((final value) {
      if (!mounted) return;
      context.read<BookingCubit>().fetchAllBookings(
        status: _selectedStatus,
        customRequestOrder: isCustomBooking ? "1" : '0',
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _bookingTypeTabController = TabController(length: 2, vsync: this);

    _bookingTypeTabController.addListener(() {
      if (!_bookingTypeTabController.indexIsChanging) {
        setState(() {});
        fetchBookingDetails();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchBookingDetails();
    });
  }

  @override
  void dispose() {
    _bookingTypeTabController.dispose();
    super.dispose();
  }

  Widget _buildBookingTypeTabs() => TopRoundedUnderlineTabBar(
    controller: _bookingTypeTabController,
    border: Border(
      bottom: BorderSide(color: context.colors.borderMuted, width: 1.5),
    ),
    tabs: [
      Text('defaultBooking'.translate(context: context)),
      Text('customBooking'.translate(context: context)),
    ],
  );

  Widget _buildQuickFilterRow() => CategoryQuickFilterRow(
    chips: [
      for (final filter in _quickFilters)
        CategoryQuickFilterChip(
          label: filter.$1.translate(context: context),
          isSelected: _selectedStatus == filter.$2,
          onTap: () {
            setState(() => _selectedStatus = filter.$2);
            fetchBookingDetails();
          },
        ),
    ],
  );

  @override
  Widget build(final BuildContext context) {
    super.build(context);
    return SafeArea(
      bottom: Platform.isIOS,
      top: false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: UiUtils.getSystemUiOverlayStyle(context: context),
        child: Scaffold(
          appBar: UiUtils.getSimpleAppBar(
            context: context,
            title: "myBookings".translate(context: context),
            isLeadingIconEnable: false,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(117.rh(context)),
              child: Column(
                children: [_buildBookingTypeTabs(), _buildQuickFilterRow()],
              ),
            ),
          ),
          body: BlocBuilder<SystemSettingCubit, SystemSettingState>(
            builder: (context, systemState) {
              if (systemState is! SystemSettingFetchSuccess) {
                if (systemState is SystemSettingFetchFailure) {
                  return SingleChildScrollView(
                    controller: widget.scrollController,
                    child: ErrorContainer(
                      errorMessage: systemState.errorMessage
                          .toString()
                          .translate(context: context),
                      onTapRetry: () async {
                        await context
                            .read<SystemSettingCubit>()
                            .getSystemSettings();
                        fetchBookingDetails();
                      },
                    ),
                  );
                }
                return _getBookingScreenShimmerLoading();
              }

              return HiveRepository.getUserToken == ''
                  ? ErrorContainer(
                      errorMessage: 'youAreNotLoggedIn'.translate(
                        context: context,
                      ),
                      subErrorMessage: 'pleaseLoginToSeeYourBookings'.translate(
                        context: context,
                      ),
                      showRetryButton: true,
                      buttonName: 'login'.translate(context: context),
                      onTapRetry: () {
                        Navigator.pushNamed(
                          context,
                          loginRoute,
                          arguments: {'source': 'dialog'},
                        );
                      },
                    )
                  : BookingsList(
                      onRefresh: fetchBookingDetails,
                      isCustomBooking: isCustomBooking,
                    );
            },
          ),
        ),
      ),
    );
  }

  Widget _getBookingScreenShimmerLoading() {
    final bool isTablet = ResponsiveHelper.isTabletDevice(context);
    return Padding(
      padding: EdgeInsetsDirectional.only(
        bottom: UiUtils.getScrollViewBottomPadding(context),
      ),
      child: isTablet
          ? GridView.builder(
              controller: widget.scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(10),
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    height: 230.rh(context),
                  ),
              itemCount: UiUtils.numberOfShimmerContainer,
              itemBuilder: (context, index) {
                return const CustomShimmerLoadingContainer(
                  height: 260,
                  borderRadius: 10,
                );
              },
            )
          : ListView.builder(
              controller: widget.scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              itemCount: UiUtils.numberOfShimmerContainer,
              itemBuilder: (context, index) {
                return const CustomShimmerLoadingContainer(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  height: 240,
                  borderRadius: 10,
                );
              },
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
