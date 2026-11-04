import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/cubits/cart/removeCartCubit.dart';
import 'package:e_demand/ui/widgets/bottomsheets/layouts/removeAllProvidersBottomSheet.dart';
import 'package:flutter/material.dart';

/// Lists every provider cart (shown when the cart bar's "View Cart" is
/// tapped while more than one provider is in the cart) — Figma node
/// 6305:28596 ("Sort by" / "Your Cart").
class CartListBottomSheet extends StatefulWidget {
  const CartListBottomSheet({super.key});

  @override
  State<CartListBottomSheet> createState() => _CartListBottomSheetState();
}

class _CartListBottomSheetState extends State<CartListBottomSheet> {
  final RemoveCartCubit _removeCartCubit = RemoveCartCubit();
  String? _loadingProviderId;
  bool _clearingAll = false;

  @override
  void dispose() {
    _removeCartCubit.close();
    super.dispose();
  }

  List<Cart> _cartRows(final Cart primary) =>
      [primary, ...?primary.otherCarts]
          .where(
            (c) =>
                (c.providerId?.isNotEmpty ?? false) &&
                (c.cartDetails?.isNotEmpty ?? false),
          )
          .toList()
        ..sort(
          (a, b) => (int.tryParse(a.carId ?? '0') ?? 0).compareTo(
            int.tryParse(b.carId ?? '0') ?? 0,
          ),
        );

  Future<void> _removeProviderCart(final String providerId) async {
    setState(() => _loadingProviderId = providerId);
    await _removeCartCubit.removeCart(providerId: providerId, clearAll: false);
    final result = _removeCartCubit.state;
    if (result is RemoveCartSuccess) {
      final newCart = result.cartDetails;
      final hasValidCart =
          newCart != null &&
          (newCart.carId?.isNotEmpty ?? false) &&
          (int.tryParse(newCart.totalQuantity ?? '0') ?? 0) > 0;
      if (hasValidCart) {
        context.read<CartCubit>().updateCartDetails(newCart);
      } else {
        context.read<CartCubit>().clearCartCubit();
      }
    }
    if (mounted) {
      setState(() => _loadingProviderId = null);
    }
  }

  void _openCheckout(final Cart row) {
    Navigator.of(context).pop({
      "providerName": row.translatedProviderName ?? '',
      "providerId": row.providerId ?? "0",
      "companyName": row.translatedCompanyName ?? '',
      "providerAdvanceBookingDays": row.advanceBookingDays,
      "cartId": row.carId ?? '',
    });
  }

  Future<void> _confirmAndClearAll(final List<Cart> rows) async {
    final confirmed = await UiUtils.showBottomSheet(
      context: context,
      enableDrag: true,
      child: const RemoveAllProvidersBottomSheet(),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _clearingAll = true);
    // Backend now supports clearing every provider cart in one call via
    // clear_all=1 — no need to loop removeCart per provider anymore.
    await _removeCartCubit.removeCart(
      providerId: rows.first.providerId ?? "0",
      clearAll: true,
    );
    if (!mounted) return;
    await context.read<CartCubit>().getCartDetails(isReorderCart: false);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(final BuildContext context) => SafeArea(
    bottom: true,
    child: BlocConsumer<CartCubit, CartState>(
      listener: (context, state) {
        final rows = state is CartFetchSuccess
            ? _cartRows(state.cartData)
            : <Cart>[];
        if (rows.isEmpty && (ModalRoute.of(context)?.isCurrent ?? false)) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        if (state is! CartFetchSuccess) {
          return const CustomSizedBox();
        }
        final rows = _cartRows(state.cartData);
        if (rows.isEmpty) {
          return const CustomSizedBox();
        }

        return CustomContainer(
          width: context.screenWidth,
          color: context.colors.component.bottomSheetBackground,
          borderRadiusStyle: BorderRadius.only(
            topLeft: Radius.circular(16.rf(context)),
            topRight: Radius.circular(16.rf(context)),
          ),
          padding: EdgeInsetsDirectional.fromSTEB(
            16.rw(context),
            16.rh(context),
            16.rw(context),
            32.rh(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 8,
                  decoration: BoxDecoration(
                    color: context.colors.backgroundTertiary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              SizedBox(height: 8.rh(context)),
              Row(
                children: [
                  Expanded(
                    child: CustomText(
                      "${"yourCart".translate(context: context)} (${rows.length} ${(rows.length > 1 ? "providers" : "provider").translate(context: context)})",
                      color: context.colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      maxLines: 1,
                    ),
                  ),
                  CustomInkWellContainer(
                    onTap: _clearingAll
                        ? null
                        : () => _confirmAndClearAll(rows),
                    child: _clearingAll
                        ? CustomCircularProgressIndicator(
                            widthAndHeight: 16.rf(context),
                          )
                        : CustomText(
                            'clearAll'.translate(context: context),
                            color: context.colors.textBrand,
                            fontSize: 14,
                            showUnderline: true,
                            underlineOrLineColor: context.colors.textBrand,
                          ),
                  ),
                ],
              ),
              SizedBox(height: 16.rh(context)),
              Divider(height: 1, color: context.colors.borderDefault),
              SizedBox(height: 16.rh(context)),
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) ...[
                  SizedBox(height: 16.rh(context)),
                  Divider(height: 1, color: context.colors.borderDefault),
                  SizedBox(height: 16.rh(context)),
                ],
                _ProviderCartRow(
                  cart: rows[i],
                  image: rows[i].providerImage,
                  isLoading: _loadingProviderId == rows[i].providerId,
                  onView: () => _openCheckout(rows[i]),
                  onRemove: () =>
                      _removeProviderCart(rows[i].providerId ?? "0"),
                ),
              ],
            ],
          ),
        );
      },
    ),
  );
}

