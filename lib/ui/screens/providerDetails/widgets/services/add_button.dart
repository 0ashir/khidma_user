import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  const AddButton({
    required this.alreadyAddedQuantity,
    required this.serviceId,
    required this.maximumAllowedQuantity,
    final Key? key,
    this.height,
    this.width,
    this.isProviderAvailableAtLocation,
    this.addButtonWithIcon,
    this.padding,
    this.backgroundColor,
    this.serviceProviderName,
    this.iconSize,
    this.countFontSize,
    required this.providerId,
  }) : super(key: key);

  final String serviceId;
  final String providerId;
  final String? isProviderAvailableAtLocation;
  final int maximumAllowedQuantity;
  final int alreadyAddedQuantity;
  final double? height;
  final double? width;
  final bool? addButtonWithIcon;
  final Color? backgroundColor;
  final double? padding;
  final String? serviceProviderName;
  final double? iconSize;
  final double? countFontSize;

  @override
  Widget build(final BuildContext context) {
    return BlocConsumer<AddServiceIntoCartCubit, AddServiceIntoCartState>(
      listener:
          (
            final BuildContext context,
            final AddServiceIntoCartState addServiceIntoCartState,
          ) {
            if (addServiceIntoCartState is AddServiceIntoCartFailure) {
              UiUtils.showMessage(
                context,
                addServiceIntoCartState.errorMessage,
                ToastificationType.error,
              );
            }
            if (addServiceIntoCartState is AddServiceIntoCartSuccess) {
              if (addServiceIntoCartState.error == false) {
                context.read<CartCubit>().updateCartDetails(
                  addServiceIntoCartState.cartDetails,
                );
              } else {
                UiUtils.showMessage(
                  context,
                  addServiceIntoCartState.successMessage,
                  ToastificationType.error,
                );
              }
            }
          },
      builder:
          (
            final BuildContext context,
            final AddServiceIntoCartState addServiceIntoCartState,
          ) => BlocConsumer<RemoveServiceFromCartCubit, RemoveServiceFromCartState>(
            listener:
                (
                  context,
                  RemoveServiceFromCartState removeServiceFromCartState,
                ) {
                  if (removeServiceFromCartState
                      is RemoveServiceFromCartFailure) {
                    UiUtils.showMessage(
                      context,
                      removeServiceFromCartState.errorMessage,
                      ToastificationType.error,
                    );
                  }
                  if (removeServiceFromCartState
                      is RemoveServiceFromCartSuccess) {
                    if (removeServiceFromCartState.error == false) {
                      final removedCart =
                          removeServiceFromCartState.cartDetails;
                      final hasValidCart =
                          removedCart != null &&
                          (removedCart.carId?.isNotEmpty ?? false) &&
                          (int.tryParse(removedCart.totalQuantity ?? '0') ??
                                  0) >
                              0;
                      if (hasValidCart) {
                        context.read<CartCubit>().updateCartDetails(
                          removedCart,
                        );
                      } else {
                        context.read<CartCubit>().getCartDetails(
                          isReorderCart: false,
                        );
                      }
                    }
                  }
                },
            builder:
                (
                  final BuildContext context,
                  RemoveServiceFromCartState removeServiceFromCartState,
                ) {
                  final bool isAddOrRemoveInProgress =
                      addServiceIntoCartState is AddServiceIntoCartInProgress ||
                      removeServiceFromCartState
                          is RemoveServiceFromCartInProgress;

                  return alreadyAddedQuantity <= 0
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomInkWellContainer(
                              onTap: () async {
                            if (isProviderAvailableAtLocation == "0") {
                              UiUtils.showMessage(
                                context,
                                'currentlyNotAvailableAtSelectedAddress'
                                    .translate(context: context),
                                ToastificationType.warning,
                              );
                              return;
                            }
                            final authStatus = context
                                .read<AuthenticationCubit>()
                                .state;
                            if (authStatus is UnAuthenticatedState) {
                              await UiUtils.showBottomSheet(
                                context: context,
                                enableDrag: true,
                                isScrollControlled: true,
                                useSafeArea: true,
                                child: const LoginRequiredBottomSheet(),
                              );

                              return;
                            }
                            if (alreadyAddedQuantity < maximumAllowedQuantity) {
                              final cartSettings = context
                                  .read<SystemSettingCubit>()
                                  .cartSettings;
                              final restrictionError = context
                                  .read<CartCubit>()
                                  .checkCartRestrictions(
                                    providerId: providerId,
                                    maxItemsPerProvider:
                                        cartSettings?.maxItemsPerProvider ?? 5,
                                    maxCartsPerUser:
                                        cartSettings?.maxCartsPerUser ?? 3,
                                  );
                              if (restrictionError != null) {
                                UiUtils.showMessage(
                                  context,
                                  restrictionError.translate(context: context),
                                  ToastificationType.warning,
                                );
                                return;
                              }

                              await context
                                  .read<AddServiceIntoCartCubit>()
                                  .addServiceIntoCart(
                                    serviceId: int.parse(serviceId),
                                    quantity: 1,
                                    serviceProviderId: providerId,
                                    serviceProviderName: serviceProviderName,
                                    cartCubit: context.read<CartCubit>(),
                                  );
                            } else {
                              UiUtils.showMessage(
                                context,
                                'maximumLimitReached'.translate(
                                  context: context,
                                ),
                                ToastificationType.warning,
                              );
                            }
                          },
                          child: addButtonWithIcon == true
                              ? Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CustomText(
                                        'add'.translate(context: context),
                                        textAlign: TextAlign.left,
                                        color:
                                            isProviderAvailableAtLocation == "0"
                                            ? context.colors.textTertiary
                                            : context.colors.textBrand,
                                        fontStyle: FontStyle.normal,
                                        fontSize: 14,
                                      ),
                                      const CustomSizedBox(width: 10),
                                      Icon(
                                        Icons.add_circle_rounded,
                                        color: context.colors.iconBrand,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                )
                              : CustomContainer(
                                  borderRadius: UiUtils.borderRadiusOf8,
                                  color: backgroundColor,
                                  border: Border.all(
                                    color: context.colors.borderBrand,
                                  ),
                                  height: height ?? 35,
                                  width: padding != null ? null : (width ?? 80),
                                  padding: padding != null
                                      ? EdgeInsets.symmetric(
                                          horizontal: padding!,
                                        )
                                      : null,
                                  child: Center(
                                    child: CustomText(
                                      'add'.translate(context: context),
                                      textAlign: TextAlign.center,
                                      color:
                                          isProviderAvailableAtLocation == "0"
                                          ? context.colors.textTertiary
                                          : context.colors.textBrand,
                                      fontStyle: FontStyle.normal,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                            ),
                            if (isAddOrRemoveInProgress)
                              CustomShimmerLoadingContainer(
                                borderRadius: UiUtils.borderRadiusOf8,
                                height: height ?? 35,
                                width: padding != null ? 50 : (width ?? 80),
                              ),
                          ],
                        )
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomContainer(
                              height: height ?? 35,
                              width: padding != null ? null : (width ?? 80),
                              padding: padding != null
                                  ? EdgeInsets.symmetric(horizontal: padding!)
                                  : null,
                              color: backgroundColor,
                              border: Border.all(
                                color: context.colors.borderBrand,
                              ),
                              borderRadius: UiUtils.borderRadiusOf8,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                spacing: 12,
                                children: [
                                  CustomInkWellContainer(
                                    onTap: () {
                                      final authStatus = context
                                          .read<AuthenticationCubit>()
                                          .state;
                                      if (authStatus is UnAuthenticatedState) {
                                        UiUtils.showBottomSheet(
                                          context: context,
                                          enableDrag: true,
                                          isScrollControlled: true,
                                          useSafeArea: true,
                                          child:
                                              const LoginRequiredBottomSheet(),
                                        );
                                        return;
                                      }

                                      if (alreadyAddedQuantity > 1) {
                                        // Add service into cart
                                        context
                                            .read<AddServiceIntoCartCubit>()
                                            .addServiceIntoCart(
                                              serviceId: int.parse(serviceId),
                                              quantity:
                                                  alreadyAddedQuantity - 1,
                                              serviceProviderId: providerId,
                                              serviceProviderName:
                                                  serviceProviderName,
                                              cartCubit: context
                                                  .read<CartCubit>(),
                                            );
                                      } else {
                                        // remove service from cart
                                        context
                                            .read<RemoveServiceFromCartCubit>()
                                            .removeServiceFromCart(
                                              serviceId: int.parse(serviceId),
                                              providerId: providerId,
                                            );
                                      }
                                    },
                                    child: alreadyAddedQuantity == 1
                                        ? Icon(
                                            Icons.delete_outline,
                                            size: iconSize ?? 24,
                                            color: context.colors.iconBrand,
                                          )
                                        : Icon(
                                            Icons.remove,
                                            size: iconSize ?? 24,
                                            color: context.colors.iconBrand,
                                          ),
                                  ),
                                  CustomText(
                                    alreadyAddedQuantity.toString(),
                                    color: context.colors.textBrand,
                                    fontSize: countFontSize ?? 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  CustomInkWellContainer(
                                    onTap: () {
                                      if (alreadyAddedQuantity <
                                          maximumAllowedQuantity) {
                                        final cartSettings = context
                                            .read<SystemSettingCubit>()
                                            .cartSettings;
                                        final restrictionError = context
                                            .read<CartCubit>()
                                            .checkCartRestrictions(
                                              providerId: providerId,
                                              maxItemsPerProvider:
                                                  cartSettings
                                                      ?.maxItemsPerProvider ??
                                                  5,
                                              maxCartsPerUser:
                                                  cartSettings
                                                      ?.maxCartsPerUser ??
                                                  3,
                                            );
                                        if (restrictionError != null) {
                                          UiUtils.showMessage(
                                            context,
                                            restrictionError.translate(
                                              context: context,
                                            ),
                                            ToastificationType.warning,
                                          );
                                          return;
                                        }

                                        context
                                            .read<AddServiceIntoCartCubit>()
                                            .addServiceIntoCart(
                                              serviceId: int.parse(serviceId),
                                              quantity:
                                                  alreadyAddedQuantity + 1,
                                              serviceProviderId: providerId,
                                              serviceProviderName:
                                                  serviceProviderName,
                                              cartCubit: context
                                                  .read<CartCubit>(),
                                            );
                                      } else {
                                        UiUtils.showMessage(
                                          context,
                                          'maximumLimitReached'.translate(
                                            context: context,
                                          ),
                                          ToastificationType.warning,
                                        );
                                      }
                                    },
                                    child: Icon(
                                      Icons.add,
                                      size: iconSize ?? 24,
                                      color: context.colors.iconBrand,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (addServiceIntoCartState
                                    is AddServiceIntoCartInProgress ||
                                removeServiceFromCartState
                                    is RemoveServiceFromCartInProgress)
                              CustomShimmerLoadingContainer(
                                borderRadius: UiUtils.borderRadiusOf8,
                                height: height ?? 35,
                                width: width ?? 80,
                              ),
                          ],
                        );
                },
          ),
    );
  }
}
