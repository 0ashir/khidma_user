import 'package:flutter/material.dart';
import '../../../../app/generalImports.dart';
import '../../../../data/model/providerMapModel.dart';

class ProviderMapCard extends StatelessWidget {
  final ProviderMapModel provider;
  final VoidCallback? onTap;

  const ProviderMapCard({Key? key, required this.provider, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) => CustomInkWellContainer(
        onTap: onTap,
        child: CustomContainer(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.all(16),
          color: context.colorScheme.secondaryColor,
          borderRadius: UiUtils.borderRadiusOf20,
          boxShadow: [
            BoxShadow(
              color: context.colorScheme.blackColor.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            )
          ],
          child: Column(
            children: [
              Row(
                children: [
                  CustomImageContainer(
                    imageURL: provider.image,
                    height: 60,
                    width: 60,
                    borderRadius: UiUtils.borderRadiusOf10,
                    boxShadow: [],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomText(
                          provider.translatedProviderName,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          maxLines: 1,
                          color: context.colorScheme.blackColor,
                        ),
                        const SizedBox(height: 4),
                        CustomText(
                          provider.translatedCompanyName,
                          maxLines: 1,
                          fontSize: 12,
                          color: context.colorScheme.lightGreyColor,
                        ),
                        const SizedBox(height: 8),
                        Row(children: [
                          CustomText(
                            '${provider.totalServices} ${provider.totalServices.toInt() < 1 ? 'service'.translate(context: context) : 'services'.translate(context: context)}',
                            fontSize: 12,
                            color: context.colorScheme.accentColor,
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
              CustomDivider(
                color: context.colorScheme.lightGreyColor,
                thickness: 1,
                height: 10,
              ),
              IntrinsicHeight(
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    CustomText(
                      provider.rating.toString(),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    VerticalDivider(
                      color: context.colorScheme.lightGreyColor,
                      thickness: 0.5,
                    ),
                    Icon(Icons.location_on,
                        color: context.colorScheme.accentColor, size: 14),
                    const SizedBox(width: 2),
                    CustomText(
                      "${provider.distance.ceil()} ${context.read<SystemSettingCubit>().systemDistanceUnit}",
                      fontSize: 14,
                      color: context.colorScheme.blackColor,
                      fontWeight: FontWeight.w600,
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios,
                        color: context.colorScheme.blackColor, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