class _ProviderCartRow extends StatelessWidget {
  const _ProviderCartRow({
    required this.cart,
    required this.image,
    required this.isLoading,
    required this.onView,
    required this.onRemove,
  });

  final Cart cart;
  final String? image;
  final bool isLoading;
  final VoidCallback onView;
  final VoidCallback onRemove;

  @override
  Widget build(final BuildContext context) {
    final qty = int.tryParse(cart.totalQuantity ?? '0') ?? 0;

    return Row(
      children: [
        ClipOval(
          child: (image != null && image!.isNotEmpty)
              ? CustomCachedNetworkImage(
                  networkImageUrl: image!,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  defaultColourFilter: false,
                  avoideResponsive: true,
                )
              : CustomContainer(
                  width: 36,
                  height: 36,
                  color: context.colors.backgroundTertiary,
                ),
        ),
        SizedBox(width: 8.rw(context)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: CustomText(
                      cart.translatedCompanyName ??
                          cart.translatedProviderName ??
                          '',
                      color: context.colors.component.cardMainText,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      maxLines: 1,
                    ),
                  ),
                  if (cart.isProviderVerified == true) ...[
                    SizedBox(width: 4.rw(context)),
                    CustomSvgPicture(
                      avoideResponsive: true,
                      svgImage: AppAssets.verified,
                      height: 16,
                      width: 16,
                      color: context.colors.iconBrand,
                    ),
                  ],
                ],
              ),
              SizedBox(height: 4.rh(context)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    "$qty ${(qty > 1 ? "services" : "service").translate(context: context)}",
                    color: context.colors.component.cardSecondaryText,
                    fontSize: 12,
                  ),
                  SizedBox(width: 4.rw(context)),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.colors.component.cardSecondaryText,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4.rw(context)),
                  CustomText(
                    (cart.subTotal ?? '0').countryPriceFormat(context),
                    color: context.colors.component.cardSecondaryText,
                    fontSize: 12,
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: 8.rw(context)),
        CustomInkWellContainer(
          borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
          onTap: isLoading ? null : onView,
          child: CustomContainer(
            padding: EdgeInsetsDirectional.symmetric(
              vertical: 8.rh(context),
              horizontal: 12.rw(context),
            ),
            borderRadius: UiUtils.borderRadiusOf12,
            color: context.colors.component.buttonPrimaryBg,
            child: CustomText(
              'view'.translate(context: context),
              color: context.colors.component.buttonPrimaryText,
              fontSize: 14,
            ),
          ),
        ),
        SizedBox(width: 8.rw(context)),
        CustomInkWellContainer(
          borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf50),
          onTap: isLoading ? null : onRemove,
          child: CustomContainer(
            padding: EdgeInsets.all(8.rf(context)),
            borderRadius: UiUtils.borderRadiusOf50,
            color: context.colors.backgroundSecondary,
            child: SizedBox(
              width: 20,
              height: 20,
              child: isLoading
                  ? const Center(
                      child: CustomCircularProgressIndicator(
                        widthAndHeight: 14,
                      ),
                    )
                  : Icon(
                      Icons.close,
                      color: context.colors.iconSecondary,
                      size: 20,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
