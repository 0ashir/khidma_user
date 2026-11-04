import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/data/model/blogs/blogModel.dart';
import 'package:flutter/material.dart';

class BlogCard extends StatelessWidget {
  final BlogModel blog;
  final bool isBorder;

  const BlogCard({super.key, required this.blog, this.isBorder = false});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: UiUtils.borderRadiusOf12,
      border: isBorder
          ? Border.all(color: context.colors.borderDefault, width: 0.5)
          : null,
      color: context.colors.surfacePrimary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 316 / 169,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf8),
              child: CustomCachedNetworkImage(
                networkImageUrl: blog.image!,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const CustomSizedBox(height: 12),
          Row(
            children: [
              if ((blog.translatedCategoryName ?? '').isNotEmpty) ...[
                CustomContainer(
                  color: context.colors.backgroundBrandSubtle,
                  borderRadius: UiUtils.borderRadiusOf8,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: CustomText(
                    blog.translatedCategoryName ?? '',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: context.colors.textPrimary,
                  ),
                ),
                const CustomSizedBox(width: 8),
                CustomContainer(
                  width: 4,
                  height: 4,
                  color: context.colors.backgroundTertiary,
                  shape: BoxShape.circle,
                ),
                const CustomSizedBox(width: 8),
              ],
              CustomText(
                blog.createdAt!.formatDateForBlogs(),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: context.colors.textPrimary,
              ),
            ],
          ),
          const CustomSizedBox(height: 12),

          CustomText(
            blog.translatedTitle ?? '',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: context.colors.textPrimary,
            maxLines: 1,
            textAlign: TextAlign.start,
          ),
          const CustomSizedBox(height: 4),

          CustomText(
            (blog.translatedDescription ?? '').plainTextFromHtml,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: context.colors.textSecondary,
            maxLines: 3,
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}
