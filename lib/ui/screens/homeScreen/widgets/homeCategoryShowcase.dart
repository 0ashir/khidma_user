import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/ui/screens/homeScreen/widgets/homeHeader.dart';
import 'package:flutter/material.dart';

/// Filter chips + "What can we help with?" photo grid.
///
/// "All services" shows the `all_categories` section. Every admin
/// `categories` featured section becomes an extra chip (its title is the chip
/// label, its categories are the filtered grid), e.g. "Car care", "Home care".
class HomeCategoryShowcase extends StatefulWidget {
  const HomeCategoryShowcase({
    required this.allCategoriesSection,
    required this.groupSections,
    this.banner,
    super.key,
  });

  final Sections? allCategoriesSection;
  final List<Sections> groupSections;

  /// Promo banner shown between the chips and the services grid.
  final Widget? banner;

  @override
  State<HomeCategoryShowcase> createState() => _HomeCategoryShowcaseState();
}

class _HomeCategoryShowcaseState extends State<HomeCategoryShowcase> {
  static const double _sideInset = 16;
  int _selected = 0;

  List<CategoryModel> get _allCategories {
    final List<CategoryModel> fromAll =
        widget.allCategoriesSection?.categories ?? const [];
    if (fromAll.isNotEmpty) return fromAll;
    // No "all categories" section: merge the group sections instead.
    final Map<String, CategoryModel> merged = {};
    for (final Sections s in widget.groupSections) {
      for (final CategoryModel c in s.categories) {
        merged.putIfAbsent(c.id ?? c.name ?? '', () => c);
      }
    }
    return merged.values.toList();
  }

  List<CategoryModel> get _visible {
    if (_selected == 0) return _allCategories;
    // Curated sections come back in id order; follow the admin sort order
    // of the "All services" grid so tiles keep the same relative order.
    final List<String?> order = _allCategories.map((c) => c.id).toList();
    final List<CategoryModel> group = List.of(
      widget.groupSections[_selected - 1].categories,
    );
    int rank(CategoryModel c) {
      final int i = order.indexOf(c.id);
      return i < 0 ? order.length : i;
    }

    group.sort((a, b) => rank(a).compareTo(rank(b)));
    return group;
  }

  Widget _chip(final String label, final int index) {
    final bool active = _selected == index;
    return CustomInkWellContainer(
      borderRadius: BorderRadius.circular(6),
      onTap: () => setState(() => _selected = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        decoration: BoxDecoration(
          color: active
              ? context.colors.backgroundBrand
              : context.colors.backgroundPrimary,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: active
                ? context.colors.backgroundBrand
                : context.colors.borderDefault,
          ),
        ),
        child: CustomText(
          label,
          fontSize: 12,
          fontWeight: active ? FontWeight.w700 : FontWeight.w600,
          color: active
              ? context.colors.textInverseLight
              : context.colors.textPrimary,
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _chips() {
    final List<String> labels = [
      homeText(context, 'allServices', 'All services'),
      ...widget.groupSections.map((s) => s.translatedTitle ?? ''),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: _sideInset),
      child: Row(
        spacing: 8,
        children: List.generate(labels.length, (i) => _chip(labels[i], i)),
      ),
    );
  }

  Color _cardColor(final CategoryModel category) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String? hex = isDark
        ? category.backgroundDarkColor
        : category.backgroundLightColor;
    if (hex != null && RegExp(r'^#?[0-9a-fA-F]{6}$').hasMatch(hex.trim())) {
      return hex.trim().toColor();
    }
    return context.colors.backgroundBrandSubtle;
  }

  Widget _card(final CategoryModel category) => CustomInkWellContainer(
    borderRadius: BorderRadius.circular(10),
    onTap: () => UiUtils.navigateToCategoryDetails(
      context,
      categoryId: category.id,
      categoryName: category.name,
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        color: _cardColor(category),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomCachedNetworkImage(
                networkImageUrl: category.categoryImage ?? '',
                width: double.infinity,
                height: double.infinity,
                avoideResponsive: true,
                fit: BoxFit.cover,
                defaultColourFilter: false,
              ),
            ),
            // Light wash over the top-start corner so the label stays
            // readable on any photo (busy or dark images included).
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                      colors: [
                        Colors.white.withValues(alpha: 0.92),
                        Colors.white.withValues(alpha: 0.6),
                        Colors.white.withValues(alpha: 0),
                      ],
                      stops: const [0, 0.3, 0.6],
                    ),
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              start: 12,
              top: 12,
              end: 48,
              child: CustomText(
                category.name ?? '',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0D0D0D),
                maxLines: 2,
                height: 1.15,
                letterSpacing: -0.4,
              ),
            ),
            PositionedDirectional(
              end: 10,
              top: 10,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: Color(0xFF0D0D0D),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _grid(final List<CategoryModel> categories) {
    final int columns = ResponsiveHelper.isTabletDevice(context) ? 3 : 2;
    final List<CategoryModel> shown = categories
        .take(columns == 3 ? 9 : 6)
        .toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _sideInset),
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: shown.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.5,
        ),
        itemBuilder: (_, i) => _card(shown[i]),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    if (_selected > widget.groupSections.length) _selected = 0;
    final List<CategoryModel> categories = _visible;
    if (_allCategories.isEmpty) return const CustomSizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.groupSections.isNotEmpty) ...[
          _chips(),
          const CustomSizedBox(height: 14),
        ],
        if (widget.banner != null) ...[
          widget.banner!,
          // Matches the gap above the banner once the heading's line
          // spacing is counted.
          const CustomSizedBox(height: 10),
        ] else if (widget.groupSections.isNotEmpty)
          const CustomSizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _sideInset),
          child: Row(
            children: [
              Expanded(
                child: CustomText(
                  homeText(context, 'ourServices', 'Our Services'),
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textPrimary,
                  maxLines: 1,
                ),
              ),
              CustomInkWellContainer(
                onTap: () => Navigator.pushNamed(context, allCategoriesRoute),
                child: CustomText(
                  'viewAll'.translate(context: context),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textBrand,
                ),
              ),
            ],
          ),
        ),
        const CustomSizedBox(height: 12),
        _grid(categories),
      ],
    );
  }
}
