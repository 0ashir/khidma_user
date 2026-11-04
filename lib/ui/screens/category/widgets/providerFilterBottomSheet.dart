import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

enum ProviderSortBy { topRated, priceHighToLow, priceLowToHigh }

enum ProviderRatingFilter { all, fiveStar, fourStarPlus, threeStarPlus }

enum ProviderTypeFilter { organization, individual }

class ProviderFilterModel {
  const ProviderFilterModel({
    this.sortBy,
    this.rating,
    this.type,
    this.selectedMaxPrice,
  });

  final ProviderSortBy? sortBy;
  final ProviderRatingFilter? rating;
  final ProviderTypeFilter? type;
  final double? selectedMaxPrice;

  bool get isEmpty =>
      sortBy == null &&
      (rating == null || rating == ProviderRatingFilter.all) &&
      type == null &&
      selectedMaxPrice == null;

  ProviderFilterModel copyWith({
    final ProviderSortBy? sortBy,
    final ProviderRatingFilter? rating,
    final ProviderTypeFilter? type,
    final double? selectedMaxPrice,
    final bool clearSort = false,
    final bool clearRating = false,
    final bool clearType = false,
    final bool clearPrice = false,
  }) => ProviderFilterModel(
    sortBy: clearSort ? null : (sortBy ?? this.sortBy),
    rating: clearRating ? null : (rating ?? this.rating),
    type: clearType ? null : (type ?? this.type),
    selectedMaxPrice: clearPrice
        ? null
        : (selectedMaxPrice ?? this.selectedMaxPrice),
  );

  String? get apiSortBy {
    switch (sortBy) {
      case ProviderSortBy.topRated:
        return 'highly_rated';
      case ProviderSortBy.priceHighToLow:
        return 'price_high_to_low';
      case ProviderSortBy.priceLowToHigh:
        return 'price_low_to_high';
      case null:
        return null;
    }
  }

  double? get apiRatingMin {
    switch (rating) {
      case ProviderRatingFilter.fiveStar:
        return 5.0;
      case ProviderRatingFilter.fourStarPlus:
        return 4.0;
      case ProviderRatingFilter.threeStarPlus:
        return 3.0;
      case ProviderRatingFilter.all:
      case null:
        return null;
    }
  }

  String? get apiProviderType {
    switch (type) {
      case ProviderTypeFilter.organization:
        return 'organization';
      case ProviderTypeFilter.individual:
        return 'individual';
      case null:
        return null;
    }
  }

  double? get apiPriceMax => selectedMaxPrice;
}

class ProviderFilterBottomSheet extends StatefulWidget {
  const ProviderFilterBottomSheet({
    required this.maxPrice,
    super.key,
    this.minPrice = 0,
    this.currentFilter,
  });

  final double maxPrice;
  final double minPrice;
  final ProviderFilterModel? currentFilter;

  @override
  State<ProviderFilterBottomSheet> createState() =>
      _ProviderFilterBottomSheetState();
}

class _ProviderFilterBottomSheetState extends State<ProviderFilterBottomSheet> {
  ProviderSortBy? _selectedSortBy;
  ProviderRatingFilter? _selectedRating;
  ProviderTypeFilter? _selectedType;
  late double _selectedPrice;
  late double _effectiveMaxPrice;
  late double _effectiveMinPrice;

  @override
  void initState() {
    super.initState();
    _effectiveMaxPrice = widget.maxPrice > 0 ? widget.maxPrice : 400.0;
    _effectiveMinPrice = widget.minPrice.clamp(0, _effectiveMaxPrice - 1);
    _selectedSortBy = widget.currentFilter?.sortBy;
    _selectedRating = widget.currentFilter?.rating;
    _selectedType = widget.currentFilter?.type;
    _selectedPrice =
        widget.currentFilter?.selectedMaxPrice ?? _effectiveMaxPrice;
    if (_selectedPrice > _effectiveMaxPrice)
      _selectedPrice = _effectiveMaxPrice;
    if (_selectedPrice < _effectiveMinPrice)
      _selectedPrice = _effectiveMinPrice;
  }

