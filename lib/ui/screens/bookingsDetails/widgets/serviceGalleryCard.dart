import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class ServiceGalleryCard extends StatelessWidget {
  const ServiceGalleryCard({super.key, required this.bookingDetails});

  final BookingDetailModel bookingDetails;

  void _openPreview(
    final BuildContext context,
    final List<String> images,
    final int startFrom,
  ) {
    Navigator.pushNamed(
      context,
      imagePreview,
      arguments: {
        "startFrom": startFrom,
        "isReviewType": false,
        "dataURL": images,
      },
    );
  }

  Widget _buildThumbnailRow(
    final BuildContext context, {
    required final String labelKey,
    required final List<String> images,
  }) {
    if (images.isEmpty) return const CustomSizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          labelKey.translate(context: context),
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: context.colors.textSecondary,
        ),
        const CustomSizedBox(height: 8),
        Row(
          children: [
            for (int i = 0; i < images.length; i++) ...[
              if (i > 0) const CustomSizedBox(width: 12),
              CustomInkWellContainer(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _openPreview(context, images, i),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomCachedNetworkImage(
                    avoideResponsive: true,
                    height: 48,
                    width: 48,
                    networkImageUrl: images[i],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  @override
  Widget build(final BuildContext context) {
    final startImages = bookingDetails.workStartedProof ?? [];
    final endImages = bookingDetails.workCompletedProof ?? [];
    if (startImages.isEmpty && endImages.isEmpty) return const CustomSizedBox();

    return CustomContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: context.colors.surfacePrimary,
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            'serviceGallery'.translate(context: context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.colors.textPrimary,
          ),
          const CustomSizedBox(height: 12),
          CustomContainer(height: 1, color: context.colors.borderDefault),
          const CustomSizedBox(height: 12),
          if (startImages.isNotEmpty) ...[
            _buildThumbnailRow(
              context,
              labelKey: 'serviceStartImage',
              images: startImages,
            ),
            if (endImages.isNotEmpty) const CustomSizedBox(height: 12),
          ],
          if (endImages.isNotEmpty)
            _buildThumbnailRow(
              context,
              labelKey: 'serviceEndImage',
              images: endImages,
            ),
        ],
      ),
    );
  }
}
