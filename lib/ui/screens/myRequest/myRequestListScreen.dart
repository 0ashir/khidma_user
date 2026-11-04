import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class MyRequestListScreen extends StatefulWidget {
  const MyRequestListScreen({required this.scrollController, final Key? key})
    : super(key: key);
  final ScrollController scrollController;

  @override
  State<MyRequestListScreen> createState() => _MyRequestListScreenState();
}

class _MyRequestListScreenState extends State<MyRequestListScreen> {
  String? _selectedStatus;

  static const List<(String labelKey, String? status)> _statusTabs = [
    ('all', null),
    ('requested', 'pending'),
    ('expiry', 'expiry'),
    ('cancelled', 'cancelled'),
    ('booked', 'booked'),
  ];

  @override
  void initState() {
    Future.delayed(Duration.zero).then((final value) {
      fetchMyRequestList();
    });

    widget.scrollController.addListener(fetchMoreRequestDetails);
    super.initState();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(fetchMoreRequestDetails);
    super.dispose();
  }

  void fetchMoreRequestDetails() {
    if (mounted && !context.read<MyRequestListCubit>().hasMoreReq()) {
      return;
    }
    // nextPageTrigger will have a value equivalent to 70% of the list size.
    final nextPageTrigger =
        0.7 * widget.scrollController.position.maxScrollExtent;

    // _scrollController fetches the next paginated data when the current position of the user on the screen has surpassed
    if (widget.scrollController.position.pixels > nextPageTrigger) {
      if (mounted) {
        context.read<MyRequestListCubit>().fetchMoreReq();
      }
    }
  }

  void fetchMyRequestList() {
    context.read<MyRequestListCubit>().fetchRequests(status: _selectedStatus);
  }

