import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

/// Translates [key], falling back to [fallback] when no language file
/// (bundled or server-provided) has it yet.
String homeText(
  final BuildContext context,
  final String key,
  final String fallback,
) {
  final String value = key.translate(context: context);
  return value == key ? fallback : value;
}

/// Short place label for the header. Locations are stored as the comma-joined
/// geocoder parts "place name, area (subLocality), city (locality), country",
/// with empty parts already dropped. The first part is usually a nearby
/// building or shop (e.g. "Interlock") and the last is the country, so show
/// the area and city: "Mohammed Bin Zayed City, Abu Dhabi". Literal "null"s,
/// plus codes and house/street numbers are ignored.
String cleanLocationLabel(final String? raw) {
  if (raw == null) return '';
  // Positions come from the stored order, so only drop empty / "null" parts
  // here; junk is filtered after the area and city are picked.
  final List<String> parts = raw
      .split(',')
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty && p.toLowerCase() != 'null')
      .toList();
  bool isJunk(final String p) =>
      p.contains('+') || RegExp('^[0-9]').hasMatch(p);

  final List<String> picked = switch (parts.length) {
    >= 4 => [parts[1], parts[2]], // area, city
    3 => [parts[1]], // one part missing: the middle one is the safest
    2 => [parts[0]], // place + country: drop the country
    _ => List.of(parts),
  }.where((p) => !isJunk(p)).toSet().toList();

  if (picked.isNotEmpty) return picked.join(', ');
  // Fallback: first usable part anywhere.
  return parts.firstWhere((p) => !isJunk(p), orElse: () => '');
}

class HomeHeader extends StatefulWidget {
  const HomeHeader({
    required this.scrollController,
    required this.onLocationTap,
    super.key,
  });

  final ScrollController scrollController;
  final VoidCallback onLocationTap;

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  /// 0 = location + headline fully visible, 1 = fully collapsed (scrolled).
  final ValueNotifier<double> _headerCollapse = ValueNotifier<double>(0);
  static const double _headerCollapseDistance = 96;
  static const bool _showHeadline = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onHomeScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onHomeScroll);
    _headerCollapse.dispose();
    super.dispose();
  }

  void _onHomeScroll() {
    if (!widget.scrollController.hasClients) return;
    final double next =
        (widget.scrollController.offset / _headerCollapseDistance).clamp(
          0.0,
          1.0,
        );
    if (next != _headerCollapse.value) _headerCollapse.value = next;
  }

  void _openNotifications() {
    final authStatus = context.read<AuthenticationCubit>().state;
    if (authStatus is UnAuthenticatedState) {
      UiUtils.showBottomSheet(
        context: context,
        enableDrag: true,
        isScrollControlled: true,
        useSafeArea: true,
        child: const LoginRequiredBottomSheet(),
      );
      return;
    }
    ClarityService.logAction(ClarityActions.notificationOpened, {
      'previous_route': Routes.currentRoute,
    });
    Navigator.pushNamed(context, notificationRoute);
  }

  Widget _buildBrandRow() => Row(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          AppAssets.splashLogo,
          width: 30,
          height: 30,
          fit: BoxFit.cover,
        ),
      ),
      const CustomSizedBox(width: 8),
      Expanded(
        child: CustomText(
          homeText(context, 'appName', appName),
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: context.colors.textPrimary,
          maxLines: 1,
        ),
      ),
      CustomInkWellContainer(
        borderRadius: BorderRadius.circular(24),
        onTap: _openNotifications,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: context.colors.backgroundPrimary,
            shape: BoxShape.circle,
            border: Border.all(color: context.colors.borderDefault),
          ),
          child: CustomSvgPicture(
            svgImage: AppAssets.notification,
            height: 19,
            width: 19,
            color: context.colors.iconPrimary,
            avoideResponsive: true,
          ),
        ),
      ),
    ],
  );

  Widget _buildLocationRow() => CustomInkWellContainer(
    onTap: widget.onLocationTap,
    child: ValueListenableBuilder(
      valueListenable: Hive.box(HiveRepository.userDetailBoxKey).listenable(),
      builder: (BuildContext context, Box box, _) {
        // A saved address picked in the location sheet shows its own label
        // ("Apartment · Marina Tower, Apt 304"); otherwise the place name.
        final String savedLabel =
            HiveRepository.getSelectedAddress?['label']?.trim() ?? '';
        final String locationName = savedLabel.isNotEmpty
            ? savedLabel
            : cleanLocationLabel(HiveRepository.getLocationName);
        // Single compact line: pin · address · chevron.
        return Row(
          children: [
            CustomSvgPicture(
              svgImage: AppAssets.icLocation,
              height: 16,
              width: 16,
              avoideResponsive: true,
              color: context.colors.iconBrand,
            ),
            const CustomSizedBox(width: 6),
            Flexible(
              child: CustomText(
                locationName.isEmpty
                    ? "selectYourLocation".translate(context: context)
                    : locationName,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
                maxLines: 1,
              ),
            ),
            const CustomSizedBox(width: 2),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: context.colors.iconPrimary,
            ),
          ],
        );
      },
    ),
  );

  Widget _buildHeadline() => CustomText(
    homeText(context, 'homeHeadline', 'Your day, made easier.'),
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: context.colors.textPrimary,
    height: 1.2,
  );

  Widget _buildSearchBar() => CustomInkWellContainer(
    borderRadius: BorderRadius.circular(14),
    onTap: () async {
      ClarityService.logAction(ClarityActions.searchScreenOpened, {
        'source': 'home_top_search',
      });
      await Navigator.pushNamed(context, searchCategoriesScreen);
    },
    child: Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: context.colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.borderDefault),
      ),
      child: Row(
        children: [
          CustomSvgPicture(
            svgImage: AppAssets.search,
            height: 20,
            width: 20,
            color: context.colors.iconSecondary,
            avoideResponsive: true,
          ),
          const CustomSizedBox(width: 10),
          Expanded(
            child: CustomText(
              homeText(context, 'searchForAService', 'Search for a Service'),
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 14,
              maxLines: 1,
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(final BuildContext context) => Container(
    color: context.colors.backgroundPrimary,
    padding: EdgeInsetsDirectional.only(
      top: MediaQuery.paddingOf(context).top + 6,
      start: 16,
      end: 16,
      bottom: 8,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrandRow(),
        ValueListenableBuilder<double>(
          valueListenable: _headerCollapse,
          builder: (final BuildContext context, final double collapse, _) =>
              ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: 1 - collapse,
                  child: Opacity(
                    opacity: 1 - collapse,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLocationRow(),
                          // Headline hidden for now; set to true to show it.
                          if (_showHeadline) ...[
                            const CustomSizedBox(height: 10),
                            _buildHeadline(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
        ),
        const CustomSizedBox(height: 14),
        _buildSearchBar(),
      ],
    ),
  );
}