  void _clearFilters() {
    setState(() {
      _selectedSortBy = null;
      _selectedRating = null;
      _selectedType = null;
      _selectedPrice = _effectiveMaxPrice;
    });
  }

  void _applyFilters() {
    final ProviderFilterModel filter = ProviderFilterModel(
      sortBy: _selectedSortBy,
      rating: _selectedRating,
      type: _selectedType,
      selectedMaxPrice: _selectedPrice < _effectiveMaxPrice
          ? _selectedPrice
          : null,
    );
    Navigator.pop(context, filter);
  }

  Widget _sectionTitle(final String title) => CustomText(
    title.translate(context: context),
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: context.colors.textPrimary,
  );

  Widget _filterChipItem({
    required final String label,
    required final bool isSelected,
    required final VoidCallback onTap,
    final Widget? icon,
  }) => CustomInkWellContainer(
    borderRadius: BorderRadius.circular(16),
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? context.colors.backgroundBrandSubtle
            : context.colors.backgroundPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? context.colors.backgroundBrand
              : context.colors.borderMuted,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon, const CustomSizedBox(width: 8)],
          CustomText(
            label.translate(context: context),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            color: isSelected
                ? context.colors.textBrand
                : context.colors.textPrimary,
          ),
        ],
      ),
    ),
  );

  Widget _sortIcon(final String svgImage, final bool isSelected) =>
      CustomSvgPicture(
        svgImage: svgImage,
        height: 16,
        width: 16,
        avoideResponsive: true,
        color: isSelected
            ? context.colors.textBrand
            : context.colors.textPrimary,
      );

  Widget _buildSortBySection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionTitle('sortBy'),
      const CustomSizedBox(height: 8),
      // Figma also shows a "Nearest First" sort option, but the confirmed
      // `sort_by` values for get_all_providers are only highly_rated /
      // price_high_to_low / price_low_to_high — no distance-sort value.
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _filterChipItem(
            label: 'topRated',
            isSelected: _selectedSortBy == ProviderSortBy.topRated,
            icon: _sortIcon(
              AppAssets.starOutline,
              _selectedSortBy == ProviderSortBy.topRated,
            ),
            onTap: () => setState(() {
              _selectedSortBy = _selectedSortBy == ProviderSortBy.topRated
                  ? null
                  : ProviderSortBy.topRated;
            }),
          ),
          _filterChipItem(
            label: 'priceHighToLow',
            isSelected: _selectedSortBy == ProviderSortBy.priceHighToLow,
            icon: _sortIcon(
              AppAssets.sortDescending,
              _selectedSortBy == ProviderSortBy.priceHighToLow,
            ),
            onTap: () => setState(() {
              _selectedSortBy = _selectedSortBy == ProviderSortBy.priceHighToLow
                  ? null
                  : ProviderSortBy.priceHighToLow;
            }),
          ),
          _filterChipItem(
            label: 'priceLowToHigh',
            isSelected: _selectedSortBy == ProviderSortBy.priceLowToHigh,
            icon: _sortIcon(
              AppAssets.sortAscending,
              _selectedSortBy == ProviderSortBy.priceLowToHigh,
            ),
            onTap: () => setState(() {
              _selectedSortBy = _selectedSortBy == ProviderSortBy.priceLowToHigh
                  ? null
                  : ProviderSortBy.priceLowToHigh;
            }),
          ),
        ],
      ),
    ],
  );

  Widget _buildRatingSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionTitle('rating'),
      const CustomSizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _filterChipItem(
            label: 'all',
            isSelected:
                _selectedRating == null ||
                _selectedRating == ProviderRatingFilter.all,
            icon: _sortIcon(
              AppAssets.starOutline,
              _selectedRating == null ||
                  _selectedRating == ProviderRatingFilter.all,
            ),
            onTap: () =>
                setState(() => _selectedRating = ProviderRatingFilter.all),
          ),
          _filterChipItem(
            label: 'fiveStar',
            isSelected: _selectedRating == ProviderRatingFilter.fiveStar,
            icon: _sortIcon(
              AppAssets.starOutline,
              _selectedRating == ProviderRatingFilter.fiveStar,
            ),
            onTap: () => setState(() {
              _selectedRating = _selectedRating == ProviderRatingFilter.fiveStar
                  ? null
                  : ProviderRatingFilter.fiveStar;
            }),
          ),
          _filterChipItem(
            label: 'plus4Star',
            isSelected: _selectedRating == ProviderRatingFilter.fourStarPlus,
            icon: _sortIcon(
              AppAssets.starOutline,
              _selectedRating == ProviderRatingFilter.fourStarPlus,
            ),
            onTap: () => setState(() {
              _selectedRating =
                  _selectedRating == ProviderRatingFilter.fourStarPlus
                  ? null
                  : ProviderRatingFilter.fourStarPlus;
            }),
          ),
          _filterChipItem(
            label: 'plus3Star',
            isSelected: _selectedRating == ProviderRatingFilter.threeStarPlus,
            icon: _sortIcon(
              AppAssets.starOutline,
              _selectedRating == ProviderRatingFilter.threeStarPlus,
            ),
            onTap: () => setState(() {
              _selectedRating =
                  _selectedRating == ProviderRatingFilter.threeStarPlus
                  ? null
                  : ProviderRatingFilter.threeStarPlus;
            }),
          ),
        ],
      ),
    ],
  );

  Widget _buildTypeSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionTitle('type'),
      const CustomSizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _filterChipItem(
            label: 'organization',
            isSelected: _selectedType == ProviderTypeFilter.organization,
            onTap: () => setState(() {
              _selectedType = _selectedType == ProviderTypeFilter.organization
                  ? null
                  : ProviderTypeFilter.organization;
            }),
          ),
          _filterChipItem(
            label: 'individual',
            isSelected: _selectedType == ProviderTypeFilter.individual,
            onTap: () => setState(() {
              _selectedType = _selectedType == ProviderTypeFilter.individual
                  ? null
                  : ProviderTypeFilter.individual;
            }),
          ),
        ],
      ),
    ],
  );

  Widget _buildPriceRangeSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionTitle('priceRange'),
      const CustomSizedBox(height: 12),
      PriceRangeSlider(
        min: _effectiveMinPrice,
        max: _effectiveMaxPrice,
        value: _selectedPrice,
        onChanged: (value) => setState(() => _selectedPrice = value),
      ),
    ],
  );

  @override
  Widget build(final BuildContext context) => CustomContainer(
    color: context.colors.backgroundPrimary,
    borderRadiusStyle: const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.borderDefault,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              const CustomSizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: CustomText(
                  'filterBy'.translate(context: context),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
              const CustomSizedBox(height: 12),
              Container(
                height: 1,
                width: double.infinity,
                color: context.colors.borderMuted,
              ),
            ],
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSortBySection(),
                const CustomSizedBox(height: 16),
                _buildRatingSection(),
                const CustomSizedBox(height: 16),
                _buildTypeSection(),
                const CustomSizedBox(height: 16),
                _buildPriceRangeSection(),
                const CustomSizedBox(height: 8),
              ],
            ),
          ),
        ),
        ClipShadowBottom(
          child: Container(
            padding: const EdgeInsets.all(
              16,
            ).copyWith(bottom: 16 + MediaQuery.viewPaddingOf(context).bottom),
            decoration: BoxDecoration(
              color: context.colors.backgroundPrimary,
              boxShadow: [
                BoxShadow(
                  color: context.colors.overlayFooterShadow,
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomInkWellContainer(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _clearFilters,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: context.colors.backgroundBrandSubtle,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.colors.backgroundBrand,
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: CustomText(
                        'clearFilter'.translate(context: context),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: context.colors.textBrand,
                      ),
                    ),
                  ),
                ),
                const CustomSizedBox(width: 12),
                Expanded(
                  child: CustomInkWellContainer(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _applyFilters,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: context.colors.backgroundBrand,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: CustomText(
                        'apply'.translate(context: context),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: context.colors.textInverseLight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
