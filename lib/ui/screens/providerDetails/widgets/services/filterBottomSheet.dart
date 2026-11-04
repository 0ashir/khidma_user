import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

enum ServiceSortBy { topRated, priceHighToLow, priceLowToHigh }

enum ServiceRatingFilter { all, fiveStar, fourStarPlus, threeStarPlus }

enum ServiceDurationFilter {
  lessThan30Min,
  between30To60Min,
  between1To2Hours,
  moreThan2Hours,
}

enum ServiceModeFilter { atDoorstep, atStore }

class ServiceFilterModel {
  final ServiceSortBy? sortBy;
  final ServiceRatingFilter? rating;
  final double? selectedMaxPrice;
  final ServiceDurationFilter? duration;
  final ServiceModeFilter? serviceMode;
  final bool payLaterAllowed;

  const ServiceFilterModel({
    this.sortBy,
    this.rating,
    this.selectedMaxPrice,
    this.duration,
    this.serviceMode,
    this.payLaterAllowed = false,
  });

  bool get isEmpty =>
      sortBy == null &&
      (rating == null || rating == ServiceRatingFilter.all) &&
      selectedMaxPrice == null &&
      duration == null &&
      serviceMode == null &&
      !payLaterAllowed;

  ServiceFilterModel copyWith({
    ServiceSortBy? sortBy,
    ServiceRatingFilter? rating,
    double? selectedMaxPrice,
    ServiceDurationFilter? duration,
    ServiceModeFilter? serviceMode,
    bool? payLaterAllowed,
    bool clearSort = false,
    bool clearRating = false,
    bool clearPrice = false,
    bool clearDuration = false,
    bool clearServiceMode = false,
  }) {
    return ServiceFilterModel(
      sortBy: clearSort ? null : (sortBy ?? this.sortBy),
      rating: clearRating ? null : (rating ?? this.rating),
      selectedMaxPrice: clearPrice
          ? null
          : (selectedMaxPrice ?? this.selectedMaxPrice),
      duration: clearDuration ? null : (duration ?? this.duration),
      serviceMode: clearServiceMode ? null : (serviceMode ?? this.serviceMode),
      payLaterAllowed: payLaterAllowed ?? this.payLaterAllowed,
    );
  }

  String? get apiSortBy {
    switch (sortBy) {
      case ServiceSortBy.topRated:
        return 'highly_rated';
      case ServiceSortBy.priceHighToLow:
        return 'price_high_to_low';
      case ServiceSortBy.priceLowToHigh:
        return 'price_low_to_high';
      case null:
        return null;
    }
  }

  double? get apiRatingMin {
    switch (rating) {
      case ServiceRatingFilter.fiveStar:
        return 5.0;
      case ServiceRatingFilter.fourStarPlus:
        return 4.0;
      case ServiceRatingFilter.threeStarPlus:
        return 3.0;
      case ServiceRatingFilter.all:
      case null:
        return null;
    }
  }

  double? get apiPriceMax => selectedMaxPrice;

  int? get apiDurationMin {
    switch (duration) {
      case ServiceDurationFilter.lessThan30Min:
        return null;
      case ServiceDurationFilter.between30To60Min:
        return 30;
      case ServiceDurationFilter.between1To2Hours:
        return 60;
      case ServiceDurationFilter.moreThan2Hours:
        return 120;
      case null:
        return null;
    }
  }

  int? get apiDurationMax {
    switch (duration) {
      case ServiceDurationFilter.lessThan30Min:
        return 30;
      case ServiceDurationFilter.between30To60Min:
        return 60;
      case ServiceDurationFilter.between1To2Hours:
        return 120;
      case ServiceDurationFilter.moreThan2Hours:
        return null;
      case null:
        return null;
    }
  }

  String? get apiServiceMode {
    switch (serviceMode) {
      case ServiceModeFilter.atDoorstep:
        return 'at_doorstep';
      case ServiceModeFilter.atStore:
        return 'at_store';
      case null:
        return null;
    }
  }

  int? get apiPayLaterAllowed => payLaterAllowed ? 1 : null;
}

class FilterBottomSheet extends StatefulWidget {
  final double maxPrice;
  final double minPrice;
  final ServiceFilterModel? currentFilter;

