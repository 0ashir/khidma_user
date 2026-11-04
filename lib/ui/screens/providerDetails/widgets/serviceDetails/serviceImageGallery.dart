import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class ServiceImageGallery extends StatelessWidget {
  const ServiceImageGallery({required this.details, super.key});

  final ServiceDetailsModel details;

  void _openImagePreview(
    final BuildContext context,
    final List<String> images,
  ) {
    UiUtils.showBottomSheet(
      context: context,
      enableDrag: true,
      isScrollControlled: true,
      useSafeArea: true,
      child: ServiceImagesList(imageList: images),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final List<String> images = <String>[
      details.image ?? '',
      ...details.otherImages,
    ].where((final e) => e.isNotEmpty).toList();

    final List<String> sideThumbnails = images.length > 1
        ? images.sublist(1).take(3).toList()
        : [];

    final bool isTablet = ResponsiveHelper.isTabletDevice(context);

    Widget wrapGallery(final double aspectRatio, final Widget child) => isTablet
        ? SizedBox(height: 380, width: double.infinity, child: child)
        : AspectRatio(aspectRatio: aspectRatio, child: child);

    if (sideThumbnails.isEmpty) {
      return wrapGallery(
        352 / 336,
        CustomInkWellContainer(
          borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf8),
          onTap: () => _openImagePreview(context, images),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf8),
            child: CustomCachedNetworkImage(
              networkImageUrl: images.isNotEmpty ? images.first : '',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }

    return wrapGallery(
      352 / 336,
      Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 260,
            child: CustomInkWellContainer(
              borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf8),
              onTap: () => _openImagePreview(context, images),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf8),
                child: CustomCachedNetworkImage(
                  networkImageUrl: images.first,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const CustomSizedBox(width: 12),
          Expanded(
            flex: 80,
            child: Column(
              children: List.generate(sideThumbnails.length, (final index) {
                final bool isLast = index == sideThumbnails.length - 1;
                final bool hasMore = images.length > 4 && isLast;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      top: index == 0 ? 0 : 6,
                      bottom: isLast ? 0 : 6,
                    ),
                    child: CustomInkWellContainer(
                      borderRadius: BorderRadius.circular(
                        UiUtils.borderRadiusOf8,
                      ),
                      onTap: () => _openImagePreview(context, images),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              UiUtils.borderRadiusOf8,
                            ),
                            child: CustomCachedNetworkImage(
                              networkImageUrl: sideThumbnails[index],
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (hasMore)
                            CustomContainer(
                              color: context.colors.overlayDefault,
                              borderRadius: UiUtils.borderRadiusOf8,
                              child: Center(
                                child: CustomText(
                                  'viewAll'.translate(context: context),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: context.colors.textInverseLight,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