  Widget _buildStatusFilterTabs() => CustomContainer(
    width: double.infinity,
    color: context.colors.surfacePrimary,
    padding: const EdgeInsets.only(top: 8, bottom: 16),
    boxShadow: [
      BoxShadow(
        blurRadius: 16,
        offset: const Offset(0, 8),
        color: context.colors.overlayHeaderShadow,
      ),
    ],
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (int i = 0; i < _statusTabs.length; i++) ...[
            if (i > 0) const CustomSizedBox(width: 14),
            _buildStatusTabChip(
              labelKey: _statusTabs[i].$1,
              status: _statusTabs[i].$2,
            ),
          ],
        ],
      ),
    ),
  );

  Widget _buildStatusTabChip({
    required final String labelKey,
    required final String? status,
  }) {
    final bool isSelected = _selectedStatus == status;
    return CustomInkWellContainer(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() => _selectedStatus = status);
        context.read<MyRequestListCubit>().fetchRequests(status: status);
      },
      child: CustomContainer(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: isSelected
            ? context.colors.backgroundBrandSubtle
            : context.colors.backgroundSecondary,
        border: isSelected
            ? Border.all(color: context.colors.borderBrand)
            : null,
        borderRadius: 12,
        child: CustomText(
          labelKey.translate(context: context),
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: isSelected
              ? context.colors.textBrand
              : context.colors.textPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(
    final BuildContext context,
  ) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: UiUtils.getSystemUiOverlayStyle(context: context),
    child: SafeArea(
      bottom: Platform.isIOS,
      top: false,
      child: Scaffold(
        appBar: UiUtils.getSimpleAppBar(
          context: context,
          title: 'myRequest'.translate(context: context),
          isLeadingIconEnable: false,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60.rh(context)),
            child: _buildStatusFilterTabs(),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<SystemSettingCubit, SystemSettingState>(
                builder: (context, systemState) {
                  // Show loading shimmer if system settings are not loaded yet
                  if (systemState is! SystemSettingFetchSuccess) {
                    if (systemState is SystemSettingFetchFailure) {
                      return ErrorContainer(
                        errorMessage: systemState.errorMessage
                            .toString()
                            .translate(context: context),
                        onTapRetry: () async {
                          await context
                              .read<SystemSettingCubit>()
                              .getSystemSettings();
                          fetchMyRequestList();
                        },
                        showRetryButton: true,
                      );
                    }
                    return _getLoadingShimmerEffect();
                  }

                  return CustomRefreshIndicator(
                    displacment: 12,
                    onRefreshCallback: () {
                      fetchMyRequestList();
                    },
                    child: BlocBuilder<MyRequestListCubit, MyRequestListState>(
                      builder: (context, state) {
                        if (HiveRepository.getUserToken == '') {
                          return ErrorContainer(
                            errorMessage: 'youAreNotLoggedIn'.translate(
                              context: context,
                            ),
                            subErrorMessage: 'pleaseLoginToSeeYourRequests'
                                .translate(context: context),
                            showRetryButton: true,
                            buttonName: 'login'.translate(context: context),
                            onTapRetry: () {
                              Navigator.pushNamed(
                                context,
                                loginRoute,
                                arguments: {'source': 'dialog'},
                              );
                            },
                          );
                        }
                        if (state is MyRequestListInProgress) {
                          return _getLoadingShimmerEffect();
                        }
                        if (state is MyRequestListFailure) {
                          return Stack(
                            children: [
                              ErrorContainer(
                                errorMessage: state.errorMessage.translate(
                                  context: context,
                                ),
                                onTapRetry: fetchMyRequestList,
                                showRetryButton: true,
                              ),
                              _buildRequestServiceFab(),
                            ],
                          );
                        }
                        if (state is MyRequestListSuccess) {
                          if (state.requestList.isEmpty) {
                            return Stack(
                              children: [
                                Center(
                                  child: NoDataFoundWidget(
                                    titleKey: 'noServiceRequested'.translate(
                                      context: context,
                                    ),
                                    subtitleKey: 'noServiceRequestedSubTitle'
                                        .translate(context: context),
                                    showRetryButton: true,
                                    onTapRetry: fetchMyRequestList,
                                  ),
                                ),
                                _buildRequestServiceFab(),
                              ],
                            );
                          }
                          return Stack(
                            children: [
                              _getMyRequestList(
                                myRequestList: state.requestList,
                                isLoadingMoreError: state.isLoadingMoreError,
                              ),
                              _buildRequestServiceFab(),
                            ],
                          );
                        }
                        return const CustomSizedBox();
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildRequestServiceFab() => Align(
    alignment: AlignmentDirectional.bottomEnd,
    child: Padding(
      padding: EdgeInsetsDirectional.only(
        end: 16,
        bottom:
            kBottomNavigationBarHeight.rh(context) +
            MediaQuery.paddingOf(context).bottom +
            36,
      ),
      child: CustomInkWellContainer(
        borderRadius: BorderRadius.circular(100),
        onTap: () {
          Navigator.pushNamed(context, requestServiceCategorySelectionScreen);
        },
        child: CustomContainer(
          padding: const EdgeInsets.all(8),
          color: context.colors.backgroundBrand,
          borderRadius: 100,
          boxShadow: [
            BoxShadow(
              blurRadius: 2,
              offset: const Offset(0, 4),
              color: context.colors.overlayHeaderShadow,
            ),
          ],
          child: CustomSvgPicture(
            svgImage: AppAssets.plus,
            height: 32,
            width: 32,
            color: context.colors.iconInverseLight,
            avoideResponsive: true,
          ),
        ),
      ),
    ),
  );

  Widget _getMyRequestList({
    required final List<MyRequestListModel> myRequestList,
    required final bool isLoadingMoreError,
  }) {
    final isTablet = ResponsiveHelper.isTabletDevice(context);

    if (isTablet) {
      // Rows size to the taller card (no fixed cell height, which overflowed
      // whenever a card's content outgrew it) and stretch both cards to match.
      return ListView.builder(
        controller: widget.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          15,
          15,
          15,
          kBottomNavigationBarHeight.rh(context) * 2,
        ),
        itemCount: (myRequestList.length / 2).ceil(),
        itemBuilder: (final BuildContext context, int rowIndex) {
          final int first = rowIndex * 2;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: MyRequestCardContainer(
                    myRequestDetails: myRequestList[first],
                    fillAvailableHeight: true,
                  ),
                ),
                const CustomSizedBox(width: 15),
                Expanded(
                  child: first + 1 < myRequestList.length
                      ? MyRequestCardContainer(
                          myRequestDetails: myRequestList[first + 1],
                          fillAvailableHeight: true,
                        )
                      : const CustomSizedBox(),
                ),
              ],
            ),
          );
        },
      );
    } else {
      return ListView.builder(
        controller: widget.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          15,
          15,
          15,
          kBottomNavigationBarHeight * 2,
        ),
        itemCount: myRequestList.length,
        itemBuilder: (final BuildContext context, int index) {
          if (index >= myRequestList.length) {
            return CustomContainer(
              margin: EdgeInsetsDirectional.only(
                bottom: kBottomNavigationBarHeight.rh(context) * 2.rh(context),
              ),
              child: CustomLoadingMoreContainer(
                isError: isLoadingMoreError,
                onErrorButtonPressed: () {
                  fetchMoreRequestDetails();
                },
              ),
            );
          }
          return MyRequestCardContainer(myRequestDetails: myRequestList[index]);
        },
      );
    }
  }

  Widget _getLoadingShimmerEffect() {
    return ResponsiveHelper.isTabletDevice(context)
        ? GridView.builder(
            controller: widget.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  height: 180,
                ),
            itemCount: 10,
            itemBuilder: (final BuildContext context, int index) {
              return CustomShimmerLoadingContainer(
                borderRadius: 10,
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: context.screenWidth * 0.9,
                height: context.screenHeight * 0.24,
              );
            },
          )
        : ListView.builder(
            controller: widget.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
            itemCount: 10,
            itemBuilder: (final BuildContext context, int index) {
              return CustomShimmerLoadingContainer(
                borderRadius: 10,
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: context.screenWidth * 0.9,
                height: context.screenHeight * 0.24,
              );
            },
          );
  }
}
