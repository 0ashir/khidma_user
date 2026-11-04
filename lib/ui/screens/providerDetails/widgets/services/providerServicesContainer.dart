import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/ui/widgets/animation/slide_animation.dart';
import 'package:flutter/material.dart';

class ProviderServicesContainer extends StatefulWidget {
  final String providerID;
  final String isProviderAvailableAtLocation;
  final String? selectedCategoryId;
  final String? selectedCategoryName;
  final VoidCallback? onClearCategoryFilter;
  final ServiceFilterModel? filter;
  final VoidCallback? onClearFilter;

  const ProviderServicesContainer({
    super.key,
    required this.providerID,
    required this.isProviderAvailableAtLocation,
    this.selectedCategoryId,
    this.selectedCategoryName,
    this.onClearCategoryFilter,
    this.filter,
    this.onClearFilter,
  });

  @override
  State<ProviderServicesContainer> createState() =>
      _ProviderServicesContainerState();
}

class _ProviderServicesContainerState extends State<ProviderServicesContainer> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  final Map<String, bool> _expandedOverride = {};

  bool _isExpanded(String categoryId, {required bool defaultExpanded}) =>
      _expandedOverride[categoryId] ?? defaultExpanded;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(covariant ProviderServicesContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategoryId != widget.selectedCategoryId) {
      _expandedOverride.clear();
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    if (_searchController.text.isEmpty) {
      context.read<SearchProviderServicesCubit>().resetSearch();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<SearchProviderServicesCubit>().searchServices(
        providerId: widget.providerID,
        search: _searchController.text,
      );
    });
  }

  Widget _buildRegularServicesList(BuildContext context) {
    return BlocBuilder<
      ProviderDetailsAndServiceCubit,
      ProviderDetailsAndServiceState
    >(
      builder: (context, state) {
        if (state is! ProviderDetailsAndServiceFetchSuccess) {
          return const SizedBox.shrink();
        }
        final categories = state.serviceCategories;
        final isLoadingMore = state.isLoadingMoreServices;

        if (isLoadingMore && state.loadedServicesCount == 0) {
          return Center(
            child: CustomCircularProgressIndicator(
              color: context.colors.iconBrand,
            ),
          );
        }
        if (state.loadedServicesCount == 0) {
          return Center(
            child: NoDataFoundWidget(
              titleKey: "noServicesAvailable".translate(context: context),
              subtitleKey: "noServicesFoundSubTitle".translate(
                context: context,
              ),
            ),
          );
        }
        return _buildServiceListView(
          context,
          categories: categories,
          otherServices: state.otherServices,
          isLoadingMore: isLoadingMore,
          onLoadMore: () => context
              .read<ProviderDetailsAndServiceCubit>()
              .fetchMoreServices(providerId: widget.providerID),
          hasMore: context
              .read<ProviderDetailsAndServiceCubit>()
              .hasMoreServices(),
        );
      },
    );
  }

  Widget _categoryHeader(
    BuildContext context,
    ServiceCategoryGroup group,
    bool expanded,
  ) {
    return CustomInkWellContainer(
      onTap: () =>
          setState(() => _expandedOverride[group.categoryId] = !expanded),
      child: Row(
        children: [
          Expanded(
            child: CustomText(
              '${group.categoryName} (${group.totalServices})',
              maxLines: 1,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
          AnimatedRotation(
            turns: expanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: CustomSvgPicture(
              avoideResponsive: true,
              svgImage: AppAssets.downArrow,
              height: 24,
              width: 24,
              color: context.colors.iconPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryBlock(
    BuildContext context,
    ServiceCategoryGroup group,
    bool expanded,
  ) {
    return Column(
      key: ValueKey(group.categoryId),
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        _categoryHeader(context, group, expanded),
        if (expanded)
          _cardList(
            context,
            group.services.map((s) => _serviceItem(context, s)).toList(),
          ),
      ],
    );
  }

  // Tablet shows 2-column cards (20 gap); phone keeps the single column.
  Widget _cardList(BuildContext context, List<Widget> cards) =>
      ResponsiveHelper.isTabletDevice(context)
      ? EqualHeightGrid(spacing: 20, children: cards)
      : Column(spacing: 12, children: cards);

  Widget _categorySeparator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: CustomContainer(
        height: 1,
        width: double.infinity,
        color: context.colors.borderMuted,
      ),
    );
  }

  Widget _exploreMoreServicesLabel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomText(
        'exploreMoreServices'.translate(context: context),
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: context.colors.textPrimary,
      ),
    );
  }

  Widget _activeCategoryFilterChip(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: CustomInkWellContainer(
          borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
          onTap: widget.onClearCategoryFilter,
          child: CustomContainer(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: context.colors.backgroundBrandSubtle,
            borderRadius: UiUtils.borderRadiusOf12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                CustomText(
                  widget.selectedCategoryName ?? '',
                  maxLines: 1,
                  fontSize: 14,
                  color: context.colors.textBrand,
                ),
                Icon(Icons.close, size: 16, color: context.colors.iconBrand),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _serviceItem(BuildContext context, Services service) {
    final String? serviceProviderName =
        (service.translatedPartnerName ?? '').isNotEmpty
        ? service.translatedPartnerName
        : ((service.companyName ?? '').isNotEmpty
              ? service.companyName
              : service.partnerName);
    return ServiceCard(
      serviceId: service.id ?? '',
      providerId: widget.providerID,
      title: service.translatedTitle,
      image: service.imageOfTheService,
      price: service.price,
      discountedPrice: service.discountedPrice,
      discountPercentage: service.discountPercentage,
      duration: service.duration,
      durationType: service.durationType,
      addButtonBackgroundColor: context.colors.backgroundBrandSubtle,
      numberOfMembersRequired: service.numberOfMembersRequired,
      averageRating: service.averageRating ?? service.rating,
      maximumAllowedQuantity:
          int.tryParse(service.maxQuantityAllowed ?? '0') ?? 0,
      isProviderAvailableAtLocation: widget.isProviderAvailableAtLocation,
      description: service.translatedDescription,
      companyName: service.companyName,
      showProviderName: false,
      isProviderVerified: service.isProviderVerified ?? false,
      isBookmarked: service.isBookmarked,
      serviceProviderName: serviceProviderName,
      showRatingAsBadge: true,
      imageHeight: 110,
      imageWidth: 80,
      onTap: () {
        Navigator.pushNamed(
          context,
          providerServiceDetails,
          arguments: {
            'serviceDetails': service,
            'serviceId': service.id ?? '',
            'providerId': widget.providerID,
            'isProviderAvailableAtLocation':
                widget.isProviderAvailableAtLocation,
          },
        );
      },
    );
  }

  List<ServiceCategoryGroup> _applyFilters(List<ServiceCategoryGroup> groups) {
    if (widget.filter == null || widget.filter!.isEmpty) {
      return groups;
    }

    final ServiceFilterModel filter = widget.filter!;

    if (filter.sortBy == null) return groups;

    return groups
        .map((group) {
          final List<Services> sorted = List<Services>.from(group.services);
          sorted.sort((a, b) {
            switch (filter.sortBy!) {
              case ServiceSortBy.topRated:
                final double rA =
                    double.tryParse(a.averageRating ?? a.rating ?? '0') ?? 0;
                final double rB =
                    double.tryParse(b.averageRating ?? b.rating ?? '0') ?? 0;
                return rB.compareTo(rA);
              case ServiceSortBy.priceHighToLow:
                final double pA =
                    double.tryParse(
                      (a.discountedPrice != null && a.discountedPrice != '0'
                              ? a.discountedPrice
                              : a.price) ??
                          '0',
                    ) ??
                    0;
                final double pB =
                    double.tryParse(
                      (b.discountedPrice != null && b.discountedPrice != '0'
                              ? b.discountedPrice
                              : b.price) ??
                          '0',
                    ) ??
                    0;
                return pB.compareTo(pA);
              case ServiceSortBy.priceLowToHigh:
                final double pA =
                    double.tryParse(
                      (a.discountedPrice != null && a.discountedPrice != '0'
                              ? a.discountedPrice
                              : a.price) ??
                          '0',
                    ) ??
                    0;
                final double pB =
                    double.tryParse(
                      (b.discountedPrice != null && b.discountedPrice != '0'
                              ? b.discountedPrice
                              : b.price) ??
                          '0',
                    ) ??
                    0;
                return pA.compareTo(pB);
            }
          });
          return ServiceCategoryGroup(
            categoryId: group.categoryId,
            categoryName: group.categoryName,
            totalServices: sorted.length,
            services: sorted,
          );
        })
        .where((group) => group.services.isNotEmpty)
        .toList();
  }

  List<Widget> _flattenCategories(
    BuildContext context,
    List<ServiceCategoryGroup> categories,
    List<ServiceCategoryGroup> otherServices,
  ) {
    final List<ServiceCategoryGroup> filtered = _applyFilters(categories);
    final List<ServiceCategoryGroup> visible = filtered
        .where((group) => group.services.isNotEmpty)
        .toList();
    final String? selectedId = widget.selectedCategoryId;
    final int pinnedIndex = selectedId == null
        ? -1
        : visible.indexWhere((group) => group.categoryId == selectedId);

    final List<Widget> items = [];
    if (selectedId != null) {
      items.add(_activeCategoryFilterChip(context));
      if (pinnedIndex == -1) {
        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CustomText(
              'noServicesInThisCategory'.translate(context: context),
              fontSize: 14,
              color: context.colors.textSecondary,
            ),
          ),
        );
      }
    }

    if (visible.isEmpty && (widget.filter != null && !widget.filter!.isEmpty)) {
      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: NoDataFoundWidget(
              titleKey: "noServicesFound".translate(context: context),
              subtitleKey: "noServicesFoundSubTitle".translate(
                context: context,
              ),
            ),
          ),
        ),
      );
      return items;
    }

    final List<ServiceCategoryGroup> ordered = pinnedIndex == -1
        ? visible
        : [
            visible[pinnedIndex],
            ...visible.sublist(0, pinnedIndex),
            ...visible.sublist(pinnedIndex + 1),
          ];

    for (int i = 0; i < ordered.length; i++) {
      if (i != 0) {
        items.add(_categorySeparator(context));
      }
      items.add(
        _categoryBlock(
          context,
          ordered[i],
          _isExpanded(
            ordered[i].categoryId,
            defaultExpanded: pinnedIndex == -1 || i == 0,
          ),
        ),
      );
    }

    if (selectedId != null && otherServices.isNotEmpty) {
      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: CustomSizedBox(
            height: 1,
            width: double.infinity,
            child: DashedRect(
              color: context.colors.borderStrong,
              strokeWidth: 1,
              gap: 4,
            ),
          ),
        ),
      );
      items.add(_exploreMoreServicesLabel(context));
      for (int i = 0; i < otherServices.length; i++) {
        if (i != 0) {
          items.add(_categorySeparator(context));
        }
        items.add(
          _categoryBlock(
            context,
            otherServices[i],
            _isExpanded(otherServices[i].categoryId, defaultExpanded: false),
          ),
        );
      }
    }
    return items;
  }

  Widget _buildServiceListView(
    BuildContext context, {
    required List<ServiceCategoryGroup> categories,
    required bool isLoadingMore,
    required VoidCallback onLoadMore,
    required bool hasMore,
    List<ServiceCategoryGroup> otherServices = const [],
  }) {
    final List<Widget> items = _flattenCategories(
      context,
      categories,
      otherServices,
    );
    return NotificationListener(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          if (!hasMore) return false;
          onLoadMore();
        }
        return true;
      },
      child: Container(
        color: context.colors.backgroundSecondary,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: SlideAnimationScope(
            builder: (context, controller) => SlideAnimation(
              position: 0,
              itemCount: 1,
              slideDirection: SlideDirection.fromBottom,
              animationController: controller,
              child: CustomContainer(
                color: context.colors.backgroundPrimary,
                child: ListView.builder(
                  key: const PageStorageKey("services"),
                  padding: EdgeInsetsDirectional.only(
                    top: 12.rh(context),
                    start: 16.rw(context),
                    end: 16.rw(context),
                    bottom:
                        12.rh(context) +
                        MediaQuery.viewPaddingOf(context).bottom +
                        (context
                                    .read<CartCubit>()
                                    .getProviderIDFromCartData() ==
                                '0'
                            ? 0
                            : kBottomNavigationBarHeight.rh(context) +
                                  30.rh(context)),
                  ),
                  shrinkWrap: true,
                  itemCount: items.length + (isLoadingMore ? 1 : 0),
                  itemBuilder: (final BuildContext context, final int index) {
                    if (index >= items.length) {
                      return Center(
                        child: CustomCircularProgressIndicator(
                          color: context.colors.iconBrand,
                        ),
                      );
                    }
                    return items[index];
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.backgroundSecondary,
      child:
          BlocBuilder<SearchProviderServicesCubit, SearchProviderServicesState>(
            builder: (context, searchState) {
              if (searchState is SearchProviderServicesInitial) {
                return _buildRegularServicesList(context);
              }
              if (searchState is SearchProviderServicesInProgress) {
                return Center(
                  child: CustomCircularProgressIndicator(
                    color: context.colors.iconBrand,
                  ),
                );
              }
              if (searchState is SearchProviderServicesSuccess) {
                if (searchState.loadedServicesCount == 0) {
                  return Center(
                    child: NoDataFoundWidget(
                      titleKey: "noServicesAvailable".translate(
                        context: context,
                      ),
                      subtitleKey: "noServicesFoundSubTitle".translate(
                        context: context,
                      ),
                    ),
                  );
                }
                return _buildServiceListView(
                  context,
                  categories: searchState.serviceCategories,
                  isLoadingMore: searchState.isLoadingMore,
                  onLoadMore: () =>
                      context.read<SearchProviderServicesCubit>().loadMore(),
                  hasMore: context
                      .read<SearchProviderServicesCubit>()
                      .hasMore(),
                );
              }
              if (searchState is SearchProviderServicesFailure) {
                return Center(
                  child: ErrorContainer(
                    errorMessage: searchState.errorMessage.translate(
                      context: context,
                    ),
                    onTapRetry: () {
                      context
                          .read<SearchProviderServicesCubit>()
                          .searchServices(
                            providerId: widget.providerID,
                            search: _searchController.text,
                          );
                    },
                    showRetryButton: true,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
    );
  }
}
