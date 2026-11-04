import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/ui/screens/homeScreen/widgets/animatedSearchHint.dart';
import 'package:flutter/material.dart';

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
  /// 0 = location row fully visible, 1 = fully collapsed (scrolled).
  final ValueNotifier<double> _headerCollapse = ValueNotifier<double>(0);
  static const double _headerCollapseDistance = 56;

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

  Widget _buildSearchBar() => CustomInkWellContainer(
    borderRadius: BorderRadius.circular(12),
    onTap: () async {
      ClarityService.logAction(ClarityActions.searchScreenOpened, {
        'source': 'home_top_search',
      });
      await Navigator.pushNamed(context, searchCategoriesScreen);
    },
    child: CustomContainer(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: context.colors.backgroundPrimary,
      borderRadius: 12,
      avoideResponsive: true,
      child: Row(
        children: [
          CustomSvgPicture(
            svgImage: AppAssets.search,
            height: 24,
            width: 24,
            color: context.colors.iconPrimary,
            avoideResponsive: true,
          ),
          const CustomSizedBox(width: 8),
          const Expanded(child: AnimatedSearchHint()),
        ],
      ),
    ),
  );

  Widget _buildLocationRow() => Row(
    children: [
      Expanded(
        child: CustomInkWellContainer(
          onTap: widget.onLocationTap,
          child: Row(
            children: [
              CustomContainer(
                width: 40,
                height: 40,
                borderRadius: 20,
                color: context.colors.backgroundSecondary,
                clipBehavior: Clip.antiAlias,
                child:
                    (HiveRepository.getUserProfilePictureURL == null ||
                        HiveRepository.getUserProfilePictureURL == '')
                    ? Padding(
                        padding: const EdgeInsets.all(8),
                        child: CustomSvgPicture(
                          svgImage: AppAssets.user,
                          color: context.colors.iconPrimary,
                        ),
                      )
                    : CustomCachedNetworkImage(
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                        networkImageUrl: HiveRepository.getUserProfilePictureURL
                            .toString(),
                      ),
              ),
              const CustomSizedBox(width: 8),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: Hive.box(
                    HiveRepository.userDetailBoxKey,
                  ).listenable(),
                  builder: (BuildContext context, Box box, _) {
                    final String? locationArea = HiveRepository.getLocationArea;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: CustomText(
                                (HiveRepository.getLocationName == null ||
                                        HiveRepository.getLocationName!.isEmpty)
                                    ? "selectYourLocation".translate(
                                        context: context,
                                      )
                                    : HiveRepository.getLocationName!,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: context.colors.textInverseLight,
                                maxLines: 1,
                              ),
                            ),
                            const CustomSizedBox(width: 4),
                            CustomSvgPicture(
                              svgImage: AppAssets.downArrow,
                              height: 20,
                              width: 20,
                              avoideResponsive: true,
                              color: context.colors.iconInverseLight,
                            ),
                          ],
                        ),
                        if (locationArea != null && locationArea.isNotEmpty)
                          CustomText(
                            locationArea,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: context.colors.textInverseLight,
                            maxLines: 1,
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      const CustomSizedBox(width: 12),
      CustomInkWellContainer(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
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
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.colors.backgroundPrimary,
            shape: BoxShape.circle,
          ),
          child: CustomSvgPicture(
            svgImage: AppAssets.notification,
            height: 24,
            width: 24,
            color: context.colors.iconPrimary,
            avoideResponsive: true,
          ),
        ),
      ),
    ],
  );

  @override
  Widget build(final BuildContext context) => CustomContainer(
    color: context.colors.backgroundBrand,
    padding: EdgeInsetsDirectional.only(
      top: MediaQuery.paddingOf(context).top + 12,
      start: 16,
      end: 16,
      bottom: 16,
    ),
    borderRadiusStyle: const BorderRadius.only(
      bottomLeft: Radius.circular(16),
      bottomRight: Radius.circular(16),
    ),
    boxShadow: [
      BoxShadow(
        color: context.colors.overlayHeaderShadow,
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
    child: Column(
      children: [
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
                      padding: const EdgeInsetsDirectional.only(bottom: 16),
                      child: _buildLocationRow(),
                    ),
                  ),
                ),
              ),
        ),
        _buildSearchBar(),
      ],
    ),
  );
}
