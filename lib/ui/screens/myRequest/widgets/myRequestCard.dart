import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class MyRequestCardContainer extends StatelessWidget {
  final MyRequestListModel myRequestDetails;

  const MyRequestCardContainer({
    super.key,
    required this.myRequestDetails,
  });

  Widget _buildPriceContainer({required BuildContext context}) {
    return Row(
      children: [
        CustomText(
          myRequestDetails.minPrice!.priceFormat(context),
          color: context.colorScheme.blackColor,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        CustomText(
          '  ${'to'.translate(context: context)}  ',
          color: context.colorScheme.lightGreyColor,
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
        CustomText(
          myRequestDetails.maxPrice!.priceFormat(context),
          color: context.colorScheme.blackColor,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ],
    );
  }

  Widget _buildViewDetails({
    required final BuildContext context,
  }) =>
      CustomRoundedButton(
          onTap: () {
            Navigator.pushNamed(context, myRequestDetailsScreen, arguments: {
              'customJobRequestId': myRequestDetails.id,
              'status': myRequestDetails.status,
              'translatedStatus':myRequestDetails.translatedStatus
            });
          },
          height: 30,
          radius: 5,
          widthPercentage: ResponsiveHelper.isLargeTablet(context) ||
                  ResponsiveHelper.isTablet(context)
              ? 0.2
              : 0.3,
          buttonTitle: 'viewDetails'.translate(context: context),
          titleColor: context.colorScheme.accentColor,
          textSize: 12,
          fontWeight: FontWeight.w400,
          showBorder: false,
          backgroundColor:
              context.colorScheme.accentColor.withValues(alpha: 0.1));

  Widget _buildCategoryContainer({required BuildContext context}) {
    return CustomContainer(
      color:
          Theme.of(context).colorScheme.lightGreyColor.withValues(alpha: 0.25),
      borderRadius: UiUtils.borderRadiusOf5,
      padding: const EdgeInsetsDirectional.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
              child: CustomCachedNetworkImage(
                avoideResponsive: true,
                height: 18,
                width: 18,
                networkImageUrl: myRequestDetails.categoryImage ?? '',
                fit: BoxFit.fill,
              ),
            ),
          ),
          const SizedBox(
            width: 4,
          ),
          Flexible(
            flex: 8,
            child: CustomText(
              myRequestDetails.categoryName!,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomStatusContainer({
    required final BuildContext context,
    required final String status,
    required final String translatedStatus,
  }) =>
      CustomContainer(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
        borderRadius: 5,
        color:
            UiUtils.getBookingStatusColor(context: context, statusVal: status)
                .withValues(alpha: 0.1),
        child: CustomText(
          status == 'pending'
              ? 'requested'.translate(context: context)
              : translatedStatus,
          fontSize: 14,
          color: UiUtils.getBookingStatusColor(
              context: context, statusVal: status),
          maxLines: 1,
          fontWeight: FontWeight.w500,
        ),
      );

  Widget _buildServiceTitleContainer({
    required final BuildContext context,
  }) =>
      CustomText(
        myRequestDetails.serviceTitle!,
        fontSize: 16,
        color: context.colorScheme.blackColor,
        maxLines: 1,
        fontWeight: FontWeight.w600,
      );

  Widget _buildBidsContainer({required final BuildContext context}) {
    final isTablet = ResponsiveHelper.isLargeTablet(context) ||
        ResponsiveHelper.isTablet(context);
    if (myRequestDetails.totalBids == 0) {
      return Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                text: "noBidsAvailable".translate(context: context),
                style: TextStyle(
                  fontSize: 14,
                  color: context.colorScheme.blackColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
          _buildViewDetails(context: context),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomContainer(
            height: 35,
            width: myRequestDetails.totalBids == 1
                ? 35
                : myRequestDetails.totalBids == 2
                    ? 50
                    : myRequestDetails.totalBids == 3
                        ? 65
                        : 80,
            child: Stack(
                children: List.generate(
              myRequestDetails.totalBids ?? 0,
              (index) {
                if (index < 4) {
                  if (index == 3 && (myRequestDetails.totalBids ?? 0) > 4) {
                    return Positioned(
                      left: index * 15.0,
                      child: CustomContainer(
                        alignment: Alignment.center,
                        height: 32,
                        width: 32,
                        color: context.colorScheme.accentColor,
                        border: Border.all(
                          color: context.colorScheme.lightGreyColor,
                          width: 0.5,
                        ),
                        borderRadius: UiUtils.borderRadiusOf50,
                        child: CustomText(
                          "+${(myRequestDetails.totalBids ?? 0) - 3}",
                          fontSize: 14,
                          color: context.colorScheme.surfaceBright,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  } else if (index <= 3 ||
                      (myRequestDetails.totalBids ?? 0) == 3) {
                    return Positioned(
                      left: index * 15.0,
                      child: CustomContainer(
                        color: context.colorScheme.secondaryColor,
                        border: Border.all(
                          color: context.colorScheme.lightGreyColor,
                          width: 0.5,
                        ),
                        borderRadius: UiUtils.borderRadiusOf50,
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(UiUtils.borderRadiusOf50),
                          child: CustomCachedNetworkImage(
                            avoideResponsive: true,
                            height: isTablet ? 40 : 32,
                            width: isTablet ? 40 : 32,
                            networkImageUrl: myRequestDetails
                                    .bidders?[index]?.providerImage ??
                                '',
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            )),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 5, start: 2),
            child: CustomText(
              'bids'.translate(context: context),
              fontSize: 14,
              color: context.colorScheme.accentColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          _buildViewDetails(context: context),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, myRequestDetailsScreen, arguments: {
          'customJobRequestId': myRequestDetails.id,
          'status': myRequestDetails.status,
          'translatedStatus':myRequestDetails.translatedStatus
        });
      },
      child: CustomContainer(
        margin: const EdgeInsets.symmetric(vertical: 10),
        color: context.colorScheme.secondaryColor,
        borderRadius: UiUtils.borderRadiusOf10,
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 2,
                  child: _buildCategoryContainer(
                    context: context,
                  ),
                ),
                // const Spacer(),
                const SizedBox(
                  width: 10,
                ),
                Flexible(
                  child: _buildCustomStatusContainer(
                    context: context,
                    status: myRequestDetails.status!,
                    translatedStatus: myRequestDetails.translatedStatus!
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            _buildServiceTitleContainer(
              context: context,
            ),
            const SizedBox(
              height: 8,
            ),
            CustomText(
              'budget'.translate(context: context),
              color: Theme.of(context)
                  .colorScheme
                  .lightGreyColor
                  .withValues(alpha: 0.5),
              fontSize: 14,
            ),
            _buildPriceContainer(context: context),
            CustomDivider(
              thickness: 0.5,
              color: Theme.of(context)
                  .colorScheme
                  .lightGreyColor
                  .withValues(alpha: 0.5),
              height: 20,
            ),
            _buildBidsContainer(context: context),
          ],
        ),
      ),
    );
  }
}
