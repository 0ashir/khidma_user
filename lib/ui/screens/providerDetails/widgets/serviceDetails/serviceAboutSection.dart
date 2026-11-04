import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import 'serviceSectionTitle.dart';

class ServiceAboutSection extends StatefulWidget {
  const ServiceAboutSection({required this.details, super.key});

  final ServiceDetailsModel details;

  @override
  State<ServiceAboutSection> createState() => _ServiceAboutSectionState();
}

class _ServiceAboutSectionState extends State<ServiceAboutSection> {
  bool _isExpanded = false;

  @override
  Widget build(final BuildContext context) {
    final ServiceDetailsModel details = widget.details;
    final String description = details.description ?? '';
    if (description.isEmpty) return const CustomSizedBox();

    final String plainText = description.plainTextFromHtml;
    final bool needsTrim = plainText.length > 150;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ServiceSectionTitle('aboutService'.translate(context: context)),
        if (!needsTrim) ...[
          HtmlWidget(
            description,
            textStyle: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 12,
            ),
          ),
        ] else if (_isExpanded) ...[
          HtmlWidget(
            description,
            textStyle: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 12,
            ),
          ),
          CustomInkWellContainer(
            onTap: () {
              setState(() {
                _isExpanded = false;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: CustomText(
                'readLess'.translate(context: context),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: context.colors.textBrand,
              ),
            ),
          ),
        ] else ...[
          CustomText(
            plainText,
            maxLines: 6,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: context.colors.textSecondary,
          ),
          CustomInkWellContainer(
            onTap: () {
              setState(() {
                _isExpanded = true;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: CustomText(
                'readMore'.translate(context: context),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: context.colors.textBrand,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
