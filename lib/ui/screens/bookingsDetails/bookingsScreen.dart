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
  late TabController _tabController;
  late TabController _bottomTabController;

  bool get isCustomBooking => _bottomTabController.index == 1;

  void fetchBookingDetails() {
    Future.delayed(Duration.zero).then((final value) {
      String status = '';
      switch (_tabController.index) {
        case 0:
          status = '';
          break;
        case 1:
          status = 'awaiting';
          break;
        case 2:
          status = 'confirmed';
          break;
        case 3:
          status = 'started';
          break;
        case 4:
          status = 'cancelled';
          break;
        case 5:
          status = 'rescheduled';
          break;
        case 6:
          status = 'completed';
        case 7:
          status = 'booking_ended';
          break;
      }

      final AuthenticationState authStatus =
          context.read<AuthenticationCubit>().state;
      if (authStatus is AuthenticatedState) {
        Future.delayed(Duration.zero).then((final value) {
          context.read<BookingCubit>().fetchBookingDetails(
                status: status,
                customRequestOrders: isCustomBooking ? "1" : '',
              );
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _bottomTabController = TabController(length: 2, vsync: this);
    _tabController = TabController(length: 8, vsync: this);

    _bottomTabController.addListener(() {
      if (!_bottomTabController.indexIsChanging) {
        fetchBookingDetails();
      }
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        fetchBookingDetails();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchBookingDetails();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bottomTabController.dispose();
    super.dispose();
  }

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
            centerTitle: true,
            isLeadingIconEnable: false,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            elevation: 0.5,
          ),
          body: BlocBuilder<SystemSettingCubit, SystemSettingState>(
            builder: (context, systemState) {
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

              return BlocBuilder<BookingCubit, BookingState>(
                  builder: (final context, final state) =>
                      HiveRepository.getUserToken == ''
                          ? ErrorContainer(
                              errorMessage: 'youAreNotLoggedIn'
                                  .translate(context: context),
                              subErrorMessage: 'pleaseLoginToSeeYourBookings'
                                  .translate(context: context),
                              showRetryButton: true,
                              buttonName: 'login'.translate(context: context),
                              onTapRetry: () {
                                //passing source as dialog instead of booking
                                //because there is no condition added for booking so using dialog,

                                Navigator.pushNamed(context, loginRoute,
                                    arguments: {'source': 'dialog'});
                              },
                            )
                          : Stack(
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    CustomContainer(
                                      color: context.colorScheme.secondaryColor,
                                      height: 58,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        child: _buildTabBar(),
                                      ),
                                    ),
                                    Expanded(
                                      child: TabBarView(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        controller: _tabController,
                                        children: [
                                          BookingsList(
                                            selectedStatus: '',
                                            scrollController:
                                                widget.scrollController,
                                          ),
                                          BookingsList(
                                            selectedStatus: "awaiting",
                                            scrollController:
                                                widget.scrollController,
                                          ),
                                          BookingsList(
                                            selectedStatus: 'confirmed',
                                            scrollController:
                                                widget.scrollController,
                                          ),
                                          BookingsList(
                                            selectedStatus: 'started',
                                            scrollController:
                                                widget.scrollController,
                                          ),
                                          BookingsList(
                                            selectedStatus: 'cancelled',
                                            scrollController:
                                                widget.scrollController,
                                          ),
                                          BookingsList(
                                            selectedStatus: 'rescheduled',
                                            scrollController:
                                                widget.scrollController,
                                          ),
                                          BookingsList(
                                            selectedStatus: 'completed',
                                            scrollController:
                                                widget.scrollController,
                                          ),
                                          BookingsList(
                                            selectedStatus: 'booking_ended',
                                            scrollController:
                                                widget.scrollController,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                        height: kBottomNavigationBarHeight
                                            .rh(context)),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: CustomContainer(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 8),
                                    margin: EdgeInsetsDirectional.only(
                                      bottom: kBottomNavigationBarHeight
                                              .rh(context) +
                                          10.rh(context),
                                    ),
                                    color: context.colorScheme.secondaryColor,
                                    height: kBottomNavigationBarHeight - 5,
                                    width: context.screenWidth * 0.9,
                                    borderRadius: UiUtils.borderRadiusOf50,
                                    border: Border.all(
                                      color: context.colorScheme.lightGreyColor
                                          .withValues(alpha: 0.5),
                                      width: 0.5.rh(context),
                                    ),
                                    child: TabBar(
                                      controller: _bottomTabController,
                                      indicator: BoxDecoration(
                                        color: context.colorScheme.accentColor,
                                        borderRadius: BorderRadius.circular(
                                            UiUtils.borderRadiusOf50),
                                      ),
                                      tabAlignment: TabAlignment.fill,
                                      indicatorSize: TabBarIndicatorSize.tab,
                                      labelColor: AppColors.whiteColors,
                                      unselectedLabelColor:
                                          context.colorScheme.lightGreyColor,
                                      isScrollable: false,
                                      dividerColor: Colors.transparent,
                                      labelPadding: EdgeInsets.zero,
                                      labelStyle: TextStyle(
                                        fontSize: 14.rf(context),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      tabs: [
                                        Tab(
                                          text: 'defaultBooking'
                                              .translate(context: context),
                                        ),
                                        Tab(
                                          text: 'customBooking'
                                              .translate(context: context),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() => TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: context.colorScheme.accentColor,
          borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        tabAlignment: TabAlignment.start,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.whiteColors,
        unselectedLabelColor: context.colorScheme.lightGreyColor,
        isScrollable: true,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            text: 'all'.translate(context: context),
          ),
          Tab(
            text: 'awaiting'.translate(context: context),
          ),
          Tab(
            text: 'confirmed'.translate(context: context),
          ),
          Tab(
            text: 'started'.translate(context: context),
          ),
          Tab(
            text: 'canceled'.translate(context: context),
          ),
          Tab(
            text: 'rescheduled'.translate(context: context),
          ),
          Tab(
            text: 'completed'.translate(context: context),
          ),
          Tab(text: 'booking_ended'.translate(context: context)),
        ],
      );

  @override
  bool get wantKeepAlive => true;
}
