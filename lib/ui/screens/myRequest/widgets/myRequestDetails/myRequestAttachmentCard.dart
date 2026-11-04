import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

import 'myRequestSectionCard.dart';

class MyRequestAttachmentCard extends StatefulWidget {
  const MyRequestAttachmentCard({required this.job, super.key});

  final CustomJob job;

  @override
  State<MyRequestAttachmentCard> createState() =>
      _MyRequestAttachmentCardState();
}

class _MyRequestAttachmentCardState extends State<MyRequestAttachmentCard> {
  final Map<String, bool> _downloadingMap = {};

  @override
  Widget build(final BuildContext context) {
    final CustomJob job = widget.job;
    final attachments = job.attachments;
    if (attachments == null) return const SizedBox.shrink();

    final mediaUrls = [...attachments.images, ...attachments.videos];
    final docUrls = attachments.others;

    if (mediaUrls.isEmpty && docUrls.isEmpty) return const SizedBox.shrink();

    return MyRequestSectionCard(
      title: 'attachment'.translate(context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mediaUrls.isNotEmpty) ...[
            _buildMediaThumbnails(context, mediaUrls),
            if (docUrls.isNotEmpty) const CustomSizedBox(height: 12),
          ],
          ...docUrls.map(
            (url) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildFileRow(context, url),
            ),
          ),
          ...attachments.videos.map(
            (url) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildFileRow(context, url, isVideo: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaThumbnails(
    final BuildContext context,
    final List<String> urls,
  ) {
    const maxVisible = 4;
    final visibleUrls = urls.take(maxVisible).toList();
    final extra = urls.length - maxVisible;

    return Row(
      children: [
        ...visibleUrls.asMap().entries.map((entry) {
          final idx = entry.key;
          final url = entry.value;
          final isLast = idx == maxVisible - 1 && extra > 0;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CustomInkWellContainer(
              borderRadius: BorderRadius.circular(8),
              onTap: () => Navigator.pushNamed(
                context,
                imagePreview,
                arguments: {
                  'dataURL': urls,
                  'startFrom': idx,
                  'isReviewType': false,
                  'reviewDetails': null,
                },
              ),
              child: CustomContainer(
                width: 48,
                height: 48,
                borderRadius: 8,
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomCachedNetworkImage(
                      networkImageUrl: url,
                      fit: BoxFit.cover,
                      height: 48,
                      width: 48,
                    ),
                    if (isLast)
                      Container(
                        color: context.colors.overlayDefault,
                        alignment: Alignment.center,
                        child: CustomText(
                          '+$extra',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: context.colors.textInverseLight,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFileRow(
    final BuildContext context,
    final String url, {
    final bool isVideo = false,
  }) {
    final fileName = Uri.parse(url).pathSegments.last;
    final isDownloading = _downloadingMap[url] ?? false;
    return CustomInkWellContainer(
      borderRadius: BorderRadius.circular(8),
      onTap: isDownloading
          ? null
          : () async {
              setState(() => _downloadingMap[url] = true);
              await UiUtils.downloadOrShareFile(
                url: url,
                customFileName: fileName,
                isDownload: true,
              );
              if (mounted) setState(() => _downloadingMap[url] = false);
            },
      child: CustomContainer(
        padding: const EdgeInsets.all(12),
        color: context.colors.surfacePrimary,
        borderRadius: 8,
        border: Border.all(color: context.colors.borderDefault, width: 1.5),
        child: Row(
          children: [
            CustomContainer(
              padding: const EdgeInsets.all(8),
              color: context.colors.backgroundSecondary,
              borderRadius: 8,
              child: CustomSvgPicture(
                svgImage: isVideo ? AppAssets.play : AppAssets.fileText,
                height: 16,
                width: 16,
                color: context.colors.iconSecondary,
                avoideResponsive: true,
              ),
            ),
            const CustomSizedBox(width: 8),
            Expanded(
              child: CustomText(
                fileName,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                maxLines: 1,
                color: context.colors.textPrimary,
              ),
            ),
            const CustomSizedBox(width: 8),
            isDownloading
                ? CustomCircularProgressIndicator(
                    color: context.colors.iconBrand,
                    widthAndHeight: 20,
                  )
                : CustomSvgPicture(
                    svgImage: AppAssets.download,
                    height: 24,
                    width: 24,
                    color: context.colors.iconSecondary,
                    avoideResponsive: true,
                  ),
          ],
        ),
      ),
    );
  }
}
