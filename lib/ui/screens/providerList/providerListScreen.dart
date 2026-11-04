import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class ProviderListItem extends StatelessWidget {
  const ProviderListItem({
    final Key? key,
    this.providerDetails,
    this.categoryId,
  }) : super(key: key);
  final Providers? providerDetails;
  final String? categoryId;

  Widget _getProviderCompanyName({
    required final BuildContext context,
    required final String companyName,
    required final bool isProviderAvailableCurrently,
  }) => CustomText(
    companyName,
    color: context.colors.textPrimary,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.normal,
    fontSize: 16,
    textAlign: TextAlign.left,
  );

  @override
  Widget build(final BuildContext context) => CustomInkWellContainer(
    child: CustomContainer(
      padding: const EdgeInsetsDirectional.only(bottom: 10),
      child: Stack(
        children: [
          CustomContainer(
            padding: const EdgeInsets.all(15),
            color: context.colors.surfaceElevated,
            borderRadius: UiUtils.borderRadiusOf10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomImageContainer(
                  width: 72,
                  height: 72,
                  borderRadius: UiUtils.borderRadiusOf10,
                  imageURL: providerDetails!.image!,
                  boxFit: BoxFit.fill,
                  boxShadow: [],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.only(top: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: _getProviderCompanyName(
                                  context: context,
                                  companyName:
                                      providerDetails!.translatedCompanyName!,
                                  isProviderAvailableCurrently:
                                      providerDetails!.isAvailableNow!,
                                ),
                              ),
                              if (providerDetails!.isVerified == true) ...[
                                const SizedBox(width: 4),
                                CustomSvgPicture(
                                  avoideResponsive: true,
                                  svgImage: AppAssets.verified,
                                  height: 18,
                                  width: 18,
                                  color: context.colors.iconBrand,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const CustomSizedBox(height: 5),
                        IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CustomSvgPicture(
                                    svgImage: AppAssets.currentLocation,
                                    height: 16,
                                    width: 16,
                                    color: context.colors.textBrand,
                                  ),
                                  const CustomSizedBox(width: 5),
                                  CustomText(
                                    "${double.parse(providerDetails!.distance!).ceil()} ${context.read<SystemSettingCubit>().systemDistanceUnit}",
                                    fontSize: 14,
                                    color: context.colors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  if (providerDetails!.ratings! != '0.0')
                                    const VerticalDivider(
                                      color: Colors.black,
                                      thickness: 0.2,
                                    ),
                                  if (providerDetails!.ratings! != '0.0')
                                    Row(
                                      children: [
                                        CustomSvgPicture(
                                          avoideResponsive: true,
                                          svgImage: AppAssets.icStar,
                                          height: 16,
                                          width: 16,
                                          color: context.colors.iconWarning,
                                        ),
                                        const CustomSizedBox(width: 5),
                                        CustomText(
                                          providerDetails!.ratings!,
                                          fontSize: 14,
                                          color: context.colors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const CustomSizedBox(height: 5),
                        CustomText(
                          "${providerDetails!.totalServices} ${providerDetails!.totalServices!.convertToInt() > 1 ? 'services'.translate(context: context) : 'service'.translate(context: context)}",
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: context.colors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          PositionedDirectional(
            bottom: 12,
            end: 15,
            child: BookMarkIcon(providerData: providerDetails!),
          ),
        ],
      ),
    ),
    onTap: () {
      Navigator.pushNamed(
        context,
        providerRoute,
        arguments: {
          'providers': providerDetails,
          'providerId': providerDetails!.providerId,
        },
      );
    },
  );
}
