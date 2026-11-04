import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/cubits/cart/removeCartCubit.dart';
import 'package:e_demand/ui/widgets/bottomsheets/layouts/cartListBottomSheet.dart';
import 'package:e_demand/ui/widgets/bottomsheets/layouts/removeAllProvidersBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shader_snap/flutter_shader_snap.dart';

class CartSubDetailsContainer extends StatefulWidget {
  const CartSubDetailsContainer({final Key? key, this.providerID})
    : super(key: key);
  final String? providerID;

  @override
  State<CartSubDetailsContainer> createState() =>
      _CartSubDetailsContainerState();
}

class _CartSubDetailsContainerState extends State<CartSubDetailsContainer>
    with TickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        context.read<CartCubit>().clearCartCubit();
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Up to 3 provider avatars for the overlapping avatar stack — a provider
  // can have multiple services in cart, so a per-item thumbnail can't stand
  // in for it; provider_image is the real per-provider avatar. Sorted by
  // cart_id (assigned once, never changes) rather than trusting which entry
  // the backend/response currently calls "primary" — that reorders itself
  // whenever any provider's qty changes, which visibly shuffled the avatars.
  List<String> _avatarImages(final Cart primary) {
    final carts = [primary, ...?primary.otherCarts]
      ..sort(
        (a, b) => (int.tryParse(a.carId ?? '0') ?? 0).compareTo(
          int.tryParse(b.carId ?? '0') ?? 0,
        ),
      );
    final images = <String>[];
    for (final cart in carts) {
      final image = cart.providerImage;
      if (image != null && image.isNotEmpty) {
        images.add(image);
      }
      if (images.length == 3) break;
    }
    return images;
  }

  void _openCheckout(final BuildContext context, final Map row) {
    context.read<GetAllPromocodesCubit>().getAllPromocodes(
      providerIdOrSlug: row["providerId"] ?? "0",
    );
    // [context] is the cart row's context; that row is gone once the booking
    // empties the cart, so resolve the cubit now instead of after the pop.
    final CartCubit cartCubit = context.read<CartCubit>();
    Navigator.pushNamed(
      context,
      scheduleScreenRoute,
      arguments: {
        "isFrom": "cart",
        "providerName": row["providerName"] ?? '',
        "providerId": row["providerId"] ?? "0",
        "companyName": row["companyName"] ?? '',
        "providerAdvanceBookingDays": row["providerAdvanceBookingDays"],
        "cartId": row["cartId"] ?? '',
      },
    ).then((final _) {
      if (mounted && !cartCubit.isClosed) {
        cartCubit.getCartDetails(isReorderCart: false);
      }
    });
  }

  Future<void> _confirmAndRemove(
    final BuildContext context, {
    required final String providerId,
    required final bool clearAll,
  }) async {
    final confirmed = await UiUtils.showBottomSheet(
      context: context,
      enableDrag: true,
      child: const RemoveAllProvidersBottomSheet(),
    );
    if (confirmed != true || !mounted) return;

    context.read<RemoveCartCubit>().removeCart(
      providerId: providerId,
      clearAll: clearAll,
    );
  }

  @override
  Widget build(final BuildContext context) => AnimationFromBottomSide(
    delay: 250,
    child: SnapShader(
      snapShaderType: SnapShaderType.smoke,
      controller: _controller,
      child: BlocBuilder<SystemSettingCubit, SystemSettingState>(
        builder: (context, systemState) {
          // Don't show cart data until system settings are successfully fetched
          if (systemState is! SystemSettingFetchSuccess) {
            return const CustomSizedBox();
          }

          return BlocBuilder<CartCubit, CartState>(
            builder: (BuildContext context, final CartState state) {
              if (state is! CartFetchSuccess) {
                return const CustomSizedBox();
              }

              final cartData = state.cartData;
              final totalQty = int.tryParse(cartData.totalQuantity ?? '0') ?? 0;
              if (totalQty == 0 ||
                  cartData.cartDetails == null ||
                  cartData.cartDetails!.isEmpty) {
                return const CustomSizedBox();
              }

              // Prefer the API's aggregate totals (from the latest get_cart
              // fetch); fall back to summing cartData + otherCarts, since
              // add/remove responses don't carry the aggregate fields yet.
              final providerCount = context
                  .read<CartCubit>()
                  .getProviderCartsCount();

              final allCarts = [cartData, ...?cartData.otherCarts];
              final serviceCount =
                  int.tryParse(cartData.totalServiceCount ?? '') ??
                  allCarts.fold<int>(
                    0,
                    (sum, c) =>
                        sum + (int.tryParse(c.totalQuantity ?? '0') ?? 0),
                  );
              final overallAmount =
                  (cartData.totalOverallAmount?.isNotEmpty ?? false)
                  ? cartData.totalOverallAmount!
                  : allCarts
                        .fold<double>(
                          0,
                          (sum, c) =>
                              sum +
                              (double.tryParse(c.overallAmount ?? '0') ?? 0),
                        )
                        .toString();

              final avatarImages = _avatarImages(cartData);

              return BlocProvider(
                create: (context) => RemoveCartCubit(),
                child: Builder(
                  builder: (context) => BlocConsumer<RemoveCartCubit, RemoveCartState>(
                    listener: (context, removeCartState) {
                      if (removeCartState is RemoveCartSuccess) {
                        final newCart = removeCartState.cartDetails;
                        final hasValidCart =
                            newCart != null &&
                            (newCart.carId?.isNotEmpty ?? false) &&
                            (int.tryParse(newCart.totalQuantity ?? '0') ?? 0) >
                                0;
                        if (hasValidCart) {
                          // Other provider's cart exists: switch to it
                          // directly without the disappear animation (which
                          // would clear the cart after).
                          context.read<CartCubit>().updateCartDetails(newCart);
                        } else {
                          // No more carts: play the disappear animation —
                          // its statusListener calls clearCartCubit().
                          _controller.forward();
                        }
                      }
                    },
                    builder: (context, removeCartState) {
                      final bool isRemoving =
                          removeCartState is RemoveCartInProgress;

                      return ClipShadowBottom(
                        child: CustomContainer(
                          padding: EdgeInsets.all(16.rf(context)).copyWith(
                            bottom:
                                16.rf(context) +
                                MediaQuery.viewPaddingOf(context).bottom,
                          ),
                          color: context.colors.component.cardBackground,
                          borderRadiusStyle: BorderRadius.only(
                            topLeft: Radius.circular(16.rf(context)),
                            topRight: Radius.circular(16.rf(context)),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: context.colors.component.cardShadow,
                              blurRadius: 8,
                              offset: const Offset(0, -2),
                            ),
                          ],
                          width: context.screenWidth,
                          child: Row(
                            children: [
                              if (avatarImages.isNotEmpty) ...[
                                _AvatarStack(imageUrls: avatarImages),
                                SizedBox(width: 16.rw(context)),
                              ],
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CustomText(
                                      "$serviceCount ${(serviceCount > 1 ? "services" : "service").translate(context: context)} ${"inCart".translate(context: context)}",
                                      color: context.colors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      maxLines: 1,
                                    ),
                                    SizedBox(height: 4.rh(context)),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: CustomText(
                                            "$providerCount ${(providerCount > 1 ? "providers" : "provider").translate(context: context)}",
                                            color: context
                                                .colors
                                                .component
                                                .cardSecondaryText,
                                            fontSize: 12,
                                            maxLines: 1,
                                          ),
                                        ),
                                        SizedBox(width: 4.rw(context)),
                                        Container(
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: context
                                                .colors
                                                .component
                                                .cardSecondaryText,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: 4.rw(context)),
                                        Flexible(
                                          child: CustomText(
                                            overallAmount.countryPriceFormat(
                                              context,
                                            ),
                                            color: context
                                                .colors
                                                .component
                                                .cardSecondaryText,
                                            fontSize: 12,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16.rw(context)),
                              CustomInkWellContainer(
                                borderRadius: BorderRadius.circular(
                                  UiUtils.borderRadiusOf12,
                                ),
                                onTap: () {
                                  if (providerCount > 1) {
                                    UiUtils.showBottomSheet(
                                      context: context,
                                      enableDrag: true,
                                      child: const CartListBottomSheet(),
                                    ).then((final value) {
                                      if (value is Map) {
                                        _openCheckout(context, value);
                                      }
                                    });
                                    return;
                                  }

                                  _openCheckout(context, {
                                    "providerName":
                                        cartData.translatedProviderName ?? '',
                                    "providerId": cartData.providerId ?? "0",
                                    "companyName":
                                        cartData.translatedCompanyName ?? '',
                                    "providerAdvanceBookingDays":
                                        cartData.advanceBookingDays,
                                    "cartId": cartData.carId ?? '',
                                  });
                                },
                                child: CustomContainer(
                                  padding: EdgeInsetsDirectional.symmetric(
                                    vertical: 8.rh(context),
                                    horizontal: 12.rw(context),
                                  ),
                                  borderRadius: UiUtils.borderRadiusOf12,
                                  color:
                                      context.colors.component.buttonPrimaryBg,
                                  child: CustomText(
                                    'viewCart'.translate(context: context),
                                    color: context
                                        .colors
                                        .component
                                        .buttonPrimaryText,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.rw(context)),
                              CustomInkWellContainer(
                                borderRadius: BorderRadius.circular(
                                  UiUtils.borderRadiusOf50,
                                ),
                                onTap: isRemoving
                                    ? null
                                    : () => _confirmAndRemove(
                                        context,
                                        providerId: cartData.providerId ?? "0",
                                        clearAll: providerCount > 1,
                                      ),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: isRemoving
                                      ? const Center(
                                          child:
                                              CustomCircularProgressIndicator(
                                                widthAndHeight: 18,
                                              ),
                                        )
                                      : CustomToolTip(
                                          toolTipMessage: 'deleteCart'
                                              .translate(context: context),
                                          child: Icon(
                                            Icons.close,
                                            color: context.colors.iconSecondary,
                                            size: 24,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    ),
  );
}

/// Overlapping circular avatars, leftmost (primary cart) drawn on top —
/// mirrors Figma's "Provider" avatar stack (56px wide for 3 x 32px circles
/// overlapped by 20px).
class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.imageUrls});
  final List<String> imageUrls;

  static const double _size = 32;
  static const double _overlap = 20;

  @override
  Widget build(final BuildContext context) => SizedBox(
    width: _size + (imageUrls.length - 1) * (_size - _overlap),
    height: _size,
    child: Stack(
      children: [
        for (var i = imageUrls.length - 1; i >= 0; i--)
          Positioned(
            left: i * (_size - _overlap),
            child: Container(
              width: _size,
              height: _size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.colors.surfacePrimary,
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: CustomCachedNetworkImage(
                  networkImageUrl: imageUrls[i],
                  width: _size,
                  height: _size,
                  fit: BoxFit.cover,
                  defaultColourFilter: false,
                  avoideResponsive: true,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
