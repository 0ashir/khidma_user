import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class AddToCartServicesContainer extends StatefulWidget {
  const AddToCartServicesContainer(
      {super.key, required this.services, this.isProviderAvailableAtLocation});
  final Services services;
  final String? isProviderAvailableAtLocation;

  @override
  State<AddToCartServicesContainer> createState() =>
      _AddToCartServicesContainerState();
}

class _AddToCartServicesContainerState
    extends State<AddToCartServicesContainer> {
  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      boxShadow: [
        BoxShadow(
            blurRadius: 2.0,
            offset: const Offset(1.0, 0),
            color: context.colorScheme.lightGreyColor),
      ],
      padding:
          const EdgeInsets.all(10).copyWith(bottom: Platform.isIOS ? 20 : 0),
      color: context.colorScheme.accentColor,
      height: Platform.isIOS
          ? kBottomNavigationBarHeight * 1.5
          : kBottomNavigationBarHeight * 1.2,
      width: context.screenWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                widget.services.priceWithTax!.priceFormat(context),
                color: AppColors.whiteColors,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              if (widget.services.discountedPrice != '0')
                CustomText(
                  widget.services.originalPriceWithTax!.priceFormat(context),
                  color: AppColors.whiteColors,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  showLineThrough: true,
                  underlineOrLineColor: AppColors.whiteColors,
                ),
            ],
          ),
          CustomContainer(
            height: 40,
            width: 100,
            color: AppColors.whiteColors,
            borderRadius: UiUtils.borderRadiusOf10,
            child: MultiBlocProvider(
              providers: [
                BlocProvider<AddServiceIntoCartCubit>(
                  create: (final BuildContext context) =>
                      AddServiceIntoCartCubit(CartRepository()),
                ),
                BlocProvider<RemoveServiceFromCartCubit>(
                  create: (final BuildContext context) =>
                      RemoveServiceFromCartCubit(CartRepository()),
                ),
              ],
              child: BlocConsumer<CartCubit, CartState>(
                listener: (final BuildContext context, final CartState state) {
                  if (state is CartFetchSuccess) {
                    try {
                      UiUtils.getVibrationEffect();
                    } catch (_) {}
                  }
                },
                builder: (final BuildContext context, final CartState state) =>
                    AddButton(
                  addButtonWithIcon: true,
                  height: 40,
                  width: double.infinity,
                  serviceId: widget.services.id!,
                  isProviderAvailableAtLocation:
                      widget.isProviderAvailableAtLocation,
                  maximumAllowedQuantity:
                      int.parse(widget.services.maxQuantityAllowed!),
                  alreadyAddedQuantity:
                      widget.isProviderAvailableAtLocation == "0"
                          ? 0
                          : int.parse(
                              context.read<CartCubit>().getServiceCartQuantity(
                                    serviceId: widget.services.id!,
                                  ),
                            ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
