import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PromoCodeScreen extends StatefulWidget {
  const PromoCodeScreen({
    required this.providerID,
    super.key,
    required this.isAtStoreOptionSelected,
    required this.isFrom,
  });

  final String providerID;
  final String isFrom;
  final String isAtStoreOptionSelected;

  static Route route(final RouteSettings routeSettings) {
    final Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (final _) => MultiBlocProvider(
        providers: [
          BlocProvider<ValidatePromocodeCubit>(
            create: (final context) =>
                ValidatePromocodeCubit(cartRepository: CartRepository()),
          ),
        ],
        child: PromoCodeScreen(
          isFrom: arguments["isFrom"],
          providerID: arguments['providerID'],
          isAtStoreOptionSelected: arguments['isAtStoreOptionSelected'],
        ),
      ),
    );
  }

  @override
  State<PromoCodeScreen> createState() => _PromoCodeScreenState();
}

class _PromoCodeScreenState extends State<PromoCodeScreen> {
  final TextEditingController _promoCodeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool get _isTablet => ResponsiveHelper.isTabletDevice(context);

  // The grid supplies row spacing on tablet, so cards only need their own
  // bottom margin in the single-column phone list.
  EdgeInsets get _cardMargin =>
      _isTablet ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12);

  // Tablet shows the cards in 2 columns; phone keeps a single column.
  Widget _buildCardList(final List<Widget> cards) => _isTablet
      ? Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: EqualHeightGrid(children: cards),
        )
      : Column(children: cards);

  void fetchPromoCodes() {
    context.read<GetAllPromocodesCubit>().getAllPromocodes(
      providerIdOrSlug: widget.providerID,
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<GetAllPromocodesCubit>().fetchMore();
    }
  }

  @override
  void initState() {
    fetchPromoCodes();
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }

  void _validatePromoCode(final Promocode promoCodeDetails) {
    context.read<ValidatePromocodeCubit>().validatePromoCodes(
      totalAmount: context.read<CartCubit>().getCartSubTotalAmount(
        isFrom: widget.isFrom,
        isAtStoreBooked: widget.isAtStoreOptionSelected == "1",
      ),
      promoCodeID: promoCodeDetails.id!,
      providerId: widget.providerID,
    );
  }

  void _applyTypedPromoCode() {
    UiUtils.removeFocus();
    final String typedCode = _promoCodeController.text.trim();
    if (typedCode.isEmpty) {
      return;
    }
    final GetAllPromocodesState state = context
        .read<GetAllPromocodesCubit>()
        .state;
    if (state is! GetAllPromocodesFetchSuccess) {
      return;
    }
    Promocode? matchedPromocode;
    for (final promo in state.promocodeList) {
      if ((promo.promoCode ?? '').toLowerCase() == typedCode.toLowerCase()) {
        matchedPromocode = promo;
        break;
      }
    }
    if (matchedPromocode == null) {
      UiUtils.showMessage(
        context,
        'invalidPromoCode'.translate(context: context),
        ToastificationType.error,
      );
      return;
    }
    _validatePromoCode(matchedPromocode);
  }

  Widget _buildPromoCodeInputRow() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
    child: Row(
      children: [
        Expanded(
          child: CustomContainer(
            height: 48,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: context.colors.surfacePrimary,
            borderRadius: UiUtils.borderRadiusOf12,
            child: TextField(
              controller: _promoCodeController,
              textInputAction: TextInputAction.done,
              onSubmitted: (final _) => _applyTypedPromoCode(),
              style: TextStyle(fontSize: 14, color: context.colors.textPrimary),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'enterPromoCode'.translate(context: context),
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: context.colors.textTertiary,
                ),
              ),
            ),
          ),
        ),
        const CustomSizedBox(width: 8),
        CustomInkWellContainer(
          borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf8),
          onTap: _applyTypedPromoCode,
          child: CustomContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: context.colors.backgroundBrand,
            borderRadius: UiUtils.borderRadiusOf8,
            child: CustomText(
              'apply'.translate(context: context),
              fontSize: 14,
              color: context.colors.textInverseLight,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildBulletPoint(final String message) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.textSecondary,
            ),
          ),
        ),
        const CustomSizedBox(width: 8),
        Expanded(
          child: CustomText(
            message,
            fontSize: 12,
            color: context.colors.textSecondary,
          ),
        ),
      ],
    ),
  );

  Widget _buildApplyButton(
    final Promocode promoCodeDetails,
  ) => BlocConsumer<ValidatePromocodeCubit, ValidatePromoCodeState>(
    listener:
        (final BuildContext context, final ValidatePromoCodeState state) async {
          if (state is ValidatePromoCodeSuccess) {
            if (!state.error) {
              //we have created validate promocode instance for each promocode
              //so listener will call for each instance and we have pop it only one time
              //so in this condition it will pop only one time
              if (state.promoCodeId == promoCodeDetails.id) {
                UiUtils.showMessage(
                  context,
                  'promoCodeAppliedSuccessfully'.translate(context: context),
                  ToastificationType.success,
                );

                await Future.delayed(const Duration(milliseconds: 500)).then((
                  final value,
                ) {
                  if (!context.mounted) return;
                  Navigator.of(context).pop({
                    "discount": state.discountAmount,
                    "appliedPromocode": promoCodeDetails,
                  });
                });
              }
            } else {
              if (state.promoCodeId == promoCodeDetails.id) {
                UiUtils.showMessage(
                  context,
                  state.message,
                  ToastificationType.error,
                );
              }
            }
          } else if (state is ValidatePromoCodeFailure) {
            UiUtils.showMessage(
              context,
              state.errorMessage,
              ToastificationType.error,
            );
          }
        },
    builder: (final BuildContext context, final ValidatePromoCodeState state) {
      if (state is ValidatePromoCodeInProgress &&
          state.promoCodeID == promoCodeDetails.id) {
        return CustomContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: context.colors.backgroundBrand,
          borderRadius: UiUtils.borderRadiusOf8,
          child: CustomSizedBox(
            height: 16,
            width: 16,
            child: CustomCircularProgressIndicator(
              color: context.colors.textInverseLight,
            ),
          ),
        );
      }
      if (state is ValidatePromoCodeSuccess &&
          !state.error &&
          state.promoCodeId == promoCodeDetails.id) {
        return CustomContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: context.colors.backgroundBrandSubtle,
          borderRadius: UiUtils.borderRadiusOf8,
          child: CustomText(
            'applied'.translate(context: context),
            fontSize: 14,
            color: context.colors.textBrand,
          ),
        );
      }
      return CustomInkWellContainer(
        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf8),
        onTap: state is ValidatePromoCodeInProgress
            ? null
            : () => _validatePromoCode(promoCodeDetails),
        child: CustomContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: context.colors.backgroundBrand,
          borderRadius: UiUtils.borderRadiusOf8,
          child: CustomText(
            'apply'.translate(context: context),
            fontSize: 14,
            color: context.colors.textInverseLight,
          ),
        ),
      );
    },
  );

  Widget _buildOfferCard({required final Promocode promoCodeDetails}) {
    final String currency = context.read<SystemSettingCubit>().systemCurrency;
    final String discountLabel =
        '${promoCodeDetails.discount ?? ''}'
        '${promoCodeDetails.discountType == "percentage" ? '%' : ' $currency'} '
        '${'off'.translate(context: context)}';

    final bool hasRepeatUsage =
        (int.tryParse(promoCodeDetails.noOfRepeatUsage ?? '1') ?? 1) > 1;

    final List<String> bulletPoints = [
      if ((promoCodeDetails.message ?? '').isNotEmpty)
        promoCodeDetails.message!,
      "${'offerIsApplicableOnMinimumValueOf'.translate(context: context)} "
          "${(promoCodeDetails.minimumOrderAmount ?? '0').priceFormat(context)}",
      "${'maximumInstantDiscountOf'.translate(context: context)} "
          "${(promoCodeDetails.maxDiscountAmount ?? '0').priceFormat(context)}",
      "${'offerValidFrom'.translate(context: context)} "
          "${promoCodeDetails.startDate.toString().formatDate()} "
          "${'to'.translate(context: context)} "
          "${promoCodeDetails.endDate.toString().formatDate()}",
      if (hasRepeatUsage)
        "${'applicableMaximum'.translate(context: context)} "
            "${promoCodeDetails.noOfRepeatUsage} "
            "${'timesDuringCampaignPeriod'.translate(context: context)}"
      else
        'offerValidOncePerCustomerDuringCampaignPeriod'.translate(
          context: context,
        ),
    ];

    return CustomContainer(
      margin: _cardMargin,
      padding: const EdgeInsets.all(12),
      color: context.colors.surfacePrimary,
      borderRadius: UiUtils.borderRadiusOf12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CustomCachedNetworkImage(
                  networkImageUrl: promoCodeDetails.image ?? '',
                  height: 48,
                  width: 48,
                  fit: BoxFit.cover,
                ),
              ),
              const CustomSizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(
                      promoCodeDetails.promoCode ?? '',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      maxLines: 1,
                      color: context.colors.textPrimary,
                    ),
                    const CustomSizedBox(height: 4),
                    CustomContainer(
                      padding: const EdgeInsets.all(4),
                      color: context.colors.backgroundBrandSubtle,
                      borderRadius: 4,
                      child: CustomText(
                        discountLabel,
                        fontSize: 11,
                        color: context.colors.textBrand,
                      ),
                    ),
                  ],
                ),
              ),
              const CustomSizedBox(width: 8),
              _buildApplyButton(promoCodeDetails),
            ],
          ),
          const CustomSizedBox(height: 12),
          Divider(height: 1, color: context.colors.borderDefault),
          const CustomSizedBox(height: 12),
          ...bulletPoints.map(_buildBulletPoint),
        ],
      ),
    );
  }

  Widget promoCodeLoadingShimmer() => _buildCardList(
    List.generate(
      UiUtils.numberOfShimmerContainer,
      (final int index) => CustomContainer(
        margin: _cardMargin,
        padding: const EdgeInsets.all(12),
        color: context.colors.surfacePrimary,
        borderRadius: UiUtils.borderRadiusOf12,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: const CustomShimmerLoadingContainer(height: 48, width: 48),
            ),
            const CustomSizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomShimmerLoadingContainer(
                    height: 10,
                    width: context.screenWidth * 0.3,
                  ),
                  const CustomSizedBox(height: 10),
                  CustomShimmerLoadingContainer(
                    height: 10,
                    width: context.screenWidth * 0.2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(final BuildContext context) => AnnotatedSafeArea(
    isAnnotated: true,
    applyBottomInset: false,
    child: Scaffold(
      backgroundColor: context.colors.backgroundSecondary,
      appBar: UiUtils.getSimpleAppBar(
        context: context,
        title: 'offerAndCoupons'.translate(context: context),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPromoCodeInputRow(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BlocBuilder<GetAllPromocodesCubit, GetAllPromocodesState>(
                builder:
                    (
                      final BuildContext context,
                      final GetAllPromocodesState state,
                    ) {
                      if (state is GetAllPromocodesFetchFailure) {
                        return ErrorContainer(
                          errorMessage: state.errorMessage.translate(
                            context: context,
                          ),
                          onTapRetry: () {
                            fetchPromoCodes();
                          },
                        );
                      }
                      if (state is GetAllPromocodesFetchSuccess) {
                        return state.promocodeList.isEmpty
                            ? Center(
                                child: NoDataFoundWidget(
                                  titleKey: 'noPromoCodeAvailable'.translate(
                                    context: context,
                                  ),
                                  subtitleKey: 'noPromoCodeAvailableSubTitle'
                                      .translate(context: context),
                                ),
                              )
                            : Column(
                                children: [
                                  _buildCardList(
                                    List.generate(
                                      state.promocodeList.length,
                                      (final int index) => _buildOfferCard(
                                        promoCodeDetails:
                                            state.promocodeList[index],
                                      ),
                                    ),
                                  ),
                                  if (state.isLoadingMore)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      child: Center(
                                        child:
                                            CustomCircularProgressIndicator(),
                                      ),
                                    ),
                                ],
                              );
                      }
                      return promoCodeLoadingShimmer();
                    },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
