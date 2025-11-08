import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class CustomSlidableTileContainer extends StatelessWidget {
  const CustomSlidableTileContainer({
    required this.imageURL,
    required this.title,
    required this.subTitle,
    required this.durationTitle,
    required this.dateSent,
    required this.tileBackgroundColor,
    final Key? key,
    this.onSlideTap,
    this.slidableChild,
    this.isRead = false,
  }) : super(key: key);
  final VoidCallback? onSlideTap;
  final Color tileBackgroundColor;
  final String imageURL;
  final String title;
  final String subTitle;
  final String durationTitle;
  final Widget? slidableChild;
  final String dateSent;
  final bool isRead;

  CustomContainer _buildNotificationContainer(
          {required final BuildContext context}) =>
      CustomContainer(
        width: double.infinity,
        color: tileBackgroundColor,
        borderRadius: UiUtils.borderRadiusOf10,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              imageURL != ''
                  ? Align(
                      alignment: AlignmentDirectional.topStart,
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(UiUtils.borderRadiusOf10),
                        child: CustomCachedNetworkImage(
                          networkImageUrl: imageURL,
                          height: 50,
                          width: 50,
                          fit: BoxFit.fill,
                        ),
                      ),
                    )
                  : CustomContainer(
                      height: 50,
                      width: 50,
                      color: context.colorScheme.accentColor
                          .withValues(alpha: 0.1),
                      borderRadius: UiUtils.borderRadiusOf10,
                      child: Icon(
                        Icons.notifications,
                        color: context.colorScheme.accentColor,
                        size: 25,
                      ),
                    ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      title.trim(),
                      color: context.colorScheme.blackColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 5),
                    CustomReadMoreTextContainer(
                      text: subTitle,
                      textStyle: TextStyle(
                        color: context.colorScheme.blackColor,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        fontSize: 12,
                      ),
                      trimLines: 2,
                    ),
                    const SizedBox(height: 5),
                    CustomText(
                      dateSent.convertToAgo(context: context),
                      maxLines: 1,
                      color: context.colorScheme.lightGreyColor,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 10,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(final BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 10),
        child: CustomInkWellContainer(
          onTap: onSlideTap,
          child: CustomContainer(
            clipBehavior: Clip.antiAlias,
            border: isRead ? Border.all(width: 0.5) : null,
            borderRadius: UiUtils.borderRadiusOf10,
            color: tileBackgroundColor,
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.antiAlias,
                  children: [
                    if (slidableChild != null) ...[
                      Positioned.fill(
                        child: Builder(
                          builder: (final BuildContext context) =>
                              const Padding(
                            padding: EdgeInsets.zero,
                            child: CustomContainer(
                              color: AppColors.redColor,
                              borderRadius: UiUtils.borderRadiusOf10,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (slidableChild != null) ...[
                      Slidable(
                        key: UniqueKey(),
                        endActionPane: ActionPane(
                          motion: const BehindMotion(),
                          extentRatio: 0.24,
                          children:
                              slidableChild != null ? [slidableChild!] : [],
                        ),
                        child: _buildNotificationContainer(context: context),
                      ),
                    ] else ...[
                      _buildNotificationContainer(context: context)
                    ]
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
