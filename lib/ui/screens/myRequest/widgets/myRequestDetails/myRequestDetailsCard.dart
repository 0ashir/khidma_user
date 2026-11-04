import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

import 'myRequestSectionCard.dart';

class MyRequestDetailsCard extends StatelessWidget {
  const MyRequestDetailsCard({required this.job, super.key});

  final CustomJob job;

  Widget _buildIconRow(
    final BuildContext context, {
    required final String svgIcon,
    required final String label,
    required final String value,
    final CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  }) => Row(
    crossAxisAlignment: crossAxisAlignment,
    children: [
      CustomContainer(
        padding: const EdgeInsets.all(8),
        color: context.colors.backgroundSecondary,
        borderRadius: 8,
        child: CustomSvgPicture(
          svgImage: svgIcon,
          height: 20,
          width: 20,
          color: context.colors.iconPrimary,
          avoideResponsive: true,
        ),
      ),
      const CustomSizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              label,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: context.colors.textSecondary,
            ),
            const CustomSizedBox(height: 4),
            CustomText(
              value,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: context.colors.textPrimary,
            ),
          ],
        ),
      ),
    ],
  );

  @override
  Widget build(final BuildContext context) {
    // final phone = [
    //   job.countryCode,
    //   job.phone,
    // ].where((v) => v != null && v.isNotEmpty).join(' ');

    return MyRequestSectionCard(
      title: 'viewRequestDetails'.translate(context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            'description'.translate(context: context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.colors.textPrimary,
          ),
          const CustomSizedBox(height: 8),
          CustomReadMoreTextContainer(
            text: job.description ?? '',
            trimLines: 5,
            textStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: context.colors.textSecondary,
            ),
          ),
          if ((job.description ?? '').isNotEmpty)
            MyRequestSectionCard.divider(context),
          // if (phone.isNotEmpty) ...[
          //   _buildIconRow(
          //     context,
          //     svgIcon: AppAssets.phoneCall,
          //     label: 'phoneNumber'.translate(context: context),
          //     value: phone,
          //   ),
          //   MyRequestSectionCard.divider(context),
          // ],
          _buildIconRow(
            context,
            svgIcon: AppAssets.calendar,
            label: 'startAt'.translate(context: context),
            value: (job.startDateTime ?? '').formatDateAndTime(),
          ),
          MyRequestSectionCard.divider(context),
          _buildIconRow(
            context,
            svgIcon: AppAssets.calendar,
            label: 'endAt'.translate(context: context),
            value: (job.endDateTime ?? '').formatDateAndTime(),
          ),
        ],
      ),
    );
  }
}
