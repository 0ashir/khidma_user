import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class AreaRequestSubmittedView extends StatelessWidget {
  const AreaRequestSubmittedView({
    super.key,
    required this.selectedAddress,
    required this.onChangeLocation,
  });

  final ValueNotifier selectedAddress;
  final VoidCallback onChangeLocation;

  @override
  Widget build(final BuildContext context) => Column(
    children: [
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const CustomSizedBox(height: 32),
              CustomContainer(
                padding: const EdgeInsets.all(20),
                shape: BoxShape.circle,
                color: context.colors.backgroundSuccess,
                child: Icon(
                  Icons.check,
                  size: 40,
                  color: context.colors.iconInverseLight,
                ),
              ),
              const CustomSizedBox(height: 24),
              CustomText(
                'areaRequestSubmitted'.translate(context: context),
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: context.colors.textPrimary,
              ),
              const CustomSizedBox(height: 8),
              CustomText(
                'areaRequestSubmittedMessage'.translate(context: context),
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: context.colors.textSecondary,
              ),
              const CustomSizedBox(height: 24),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: CustomText(
                  'requestedLocation'.translate(context: context),
                  fontSize: 12,
                  color: context.colors.textSecondary,
                ),
              ),
              const CustomSizedBox(height: 8),
              ValueListenableBuilder(
                valueListenable: selectedAddress,
                builder: (context, value, child) {
                  value as Map;
                  return CustomContainer(
                    width: context.screenWidth,
                    padding: const EdgeInsets.all(12),
                    color: context.colors.backgroundPrimary,
                    borderRadius: 12,
                    child: Row(
                      children: [
                        CustomContainer(
                          padding: const EdgeInsets.all(8),
                          color: context.colors.backgroundSecondary,
                          borderRadius: 8,
                          child: CustomSvgPicture(
                            svgImage: AppAssets.mapPinArea,
                            width: 24,
                            height: 24,
                            color: context.colors.iconPrimary,
                          ),
                        ),
                        const CustomSizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                value["lineOneAddress"] ?? '',
                                maxLines: 1,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: context.colors.textPrimary,
                              ),
                              const CustomSizedBox(height: 2),
                              CustomText(
                                value["lineTwoAddress"] ?? '',
                                maxLines: 1,
                                fontSize: 12,
                                color: context.colors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          top: false,
          child: CustomRoundedButton(
            onTap: onChangeLocation,
            widthPercentage: 1,
            height: 48,
            radius: 16,
            backgroundColor: context.colors.backgroundBrand,
            titleColor: context.colors.textInverseLight,
            buttonTitle: 'changeLocation'.translate(context: context),
            showBorder: false,
          ),
        ),
      ),
    ],
  );
}
