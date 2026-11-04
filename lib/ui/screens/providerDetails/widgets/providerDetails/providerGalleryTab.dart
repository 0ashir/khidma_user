import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class ProviderGalleryTab extends StatelessWidget {
  const ProviderGalleryTab({required this.images, super.key});

  final List<String> images;

  @override
  Widget build(final BuildContext context) {
    if (images.isEmpty) {
      return Center(
        child: NoDataFoundWidget(
          titleKey: "noDataFound".translate(context: context),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(
        16,
      ).copyWith(bottom: 16 + MediaQuery.viewPaddingOf(context).bottom),
      physics: const ClampingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.isTabletDevice(context) ? 6 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 960 / 540, // 16:9 ratio matching Figma design
      ),
      itemCount: images.length,
      itemBuilder: (context, index) => CustomInkWellContainer(
        onTap: () {
          Navigator.pushNamed(
            context,
            imagePreview,
            arguments: {
              "startFrom": index,
              "isReviewType": false,
              "dataURL": images,
            },
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CustomCachedNetworkImage(
            networkImageUrl: images[index],
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
