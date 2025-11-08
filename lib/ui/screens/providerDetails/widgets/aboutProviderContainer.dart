import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class AboutProviderContainer extends StatelessWidget {
  final Providers providerDetails;

  AboutProviderContainer({super.key, required this.providerDetails});

  String _replaceColorsWithTheme(String html, BuildContext context) {
    // Replace only color styles while preserving other styling
    final themeColorHex = context.colorScheme.lightGreyColor
        .toARGB32()
        .toRadixString(16)
        .substring(2);


    // Replace color: #hex patterns
    html = html.replaceAll(
        RegExp(r'color:\s*#[0-9a-fA-F]{3,6}'), 'color: #$themeColorHex');

    // Replace color: rgb patterns
    html = html.replaceAll(
        RegExp(r'color:\s*rgb\([^)]+\)'), 'color: #$themeColorHex');

    // Replace color: rgba patterns
    html = html.replaceAll(
        RegExp(r'color:\s*rgba\([^)]+\)'), 'color: #$themeColorHex');

    return html;
  }

  Widget CustomContainerWithTitle({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    return CustomContainer(
      margin: const EdgeInsetsDirectional.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      width: double.infinity,
      color: context.colorScheme.secondaryColor,
      borderRadius: UiUtils.borderRadiusOf10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            title,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.colorScheme.blackColor,
          ),
          const SizedBox(
            height: 10,
          ),
          child,
        ],
      ),
    );
  }

  Widget ProviderDescriptionSection({required BuildContext context}) {
    return CustomContainerWithTitle(
      context: context,
      title: "companyInformation".translate(context: context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Theme(
          data: Theme.of(context).copyWith(
            textTheme: Theme.of(context).textTheme.apply(
              bodyColor: context.colorScheme.lightGreyColor,
              displayColor: context.colorScheme.lightGreyColor,
            ),
          ),
          child: HtmlWidget(
            _replaceColorsWithTheme(providerDetails.translatedLongDescription ?? '', context),
            enableCaching: false,
          ),
        ),
      ),
    );
  }

  Widget ContactUsSection({
    required BuildContext context,
  }) {
    return CustomContainerWithTitle(
      context: context,
      title: "contactUs".translate(context: context),
      child: CustomInkWellContainer(
        onTap: () async {
          UiUtils.openMap(context,
              latitude: providerDetails.latitude ?? "0.0",
              longitude: providerDetails.longitude ?? "0.0");
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      double.parse(providerDetails.latitude ?? "0.0"),
                      double.parse(providerDetails.longitude ?? "0.0"),
                    ),
                    zoom: 12,
                  ),
                  zoomControlsEnabled: false,
                  liteModeEnabled: Platform.isAndroid,
                  scrollGesturesEnabled: true,
                  markers: Set<Marker>.of([
                    Marker(
                      markerId: MarkerId(
                        providerDetails.id.toString(),
                      ),
                      position: LatLng(
                        double.parse(providerDetails.latitude ?? "0.0"),
                        double.parse(providerDetails.longitude ?? "0.0"),
                      ),
                    )
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 5),
            CustomText(
              providerDetails.translatedCompanyName ?? '',
              color: context.colorScheme.blackColor,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.normal,
              fontSize: 14,
              height: 2,
              maxLines: 1,
            ),
            Row(
              children: [
                CustomSvgPicture(
                  svgImage: AppAssets.currentLocation,
                  height: 20,
                  width: 20,
                  color: context.colorScheme.accentColor,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8),
                    child: CustomText(
                      providerDetails.address ?? '',
                      color: context.colorScheme.blackColor,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                      fontSize: 12,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.only(
        top: 10,
        end: 15,
        start: 15.rw(context),
        bottom: context.read<CartCubit>().getProviderIDFromCartData() == '0'
            ? 0
            : kBottomNavigationBarHeight.rh(context) + 10.rh(context),
      ),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomContainerWithTitle(
                context: context,
                title: "aboutThisProvider".translate(context: context),
                child: ReadMoreText(
                  style: TextStyle(
                    color: context.colorScheme.lightGreyColor,
                  ),
                  providerDetails.translatedAbout!,
                  trimLines: 3,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: "showMore".translate(context: context),
                  trimExpandedText: "showLess".translate(context: context),
                  lessStyle: TextStyle(
                    color: context.colorScheme.blackColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  moreStyle: TextStyle(
                    color: context.colorScheme.blackColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              CustomContainerWithTitle(
                context: context,
                title: "businessHours".translate(context: context),
                child: Column(
                  children: List.generate(
                      providerDetails.businessDayInfo!.length, (index) {
                    return Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: CustomText(
                            providerDetails.businessDayInfo![index].day
                                .toString()
                                .translate(context: context),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: providerDetails
                                      .businessDayInfo![index].isOpen ==
                                  "1"
                              ? CustomText(
                                  "${providerDetails.businessDayInfo![index].openingTime.toString().formatTime()}  -  ${providerDetails.businessDayInfo![index].closingTime.toString().formatTime()}",
                                  maxLines: 1,
                                )
                              : Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: CustomText(
                                    "closed".translate(context: context),
                                    height: 1.5,
                                    color: context.colorScheme.lightGreyColor,
                                    maxLines: 1,
                                  ),
                                ),
                        )
                      ],
                    );
                  }),
                ),
              ),
              if (providerDetails.otherImagesOfTheService!.isNotEmpty) ...[
                CustomContainerWithTitle(
                  context: context,
                  title: "photos".translate(context: context),
                  child: GalleryImagesStyles(
                      imagesList: providerDetails.otherImagesOfTheService!),
                ),
              ],
              if (providerDetails.translatedLongDescription!.isNotEmpty) ...[
                ProviderDescriptionSection(context: context),
              ],
              if (providerDetails.address!.isNotEmpty &&
                  context.read<SystemSettingCubit>().showProviderAddress) ...[
                ContactUsSection(context: context)
              ]
            ],
          ),
        ],
      ),
    );
  }
}
