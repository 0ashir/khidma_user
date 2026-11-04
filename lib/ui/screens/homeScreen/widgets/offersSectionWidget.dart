import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class OffersSectionWidget extends StatefulWidget {
  const OffersSectionWidget({
    required this.offers,
    required this.layoutType,
    super.key,
  });

  final List<SliderImage> offers;
  final String layoutType;

  @override
  State<OffersSectionWidget> createState() => _OffersSectionWidgetState();
}

class _OffersSectionWidgetState extends State<OffersSectionWidget> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: _pages.length > 1 ? 0.85 : 1,
    );
  }

  int get _perPage => switch (widget.layoutType) {
    'two_image' => 2,
    'three_image' => 3,
    _ => 1,
  };

  double get _tileHeight => switch (widget.layoutType) {
    'two_image' => ResponsiveHelper.isTabletDevice(context) ? 155 : 124,
    'three_image' => ResponsiveHelper.isTabletDevice(context) ? 155 : 110,
    _ => ResponsiveHelper.isTabletDevice(context) ? 280 : 160,
  };

  double get _tileGap => widget.layoutType == 'two_image' ? 12 : 8;

  List<List<SliderImage>> get _pages {
    final List<List<SliderImage>> pages = <List<SliderImage>>[];
    for (int i = 0; i < widget.offers.length; i += _perPage) {
      pages.add(
        widget.offers.sublist(
          i,
          i + _perPage > widget.offers.length
              ? widget.offers.length
              : i + _perPage,
        ),
      );
    }
    return pages;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final List<List<SliderImage>> pages = _pages;

    return Column(
      children: [
        CustomSizedBox(
          height: _tileHeight,
          child: PageView.builder(
            controller: _pageController,
            padEnds: false,
            physics: pages.length > 1
                ? const PageScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            itemCount: pages.length,
            onPageChanged: (final int index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (final BuildContext context, final int pageIndex) {
              final List<SliderImage> pageOffers = pages[pageIndex];
              return Padding(
                padding: EdgeInsetsDirectional.only(
                  end: pages.length > 1 ? 8 : 0,
                ),
                child: Row(
                  children: List.generate(pageOffers.length, (final int index) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          end: index == pageOffers.length - 1 ? 0 : _tileGap,
                        ),
                        child: _OfferTile(
                          offer: pageOffers[index],
                          height: _tileHeight,
                        ),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ),
        if (pages.length > 1) ...[
          const CustomSizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pages.length, (final int index) {
              final bool isActive = index == _currentPage;
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 4),
                child: isActive
                    ? CustomContainer(
                        width: 6,
                        height: 6,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.colors.borderBrand,
                          width: 0.5,
                        ),
                      )
                    : CustomContainer(
                        width: 8,
                        height: 8,
                        shape: BoxShape.circle,
                        color: context.colors.backgroundTertiary,
                      ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _OfferTile extends StatelessWidget {
  const _OfferTile({required this.offer, required this.height});

  final SliderImage offer;
  final double height;

  @override
  Widget build(final BuildContext context) {
    return CustomInkWellContainer(
      borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
      onTap: () async {
        final String url = offer.url ?? '';
        if (url.isEmpty) return;
        try {
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(
              Uri.parse(url),
              mode: LaunchMode.externalApplication,
            );
          }
        } catch (_) {
          //ignore malformed/unreachable offer link
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
        child: CustomCachedNetworkImage(
          networkImageUrl: offer.sliderImage ?? '',
          width: double.infinity,
          height: height,
          fit: BoxFit.cover,
          avoideResponsive: true,
        ),
      ),
    );
  }
}