  const FilterBottomSheet({
    super.key,
    required this.maxPrice,
    this.minPrice = 0,
    this.currentFilter,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  ServiceSortBy? _selectedSortBy;
  ServiceRatingFilter? _selectedRating;
  late double _selectedPrice;
  late double _effectiveMaxPrice;
  late double _effectiveMinPrice;
  ServiceDurationFilter? _selectedDuration;
  ServiceModeFilter? _selectedServiceMode;
  bool _payLaterAllowed = false;

  @override
  void initState() {
    super.initState();
    _effectiveMaxPrice = widget.maxPrice > 0 ? widget.maxPrice : 400.0;
    _effectiveMinPrice = widget.minPrice.clamp(0, _effectiveMaxPrice - 1);
    _selectedSortBy = widget.currentFilter?.sortBy;
    _selectedRating = widget.currentFilter?.rating;
    _selectedPrice =
        widget.currentFilter?.selectedMaxPrice ?? _effectiveMaxPrice;
    if (_selectedPrice > _effectiveMaxPrice) {
      _selectedPrice = _effectiveMaxPrice;
    }
    if (_selectedPrice < _effectiveMinPrice) {
      _selectedPrice = _effectiveMinPrice;
    }
    _selectedDuration = widget.currentFilter?.duration;
    _selectedServiceMode = widget.currentFilter?.serviceMode;
    _payLaterAllowed = widget.currentFilter?.payLaterAllowed ?? false;
  }

  void _clearFilters() {
    setState(() {
      _selectedSortBy = null;
      _selectedRating = null;
      _selectedPrice = _effectiveMaxPrice;
      _selectedDuration = null;
      _selectedServiceMode = null;
      _payLaterAllowed = false;
    });
  }

  void _applyFilters() {
    final ServiceFilterModel filter = ServiceFilterModel(
      sortBy: _selectedSortBy,
      rating: _selectedRating,
      selectedMaxPrice: _selectedPrice < _effectiveMaxPrice
          ? _selectedPrice
          : null,
      duration: _selectedDuration,
      serviceMode: _selectedServiceMode,
      payLaterAllowed: _payLaterAllowed,
    );
    Navigator.pop(context, filter);
  }

  Widget _sectionTitle(String title) {
    return CustomText(
      title.translate(context: context),
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: context.colors.textPrimary,
    );
  }

  Widget _filterChipItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Widget? icon,
  }) {
    return CustomInkWellContainer(
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
  }

  Widget _buildSortBySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('sortBy'),
        const CustomSizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _filterChipItem(
              label: 'topRated',
              isSelected: _selectedSortBy == ServiceSortBy.topRated,
              icon: CustomSvgPicture(
                svgImage: AppAssets.starOutline,
                height: 16,
                width: 16,
                avoideResponsive: true,
                color: _selectedSortBy == ServiceSortBy.topRated
                    ? context.colors.textBrand
                    : context.colors.textPrimary,
              ),
              onTap: () {
                setState(() {
                  _selectedSortBy = _selectedSortBy == ServiceSortBy.topRated
                      ? null
                      : ServiceSortBy.topRated;
                });
              },
            ),
            _filterChipItem(
              label: 'priceHighToLow',
              isSelected: _selectedSortBy == ServiceSortBy.priceHighToLow,
              icon: CustomSvgPicture(
                svgImage: AppAssets.sortDescending,
                height: 16,
                width: 16,
                avoideResponsive: true,
                color: _selectedSortBy == ServiceSortBy.priceHighToLow
                    ? context.colors.textBrand
                    : context.colors.textPrimary,
              ),
              onTap: () {
                setState(() {
                  _selectedSortBy =
                      _selectedSortBy == ServiceSortBy.priceHighToLow
                      ? null
                      : ServiceSortBy.priceHighToLow;
                });
              },
            ),
            _filterChipItem(
              label: 'priceLowToHigh',
              isSelected: _selectedSortBy == ServiceSortBy.priceLowToHigh,
              icon: CustomSvgPicture(
                svgImage: AppAssets.sortAscending,
                height: 16,
                width: 16,
                avoideResponsive: true,
                color: _selectedSortBy == ServiceSortBy.priceLowToHigh
                    ? context.colors.textBrand
                    : context.colors.textPrimary,
              ),
              onTap: () {
                setState(() {
                  _selectedSortBy =
                      _selectedSortBy == ServiceSortBy.priceLowToHigh
                      ? null
                      : ServiceSortBy.priceLowToHigh;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
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
                  _selectedRating == ServiceRatingFilter.all,
              icon: CustomSvgPicture(
                svgImage: AppAssets.starOutline,
                height: 16,
                width: 16,
                avoideResponsive: true,
                color:
                    _selectedRating == null ||
                        _selectedRating == ServiceRatingFilter.all
                    ? context.colors.textBrand
                    : context.colors.textPrimary,
              ),
              onTap: () {
                setState(() {
                  _selectedRating = ServiceRatingFilter.all;
                });
              },
            ),
            _filterChipItem(
              label: 'fiveStar',
              isSelected: _selectedRating == ServiceRatingFilter.fiveStar,
              icon: CustomSvgPicture(
                svgImage: AppAssets.starOutline,
                height: 16,
                width: 16,
                avoideResponsive: true,
                color:
                    _selectedRating == null ||
                        _selectedRating == ServiceRatingFilter.fiveStar
                    ? context.colors.textBrand
                    : context.colors.textPrimary,
              ),
              onTap: () {
                setState(() {
                  _selectedRating =
                      _selectedRating == ServiceRatingFilter.fiveStar
                      ? null
                      : ServiceRatingFilter.fiveStar;
                });
              },
            ),
            _filterChipItem(
              label: 'plus4Star',
              isSelected: _selectedRating == ServiceRatingFilter.fourStarPlus,
              icon: CustomSvgPicture(
                svgImage: AppAssets.starOutline,
                height: 16,
                width: 16,
                avoideResponsive: true,
                color:
                    _selectedRating == null ||
                        _selectedRating == ServiceRatingFilter.fourStarPlus
                    ? context.colors.textBrand
                    : context.colors.textPrimary,
              ),
              onTap: () {
                setState(() {
                  _selectedRating =
                      _selectedRating == ServiceRatingFilter.fourStarPlus
                      ? null
                      : ServiceRatingFilter.fourStarPlus;
                });
              },
            ),
            _filterChipItem(
              label: 'plus3Star',
              isSelected: _selectedRating == ServiceRatingFilter.threeStarPlus,
              icon: CustomSvgPicture(
                svgImage: AppAssets.starOutline,
                height: 16,
                width: 16,
                avoideResponsive: true,
                color:
                    _selectedRating == null ||
                        _selectedRating == ServiceRatingFilter.threeStarPlus
                    ? context.colors.textBrand
                    : context.colors.textPrimary,
              ),
              onTap: () {
                setState(() {
                  _selectedRating =
                      _selectedRating == ServiceRatingFilter.threeStarPlus
                      ? null
                      : ServiceRatingFilter.threeStarPlus;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('priceRange'),
        const CustomSizedBox(height: 12),
        PriceRangeSlider(
          min: _effectiveMinPrice,
          max: _effectiveMaxPrice,
          value: _selectedPrice,
          onChanged: (value) {
            setState(() {
              _selectedPrice = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('duration'),
        const CustomSizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _filterChipItem(
              label: 'lessThan30Min',
              isSelected:
                  _selectedDuration == ServiceDurationFilter.lessThan30Min,
              onTap: () {
                setState(() {
                  _selectedDuration =
                      _selectedDuration == ServiceDurationFilter.lessThan30Min
                      ? null
                      : ServiceDurationFilter.lessThan30Min;
                });
              },
            ),
            _filterChipItem(
              label: 'between30To60Min',
              isSelected:
                  _selectedDuration == ServiceDurationFilter.between30To60Min,
              onTap: () {
                setState(() {
                  _selectedDuration =
                      _selectedDuration ==
                          ServiceDurationFilter.between30To60Min
                      ? null
                      : ServiceDurationFilter.between30To60Min;
                });
              },
            ),
            _filterChipItem(
              label: 'between1To2Hours',
              isSelected:
                  _selectedDuration == ServiceDurationFilter.between1To2Hours,
              onTap: () {
                setState(() {
                  _selectedDuration =
                      _selectedDuration ==
                          ServiceDurationFilter.between1To2Hours
                      ? null
                      : ServiceDurationFilter.between1To2Hours;
                });
              },
            ),
            _filterChipItem(
              label: 'moreThan2Hours',
              isSelected:
                  _selectedDuration == ServiceDurationFilter.moreThan2Hours,
              onTap: () {
                setState(() {
                  _selectedDuration =
                      _selectedDuration == ServiceDurationFilter.moreThan2Hours
                      ? null
                      : ServiceDurationFilter.moreThan2Hours;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceModeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('serviceMode'),
        const CustomSizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _filterChipItem(
              label: 'atStore',
              isSelected: _selectedServiceMode == ServiceModeFilter.atStore,
              onTap: () {
                setState(() {
                  _selectedServiceMode =
                      _selectedServiceMode == ServiceModeFilter.atStore
                      ? null
                      : ServiceModeFilter.atStore;
                });
              },
            ),
            _filterChipItem(
              label: 'doorstep',
              isSelected: _selectedServiceMode == ServiceModeFilter.atDoorstep,
              onTap: () {
                setState(() {
                  _selectedServiceMode =
                      _selectedServiceMode == ServiceModeFilter.atDoorstep
                      ? null
                      : ServiceModeFilter.atDoorstep;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPayLaterSection() {
    return CustomInkWellContainer(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() {
          _payLaterAllowed = !_payLaterAllowed;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: CustomText(
                'payLaterAllowed'.translate(context: context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.colors.textPrimary,
              ),
            ),
            const CustomSizedBox(width: 16),
            CustomSvgPicture(
              svgImage: _payLaterAllowed
                  ? AppAssets.checkCircleFill
                  : AppAssets.checkCircle,
              height: 24,
              width: 24,
              avoideResponsive: true,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
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
                  _buildServiceModeSection(),
                  const CustomSizedBox(height: 16),
                  _buildPriceRangeSection(),
                  const CustomSizedBox(height: 16),
                  _buildDurationSection(),
                  const CustomSizedBox(height: 16),
                  _buildPayLaterSection(),
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
}
