import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/ui/widgets/animation/slide_animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'widgets/providerDetails/providerDetailsShimmer.dart';
import 'widgets/providerDetails/providerGalleryTab.dart';
import 'widgets/providerDetails/providerProfileCard.dart';

enum ProviderDetailsParamType { slug, id }

class ProviderDetailsScreen extends StatefulWidget {
  const ProviderDetailsScreen({
    required this.providerIDOrSlug,
    final Key? key,
    required this.type,
  }) : super(key: key);
  final String providerIDOrSlug;
  final ProviderDetailsParamType type;

  @override
  State<ProviderDetailsScreen> createState() => _ProviderDetailsScreenState();

  static Route route(final RouteSettings routeSettings) {
    final Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (final context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ProviderDetailsAndServiceCubit(
              ServiceRepository(),
              ProviderRepository(),
            ),
          ),
          BlocProvider(
            create: (context) => SearchProviderServicesCubit(
              serviceRepository: ServiceRepository(),
            ),
          ),
        ],
        child: ProviderDetailsScreen(
          providerIDOrSlug: arguments["providerId"],
          type: arguments['type'] ?? ProviderDetailsParamType.id,
        ),
      ),
    );
  }
}

class _ProviderDetailsScreenState extends State<ProviderDetailsScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController = TabController(length: 4, vsync: this);

  List<String> tabLabels = ['services', 'about', 'gallery', 'review'];

  int selectedIndex = 0;

  String? _selectedCategoryId;
  String? _selectedCategoryName;
  ServiceFilterModel? _serviceFilter;

  ScrollController _serviceListScrollController = ScrollController();

  bool _showBackToTop = false;

  double? calculatedWidth;

  final GlobalKey _providerMenuButtonKey = GlobalKey();
  final GlobalKey _profileCardKey = GlobalKey();
  double? _measuredCardHeight;

  void _measureProfileCardHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final double? renderedHeight =
          _profileCardKey.currentContext?.size?.height;
      if (renderedHeight != null &&
          renderedHeight != _measuredCardHeight &&
          renderedHeight > 0) {
        setState(() => _measuredCardHeight = renderedHeight);
      }
    });
  }

  late final bool isTablet = ResponsiveHelper.isTablet(context);

  @override
  void initState() {
    super.initState();

    fetchProviderDetailsAndServices();

    _tabController.addListener(() {
      if (_tabController.indexIsChanging ||
          _tabController.index != selectedIndex) {
        setState(() {
          selectedIndex = _tabController.index;
        });
      }
    });

    _serviceListScrollController.addListener(_handleBackToTopVisibility);
  }

  void _handleBackToTopVisibility() {
    final bool shouldShow =
        _serviceListScrollController.hasClients &&
        _serviceListScrollController.offset > 300;
    if (shouldShow != _showBackToTop) {
      setState(() => _showBackToTop = shouldShow);
    }
  }

  void _scrollBackToTop() {
    _serviceListScrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  void serviceListScrollController() {
    if (mounted &&
        !context.read<ProviderDetailsAndServiceCubit>().hasMoreServices()) {
      return;
    }
    // nextPageTrigger will have a value equivalent to 70% of the list size.
    final nextPageTrigger =
        0.7 * _serviceListScrollController.position.maxScrollExtent;

    // _scrollController fetches the next paginated data when the current position of the user on the screen has surpassed
    if (_serviceListScrollController.position.pixels > nextPageTrigger) {
      if (mounted) {
        context.read<ProviderDetailsAndServiceCubit>().fetchMoreServices(
          providerId: widget.providerIDOrSlug,
          type: widget.type,
        );
      }
    }
  }

  void fetchProviderDetailsAndServices() {
    context
        .read<ProviderDetailsAndServiceCubit>()
        .fetchProviderDetailsAndServices(
          providerId: widget.providerIDOrSlug,
          type: widget.type,
        );
    context.read<ReviewCubit>().fetchReview(
      providerId: widget.providerIDOrSlug,
      type: widget.type,
    );
    context.read<GetAllPromocodesCubit>().getAllPromocodes(
      providerIdOrSlug: widget.providerIDOrSlug,
      type: widget.type,
    );
  }

  Widget _profileCard(
    ProviderDetailsAndServiceFetchSuccess state,
    List<Promocode> promocodeList,
  ) {
    _measureProfileCardHeight();
    return ProviderProfileCard(
      state: state,
      promocodeList: promocodeList,
      cardKey: _profileCardKey,
      cardWidth: calculatedWidth,
    );
  }

  Widget _floatingCircleButton({
    required String icon,
    required VoidCallback onTap,
    Key? key,
  }) {
    return CustomInkWellContainer(
      key: key,
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.colors.backgroundPrimary,
          shape: BoxShape.circle,
        ),
        child: CustomSvgPicture(
          svgImage: icon,
          color: context.colors.textPrimary,
          height: 24,
          width: 24,
        ),
      ),
    );
  }

  Future<void> _showCategoriesBottomSheet() async {
    final ProviderDetailsAndServiceState cubitState = context
        .read<ProviderDetailsAndServiceCubit>()
        .state;
    if (cubitState is! ProviderDetailsAndServiceFetchSuccess) {
      return;
    }

    final Object? result = await UiUtils.showBottomSheet(
      context: context,
      enableDrag: true,
      isScrollControlled: true,
      useSafeArea: true,
      child: CategoriesBottomSheet(
        providerId: cubitState.providerDetails.providerId ?? '',
      ),
    );

    if (result is AllCategoryModel && mounted) {
      setState(() {
        _selectedCategoryId = result.id;
        _selectedCategoryName = result.translated_name;
      });
      context.read<ProviderDetailsAndServiceCubit>().fetchFilteredServices(
        providerId: widget.providerIDOrSlug,
        type: widget.type,
        filter: _serviceFilter,
        categoryId: result.id,
      );
    }
  }

  void _clearCategoryFilter() {
    setState(() {
      _selectedCategoryId = null;
      _selectedCategoryName = null;
    });
    context.read<ProviderDetailsAndServiceCubit>().fetchFilteredServices(
      providerId: widget.providerIDOrSlug,
      type: widget.type,
      filter: _serviceFilter,
      categoryId: '',
    );
  }

  Future<void> _showFilterBottomSheet() async {
    final ProviderDetailsAndServiceState cubitState = context
        .read<ProviderDetailsAndServiceCubit>()
        .state;
    final double maxPrice = cubitState is ProviderDetailsAndServiceFetchSuccess
        ? (cubitState.serviceMaxPrice ?? 2000.0)
        : 2000.0;
    final double minPrice = cubitState is ProviderDetailsAndServiceFetchSuccess
        ? (cubitState.serviceMinPrice ?? 0.0)
        : 0.0;

    final Object? result = await UiUtils.showBottomSheet(
      context: context,
      enableDrag: true,
      isScrollControlled: true,
      useSafeArea: true,
      child: FilterBottomSheet(
        maxPrice: maxPrice,
        minPrice: minPrice,
        currentFilter: _serviceFilter,
      ),
    );

    if (result is ServiceFilterModel && mounted) {
      final ServiceFilterModel? newFilter = result.isEmpty ? null : result;
      setState(() {
        _serviceFilter = newFilter;
      });
      context.read<ProviderDetailsAndServiceCubit>().fetchFilteredServices(
        providerId: widget.providerIDOrSlug,
        type: widget.type,
        filter: newFilter,
        categoryId: _selectedCategoryId,
      );
    }
  }

  void _clearServiceFilter() {
    setState(() {
      _serviceFilter = null;
    });
    context.read<ProviderDetailsAndServiceCubit>().fetchFilteredServices(
      providerId: widget.providerIDOrSlug,
      type: widget.type,
      filter: null,
      categoryId: _selectedCategoryId,
    );
  }

  Widget _categoriesButton(BuildContext context) {
    return CustomInkWellContainer(
      onTap: _showCategoriesBottomSheet,
      child: Container(
        padding: const EdgeInsetsDirectional.only(
          top: 12,
          bottom: 12,
          start: 12,
          end: 16,
        ),
        decoration: BoxDecoration(
          color: context.colors.backgroundInverse,
          borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
          boxShadow: [
            BoxShadow(
              color: context.colors.overlayFooterShadow,
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            CustomSvgPicture(
              avoideResponsive: true,
              svgImage: AppAssets.squaresFour,
              height: 24,
              width: 24,
              color: context.colors.iconInverse,
            ),
            CustomText(
              'categories'.translate(context: context),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: context.colors.textInverseDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _backToTopButton(BuildContext context) {
    return CustomInkWellContainer(
      onTap: _scrollBackToTop,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsetsDirectional.all(8),
        decoration: BoxDecoration(
          color: context.colors.backgroundInverse,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: context.colors.overlayFooterShadow,
              blurRadius: 8,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Icon(
              Icons.arrow_upward,
              color: context.colors.iconInverse,
              size: 16,
            ),
            // CustomSvgPicture(
            //   avoideResponsive: true,
            //   svgImage: AppAssets.upArrow,
            //   height: 16,
            //   width: 16,
            //   color: context.colors.iconInverse,
            // ),
            CustomText(
              'backToTop'.translate(context: context),
              fontSize: 12,
              color: context.colors.textInverseDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _providerMenuRow({required String icon, required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          CustomContainer(
            color: context.colors.backgroundSecondary,
            shape: BoxShape.circle,
            padding: const EdgeInsets.all(8),
            child: CustomSvgPicture(
              svgImage: icon,
              width: 24,
              height: 24,
              color: context.colors.textPrimary,
              avoideResponsive: true,
            ),
          ),
          CustomText(label, fontSize: 14, color: context.colors.textPrimary),
        ],
      ),
    );
  }

  void _showProviderMenu({required Providers providerDetails}) {
    final RenderBox? button =
        _providerMenuButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    if (button == null) {
      return;
    }
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(
          Offset(0, button.size.height + 8),
          ancestor: overlay,
        ),
        button.localToGlobal(
          button.size.bottomRight(const Offset(0, 8)),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<int>(
      context: context,
      position: position,
      color: context.colors.backgroundPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      items: [
        PopupMenuItem<int>(
          value: 0,
          padding: EdgeInsets.zero,
          child: _providerMenuRow(
            icon: AppAssets.drShare,
            label: "share".translate(context: context),
          ),
        ),
        PopupMenuItem<int>(
          enabled: false,
          height: 1,
          padding: EdgeInsets.zero,
          child: Container(height: 1, color: context.colors.borderMuted),
        ),
        PopupMenuItem<int>(
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                CustomContainer(
                  color: context.colors.backgroundSecondary,
                  shape: BoxShape.circle,
                  padding: const EdgeInsets.all(8),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: BookMarkIcon(providerData: providerDetails),
                  ),
                ),
                CustomText(
                  "bookmark".translate(context: context),
                  fontSize: 14,
                  color: context.colors.textPrimary,
                ),
              ],
            ),
          ),
        ),
      ],
    ).then((value) {
      if (value == 0) {
        _handleShareButtonClick(providerDetails: providerDetails);
      }
    });
  }

  Widget _quickFilterChip({
    String? icon,
    required String label,
    VoidCallback? onTap,
    bool isSelected = false,
  }) {
    return CustomInkWellContainer(
      borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
      onTap: onTap,
      child: CustomContainer(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: isSelected
            ? context.colors.backgroundBrandSubtle
            : context.colors.backgroundSecondary,
        borderRadius: UiUtils.borderRadiusOf12,
        border: isSelected
            ? Border.all(color: context.colors.backgroundBrand, width: 1)
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              CustomSvgPicture(
                avoideResponsive: true,
                svgImage: icon,
                height: 20,
                width: 20,
                color: isSelected
                    ? context.colors.textBrand
                    : context.colors.textPrimary,
              ),
              const CustomSizedBox(width: 8),
            ],
            CustomText(
              label,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              color: isSelected
                  ? context.colors.textBrand
                  : context.colors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickFilterRow() {
    final bool isFilterActive =
        _serviceFilter != null && !_serviceFilter!.isEmpty;
    final bool isTopRated = _serviceFilter?.sortBy == ServiceSortBy.topRated;
    final bool isDoorstep =
        _serviceFilter?.serviceMode == ServiceModeFilter.atDoorstep;
    final bool isPayLater = _serviceFilter?.payLaterAllowed ?? false;

    void _toggleServiceMode(ServiceModeFilter mode) {
      final bool isActive = _serviceFilter?.serviceMode == mode;
      final ServiceFilterModel? updatedFilter;
      if (isActive) {
        final cleared = _serviceFilter?.copyWith(clearServiceMode: true);
        updatedFilter = (cleared != null && !cleared.isEmpty) ? cleared : null;
      } else {
        updatedFilter = (_serviceFilter ?? const ServiceFilterModel()).copyWith(
          serviceMode: mode,
        );
      }
      setState(() {
        _serviceFilter = updatedFilter;
      });
      context.read<ProviderDetailsAndServiceCubit>().fetchFilteredServices(
        providerId: widget.providerIDOrSlug,
        type: widget.type,
        filter: updatedFilter,
        categoryId: _selectedCategoryId,
      );
    }

    void _togglePayLater() {
      final ServiceFilterModel? updatedFilter;
      if (isPayLater) {
        final toggled = (_serviceFilter ?? const ServiceFilterModel()).copyWith(
          payLaterAllowed: false,
        );
        updatedFilter = toggled.isEmpty ? null : toggled;
      } else {
        updatedFilter = (_serviceFilter ?? const ServiceFilterModel()).copyWith(
          payLaterAllowed: true,
        );
      }
      setState(() {
        _serviceFilter = updatedFilter;
      });
      context.read<ProviderDetailsAndServiceCubit>().fetchFilteredServices(
        providerId: widget.providerIDOrSlug,
        type: widget.type,
        filter: updatedFilter,
        categoryId: _selectedCategoryId,
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.backgroundPrimary,
        boxShadow: [
          BoxShadow(
            color: context.colors.overlayHeaderShadow,
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _quickFilterChip(
              icon: AppAssets.sortFilter,
              label: "filter".translate(context: context),
              isSelected: isFilterActive,
              onTap: _showFilterBottomSheet,
            ),
            const CustomSizedBox(width: 8),
            _quickFilterChip(
              label: "topRated".translate(context: context),
              isSelected: isTopRated,
              onTap: () {
                final ServiceFilterModel? updatedFilter;
                if (isTopRated) {
                  final cleared = _serviceFilter?.copyWith(clearSort: true);
                  updatedFilter = (cleared != null && !cleared.isEmpty)
                      ? cleared
                      : null;
                } else {
                  updatedFilter = (_serviceFilter ?? const ServiceFilterModel())
                      .copyWith(sortBy: ServiceSortBy.topRated);
                }
                setState(() {
                  _serviceFilter = updatedFilter;
                });
                context
                    .read<ProviderDetailsAndServiceCubit>()
                    .fetchFilteredServices(
                      providerId: widget.providerIDOrSlug,
                      type: widget.type,
                      filter: updatedFilter,
                      categoryId: _selectedCategoryId,
                    );
              },
            ),
            const CustomSizedBox(width: 8),
            _quickFilterChip(
              label: "doorstep".translate(context: context),
              isSelected: isDoorstep,
              onTap: () => _toggleServiceMode(ServiceModeFilter.atDoorstep),
            ),
            const CustomSizedBox(width: 8),
            _quickFilterChip(
              label: "payLater".translate(context: context),
              isSelected: isPayLater,
              onTap: _togglePayLater,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _serviceListScrollController.removeListener(_handleBackToTopVisibility);
    _serviceListScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    calculatedWidth = context.screenWidth - 16;

    super.build(context);
    return AnnotatedSafeArea(
      isAnnotated: true,
      applyBottomInset: false,
      child: Scaffold(
        bottomNavigationBar: const BannerAdWidget(applyBottomInset: true),
        body: UiUtils.restoreBottomInset(
          inset: MediaQuery.viewPaddingOf(context).bottom,
          child: BlocBuilder<SystemSettingCubit, SystemSettingState>(
            builder: (context, SystemSettingState systemSettingState) {
              if (systemSettingState is! SystemSettingFetchSuccess) {
                return ProviderDetailsShimmer(tabCount: tabLabels.length);
              }
              return BlocBuilder<CartCubit, CartState>(
                builder: (final BuildContext context, final CartState state) => BlocConsumer<ProviderDetailsAndServiceCubit, ProviderDetailsAndServiceState>(
                  listener: (final context, final state) {
                    if (state is ProviderDetailsAndServiceFetchSuccess &&
                        state.providerDetails.isBookmark == '1' &&
                        !context.read<BookmarkCubit>().isPartnerBookmark(
                          state.providerDetails.providerId ?? '',
                        )) {
                      context.read<BookmarkCubit>().addBookmark(
                        state.providerDetails,
                      );
                    }
                  },
                  builder: (final context, final state) {
                    if (state is ProviderDetailsAndServiceFetchFailure) {
                      return Center(
                        child: ErrorContainer(
                          showRetryButton: true,
                          onTapRetry: () {
                            fetchProviderDetailsAndServices();
                          },
                          errorMessage: state.errorMessage.translate(
                            context: context,
                          ),
                        ),
                      );
                    } else if (state is ProviderDetailsAndServiceFetchSuccess) {
                      final double appbarimageContainerHight =
                          context.screenHeight.rh(context) * 0.27;
                      final double providerContainerHight = 200.rh(context);
                      final GetAllPromocodesState promocodeState = context
                          .watch<GetAllPromocodesCubit>()
                          .state;
                      final List<Promocode> promocodeList =
                          promocodeState is GetAllPromocodesFetchSuccess
                          ? promocodeState.promocodeList
                          : <Promocode>[];
                      final double promocodeHight = promocodeList.length == 1
                          ? 100.rh(context)
                          : promocodeList.isNotEmpty
                          ? 120.rh(context)
                          : 10.rh(context);
                      final bool hasPromoCode = promocodeList.isNotEmpty;
                      final double scrollThreshold = hasPromoCode
                          ? 250.rs(context)
                          : 150.rs(context);
                      final double cardTotalHeight =
                          _measuredCardHeight ??
                          (hasPromoCode
                              ? providerContainerHight +
                                    24.rh(context) +
                                    promocodeHight
                              : providerContainerHight);
                      final double cardOverlapAmount = 45.rh(context);

                      final CartState cartState = context
                          .watch<CartCubit>()
                          .state;
                      final bool showsAddToCartBar =
                          cartState is CartFetchSuccess &&
                          cartState.cartData.providerId ==
                              widget.providerIDOrSlug;
                      final bool showsOtherProviderCartBar =
                          cartState is CartFetchSuccess &&
                          (cartState.cartData.cartDetails ?? []).isNotEmpty &&
                          cartState.cartData.providerId !=
                              widget.providerIDOrSlug;
                      const double cartBarHeight =
                          kBottomNavigationBarHeight * 1.3;

                      return Stack(
                        children: [
                          NestedScrollView(
                            physics: const ClampingScrollPhysics(),
                            controller: _serviceListScrollController,
                            headerSliverBuilder:
                                (
                                  final BuildContext context,
                                  final bool innerBoxIsScrolled,
                                ) => <Widget>[
                                  SliverLayoutBuilder(
                                    builder: (context, constraints) {
                                      final bool isCollapsed =
                                          constraints.scrollOffset >=
                                          scrollThreshold;
                                      return SliverAppBar(
                                        title: isCollapsed
                                            ? CustomText(
                                                state
                                                    .providerDetails
                                                    .translatedCompanyName!,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    context.colors.textPrimary,
                                              )
                                            : const SizedBox.shrink(),
                                        leading: Padding(
                                          padding:
                                              const EdgeInsetsDirectional.all(
                                                10,
                                              ),
                                          child: _floatingCircleButton(
                                            icon:
                                                Directionality.of(
                                                  context,
                                                ).toString().contains(
                                                  TextDirection.RTL.value
                                                      .toLowerCase(),
                                                )
                                                ? AppAssets.rightArrow
                                                : AppAssets.leftArrow,
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                        bottom: PreferredSize(
                                          preferredSize: Size(
                                            double.infinity,
                                            48.rh(context) +
                                                (selectedIndex == 0
                                                    ? 48.rh(context)
                                                    : 0),
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: context
                                                  .colors
                                                  .backgroundPrimary,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SlideAnimationScope(
                                                  builder:
                                                      (
                                                        context,
                                                        controller,
                                                      ) => SlideAnimation(
                                                        position: 0,
                                                        itemCount: 1,
                                                        slideDirection:
                                                            SlideDirection
                                                                .fromBottom,
                                                        animationController:
                                                            controller,
                                                        child: TopRoundedUnderlineTabBar(
                                                          border: Border(
                                                            bottom: BorderSide(
                                                              color: context
                                                                  .colors
                                                                  .borderMuted,
                                                              width: 1.5,
                                                            ),
                                                          ),
                                                          controller:
                                                              _tabController,
                                                          labelPadding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                              ),
                                                          tabs: tabLabels
                                                              .map(
                                                                (e) => Text(
                                                                  e.translate(
                                                                    context:
                                                                        context,
                                                                  ),
                                                                ),
                                                              )
                                                              .toList(),
                                                        ),
                                                      ),
                                                ),
                                                if (selectedIndex == 0)
                                                  _quickFilterRow(),
                                              ],
                                            ),
                                          ),
                                        ),
                                        systemOverlayStyle:
                                            const SystemUiOverlayStyle(
                                              statusBarColor:
                                                  Colors.transparent,
                                            ),
                                        pinned: true,
                                        elevation: 0,
                                        surfaceTintColor:
                                            context.colors.backgroundPrimary,
                                        expandedHeight:
                                            appbarimageContainerHight +
                                            (cardTotalHeight -
                                                cardOverlapAmount) +
                                            // Card -> tabs gap (+ room for the filter
                                            // row on the services tab). Tablet uses
                                            // unscaled values that land the tabs ~8
                                            // below the card, matching the 8 between
                                            // tabs and services.
                                            (isTablet
                                                ? (selectedIndex == 0 ? 82 : 24)
                                                : 28.rh(context) +
                                                      (selectedIndex == 0
                                                          ? 48.rh(context)
                                                          : 0)),
                                        backgroundColor: isCollapsed
                                            ? context.colors.backgroundPrimary
                                            : context
                                                  .colors
                                                  .backgroundSecondary,
                                        actions: [
                                          Padding(
                                            padding:
                                                const EdgeInsetsDirectional.only(
                                                  end: 16,
                                                  top: 10,
                                                  bottom: 10,
                                                ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                _floatingCircleButton(
                                                  icon: AppAssets.search,
                                                  onTap: () {
                                                    Navigator.pushNamed(
                                                      context,
                                                      providerServiceSearchScreen,
                                                      arguments: {
                                                        'providerId':
                                                            state
                                                                .providerDetails
                                                                .providerId ??
                                                            "0",
                                                        'type': widget.type,
                                                        'isProviderAvailableAtLocation':
                                                            state
                                                                .providerDetails
                                                                .isAvailableAtLocation ??
                                                            '1',
                                                        'searchCubit': context
                                                            .read<
                                                              SearchProviderServicesCubit
                                                            >(),
                                                      },
                                                    );
                                                  },
                                                ),
                                                const CustomSizedBox(width: 12),
                                                _floatingCircleButton(
                                                  key: _providerMenuButtonKey,
                                                  icon: AppAssets.menu,
                                                  onTap: () =>
                                                      _showProviderMenu(
                                                        providerDetails: state
                                                            .providerDetails,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                        flexibleSpace: FlexibleSpaceBar(
                                          collapseMode: CollapseMode.pin,
                                          stretchModes: const [
                                            StretchMode.zoomBackground,
                                          ],
                                          background: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CustomSizedBox(
                                                height:
                                                    appbarimageContainerHight +
                                                    (cardTotalHeight -
                                                        cardOverlapAmount),
                                                width: double.maxFinite,
                                                child: Stack(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  children: [
                                                    Container(
                                                      width:
                                                          context.screenWidth,
                                                      height:
                                                          appbarimageContainerHight,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            const BorderRadius.vertical(
                                                              bottom:
                                                                  Radius.circular(
                                                                    16,
                                                                  ),
                                                            ),
                                                        border: Border(
                                                          bottom: BorderSide(
                                                            width: 1.5,
                                                            color: context
                                                                .colors
                                                                .borderMuted,
                                                          ),
                                                        ),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            const BorderRadius.vertical(
                                                              bottom:
                                                                  Radius.circular(
                                                                    16,
                                                                  ),
                                                            ),
                                                        child: CustomCachedNetworkImage(
                                                          networkImageUrl: state
                                                              .providerDetails
                                                              .bannerImage!,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      child: _profileCard(
                                                        state,
                                                        promocodeList,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                            body: TabBarView(
                              controller: _tabController,
                              physics: const BouncingScrollPhysics(),
                              children: [
                                ProviderServicesContainer(
                                  isProviderAvailableAtLocation:
                                      state
                                          .providerDetails
                                          .isAvailableAtLocation ??
                                      '1',
                                  providerID:
                                      state.providerDetails.providerId ?? "0",
                                  selectedCategoryId: _selectedCategoryId,
                                  selectedCategoryName: _selectedCategoryName,
                                  onClearCategoryFilter: _clearCategoryFilter,
                                  filter: _serviceFilter,
                                  onClearFilter: _clearServiceFilter,
                                ),
                                SlideAnimationScope(
                                  builder: (context, controller) =>
                                      SlideAnimation(
                                        position: 0,
                                        itemCount: 1,
                                        slideDirection:
                                            SlideDirection.fromBottom,
                                        animationController: controller,
                                        child: AboutProviderContainer(
                                          providerDetails:
                                              state.providerDetails,
                                        ),
                                      ),
                                ),
                                SlideAnimationScope(
                                  builder: (context, controller) =>
                                      SlideAnimation(
                                        position: 0,
                                        itemCount: 1,
                                        slideDirection:
                                            SlideDirection.fromBottom,
                                        animationController: controller,
                                        child: ProviderGalleryTab(
                                          images:
                                              state
                                                  .providerDetails
                                                  .otherImagesOfTheService ??
                                              [],
                                        ),
                                      ),
                                ),
                                SlideAnimationScope(
                                  builder: (context, controller) =>
                                      SlideAnimation(
                                        position: 0,
                                        itemCount: 1,
                                        slideDirection:
                                            SlideDirection.fromBottom,
                                        animationController: controller,
                                        child: ReviewContent(
                                          providerDetails:
                                              state.providerDetails,
                                          bottomInset: MediaQuery.viewPaddingOf(
                                            context,
                                          ).bottom,
                                        ),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (showsAddToCartBar)
                            PositionedDirectional(
                              start: 0,
                              end: 0,
                              bottom: MediaQuery.viewPaddingOf(context).bottom,
                              child: const AddToCartComtainer(),
                            ),
                          if (showsOtherProviderCartBar)
                            PositionedDirectional(
                              start: 0,
                              end: 0,
                              bottom: 0,
                              child: CartSubDetailsContainer(
                                providerID: state.providerDetails.providerId,
                              ),
                            ),
                          if (selectedIndex == 0)
                            PositionedDirectional(
                              start: 0,
                              end: 0,
                              bottom:
                                  MediaQuery.viewPaddingOf(context).bottom +
                                  16.rh(context) +
                                  ((showsAddToCartBar ||
                                          showsOtherProviderCartBar)
                                      ? cartBarHeight
                                      : 0),
                              child: Center(child: _categoriesButton(context)),
                            ),
                          if (_showBackToTop && selectedIndex == 0)
                            PositionedDirectional(
                              start: 0,
                              end: 0,
                              top:
                                  MediaQuery.paddingOf(context).top +
                                  kToolbarHeight +
                                  48.rh(context) +
                                  48.rh(context) +
                                  8.rh(context),
                              child: Center(child: _backToTopButton(context)),
                            ),
                        ],
                      );
                    }
                    return ProviderDetailsShimmer(tabCount: tabLabels.length);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  //to prevent multi-taps
  bool isSharing = false;

  Future<void> _handleShareButtonClick({
    required Providers providerDetails,
  }) async {
    if (isSharing) {
      return;
    }
    isSharing = true;
    ClarityService.logAction(ClarityActions.serviceDetailShareTapped, {
      'provider_id': providerDetails.id ?? '',
      'provider_name':
          providerDetails.translatedCompanyName ??
          providerDetails.companyName ??
          '',
    });
    final String shareURL =
        '$deepLinkDomain/provider-details/${providerDetails.slug}?lang=${HiveRepository.getCurrentLanguage()!.languageCode}&lat=${HiveRepository.getLatitude}&lng=${HiveRepository.getLongitude}&share=true';
    await UiUtils.share(context: context, shareURL, subject: "Share Provider");
    isSharing = false;
  }
}
