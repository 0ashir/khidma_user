import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class ServicesListWidget extends StatelessWidget {
  final ScrollController servicesScrollController;
  final VoidCallback onTapRetry;
  final VoidCallback onErrorButtonPressed;

  const ServicesListWidget({
    super.key,
    required this.servicesScrollController,
    required this.onTapRetry,
    required this.onErrorButtonPressed,
  });

  Widget _getServicesList(
    BuildContext context, {
    required final List<Providers> providerList,
    required final bool isLoadingMoreData,
    required final bool isLoadingMoreError,
  }) {
    final cartButtonHeight =
        context.read<CartCubit>().getProviderIDFromCartData() == '0' ? 0 : 20;
    return ListView.separated(
      separatorBuilder: (context, index) => const CustomSizedBox(height: 10),
      controller: servicesScrollController,
      padding: EdgeInsetsDirectional.only(
        bottom: UiUtils.getScrollViewBottomPadding(context) + cartButtonHeight,
        end: 15,
        start: 15,
        top: 10,
      ),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount:
          providerList.length +
          (isLoadingMoreData || isLoadingMoreError ? 1 : 0),
      itemBuilder: (final BuildContext context, final int index) {
        if (index >= providerList.length) {
          return CustomLoadingMoreContainer(
            isError: isLoadingMoreError,
            onErrorButtonPressed: onErrorButtonPressed,
          );
        }
        return CustomContainer(
          width: context.screenWidth,
          color: context.colors.surfaceElevated,
          borderRadius: UiUtils.borderRadiusOf10,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: CustomInkWellContainer(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      providerRoute,
                      arguments: {"providerId": providerList[index].id},
                    );
                  },
                  child: Row(
                    children: [
                      CustomContainer(
                        borderRadius: UiUtils.borderRadiusOf5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            UiUtils.borderRadiusOf5,
                          ),
                          child: CustomCachedNetworkImage(
                            networkImageUrl: providerList[index].image ?? '',
                            width: 35,
                            height: 35,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      const CustomSizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomText(
                              providerList[index].translatedPartnerName ?? '',
                              color: context.colors.textPrimary,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 12,
                              textAlign: TextAlign.left,
                              maxLines: 1,
                            ),
                            CustomText(
                              providerList[index].translatedCompanyName ?? '',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_right,
                        color: context.colors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              CustomContainer(
                height: 155,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shrinkWrap: false,
                  scrollDirection: Axis.horizontal,
                  itemCount: providerList[index].services?.length ?? 0,
                  itemBuilder: (context, serviceIndex) {
                    if (providerList[index].services == null) {
                      return Container();
                    }
                    return _buildServiceListItem(
                      context,
                      services: providerList[index].services![serviceIndex],
                      providerId: providerList[index].id!,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          providerServiceDetails,
                          arguments: {
                            'serviceDetails':
                                providerList[index].services![serviceIndex],
                            'serviceId':
                                providerList[index]
                                    .services![serviceIndex]
                                    .id ??
                                '',
                            'providerId': providerList[index].id!,
                          },
                        );
                      },
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const CustomSizedBox(width: 10),
                ),
              ),
              const CustomSizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlocConsumer<SearchServicesCubit, SearchServicesState>(
          listener: (final BuildContext context, final searchState) {
            if (searchState is SearchServicesFailureState) {
              UiUtils.showMessage(
                context,
                searchState.errorMessage,
                ToastificationType.error,
              );
            }
          },
          builder: (final BuildContext context, final searchState) {
            if (searchState is SearchServicesFailureState) {
              return Center(
                child: ErrorContainer(
                  errorMessage: 'somethingWentWrong'.translate(
                    context: context,
                  ),
                  onTapRetry: onTapRetry,
                  showRetryButton: true,
                ),
              );
            } else if (searchState is SearchServicesSuccessState) {
              if (searchState.providersWithServicesList.isEmpty) {
                return Center(
                  child: NoDataFoundWidget(
                    titleKey: 'noServicesFound'.translate(context: context),
                    subtitleKey: 'noServicesFoundSubTitle'.translate(
                      context: context,
                    ),
                  ),
                );
              }
              return _getServicesList(
                context,
                isLoadingMoreError: searchState.isLoadingMoreError,
                providerList: searchState.providersWithServicesList,
                isLoadingMoreData: searchState.isLoadingMore,
              );
            } else if (searchState is SearchServicesProgressState) {
              return const SearchServicesShimmerEffect();
            }
            return Center(
              child: NoDataFoundWidget(
                titleKey: "typeToSearch".translate(context: context),
                showRetryButton: false,
              ),
            );
          },
        ),
        const Align(
          alignment: Alignment.bottomCenter,
          child: CartSubDetailsContainer(),
        ),
      ],
    );
  }

  Widget _buildServiceListItem(
    BuildContext context, {
    required Services services,
    required String providerId,
    required VoidCallback onTap,
  }) {
    return ServiceCard(
      width: context.screenWidth - 76,
      showBorder: false,
      serviceId: services.id ?? '',
      providerId: providerId,
      title: services.translatedTitle,
      image: services.imageOfTheService,
      price: services.price,
      discountedPrice: services.discountedPrice,
      discountPercentage: services.discountPercentage,
      duration: services.duration,
      durationType: services.durationType,
      numberOfMembersRequired: services.numberOfMembersRequired,
      averageRating: services.averageRating ?? services.rating,
      maximumAllowedQuantity:
          int.tryParse(services.maxQuantityAllowed ?? '0') ?? 0,
      isProviderAvailableAtLocation: '1',
      serviceProviderName:
          services.translatedPartnerName ?? services.partnerName,
      onTap: onTap,
    );
  }
}
