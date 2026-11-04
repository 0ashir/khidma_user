import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

import 'serviceSectionTitle.dart';

class ServiceInclusionSection extends StatelessWidget {
  const ServiceInclusionSection({
    required this.title,
    required this.items,
    required this.isIncluded,
    super.key,
  });

  final String title;
  final List<String> items;
  final bool isIncluded;

  @override
  Widget build(final BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ServiceSectionTitle(title),
        ...items.map(
          (final item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomSvgPicture(
                  avoideResponsive: true,
                  svgImage: isIncluded
                      ? AppAssets.checkCircleFill
                      : AppAssets.xCircleFill,
                  height: 18,
                  width: 18,
                  color: isIncluded
                      ? context.colors.iconBrand
                      : context.colors.iconError,
                ),
                const CustomSizedBox(width: 8),
                Expanded(
                  child: CustomText(
                    item,
                    color: context.colors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
