import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  static Route route(final RouteSettings settings) => CupertinoPageRoute(
    builder: (final BuildContext context) => BlocProvider(
      create: (final context) =>
          FetchUserPaymentDetailsCubit(SystemRepository()),
      child: Builder(builder: (final context) => const PaymentsScreen()),
    ),
  );

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<String> statuses = ['all', 'success', 'failed', 'pending'];
  String? selectedStatus = "all";

  @override
  void initState() {
    super.initState();
    fetchPaymentDetails();
    _scrollController.addListener(fetchMorePaymentDetails);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void fetchMorePaymentDetails() {
    if (!context.read<FetchUserPaymentDetailsCubit>().hasMoreTransactions()) {
      return;
    }

    final nextPageTrigger = 0.7 * _scrollController.position.maxScrollExtent;

    if (_scrollController.position.pixels > nextPageTrigger) {
      if (mounted) {
        context
            .read<FetchUserPaymentDetailsCubit>()
            .fetchUsersMorePaymentDetails(status: selectedStatus);
      }
    }
  }

  void fetchPaymentDetails() {
    context.read<FetchUserPaymentDetailsCubit>().fetchUserPaymentDetails(
      status: selectedStatus == 'all' ? null : selectedStatus,
    );
  }

  void _onStatusSelected(String status) {
    setState(() {
      selectedStatus = status;
    });
    fetchPaymentDetails();
  }

  int? _countForStatus(
    final String status,
    final FetchUserPaymentDetailsState state,
  ) {
    if (state is! FetchUserPaymentDetailsSuccess) return null;
    switch (status) {
      case 'all':
        return state.allCount;
      case 'success':
        return state.successCount;
      case 'failed':
        return state.failedCount;
      case 'pending':
        return state.pendingCount;
      default:
        return null;
    }
  }

  Widget _buildQuickFilterBar() =>
      BlocBuilder<FetchUserPaymentDetailsCubit, FetchUserPaymentDetailsState>(
        builder: (context, state) => CustomContainer(
          width: double.infinity,
          color: context.colors.backgroundPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              color: context.colors.overlayHeaderShadow,
              offset: const Offset(0, 8),
            ),
          ],
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: statuses.map((status) {
                final bool isSelected = status == selectedStatus;
                final int? count = _countForStatus(status, state);
                final String label = status.translate(context: context);
                return Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: FlatOutlinedButton(
                    name: count == null ? label : '$label ($count)',
                    isSelected: isSelected,
                    onTap: () => _onStatusSelected(status),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      );

  // Tablet shows 2-column cards (12 gap); phone keeps the single column.
  Widget _buildCardList(final List<Widget> cards) =>
      ResponsiveHelper.isTabletDevice(context)
      ? EqualHeightGrid(spacing: 12, children: cards)
      : Column(spacing: 12, children: cards);

  SingleChildScrollView _buildPaymentDetailsShimmerLoading() =>
      SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildCardList(
          List.generate(
            UiUtils.numberOfShimmerContainer,
            (final int index) => CustomShimmerLoadingContainer(
              height: 220,
              width: context.screenWidth,
              borderRadius: UiUtils.borderRadiusOf12,
            ),
          ),
        ),
      );

  ({Color background, Color text}) _statusColors(final String? status) {
    switch (status) {
      case "success":
        return (
          background: context.colors.backgroundSuccessSubtle,
          text: context.colors.textSuccess,
        );
      case "failed":
        return (
          background: context.colors.backgroundErrorSubtle,
          text: context.colors.textError,
        );
      case "pending":
      default:
        return (
          background: context.colors.backgroundWarningSubtle,
          text: context.colors.textWarning,
        );
    }
  }

  Widget _buildDivider() =>
      CustomContainer(height: 1, color: context.colors.borderDefault);

  Widget _buildFieldRow(final String label, final String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomText(
        label,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: context.colors.textTertiary,
      ),
      const CustomSizedBox(height: 4),
      CustomText(
        value,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: context.colors.textPrimary,
      ),
    ],
  );

  Widget _buildTransactionCard(final Payment payment) {
    final colors = _statusColors(payment.status);

    return CustomInkWellContainer(
      borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
      onTap: () {
        if (payment.orderId?.trim().isNotEmpty ?? false) {
          Navigator.of(context).pushNamed(
            bookingDetails,
            arguments: {'bookingId': payment.orderId},
          );
        }
      },
      child: CustomContainer(
        width: double.infinity,
        color: context.colors.surfacePrimary,
        borderRadius: UiUtils.borderRadiusOf12,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        'transactionId'.translate(context: context),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: context.colors.textSecondary,
                      ),
                      const CustomSizedBox(height: 4),
                      CustomText(
                        (payment.txnId == null || payment.txnId!.isEmpty)
                            ? '-'
                            : payment.txnId!,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: context.colors.textBrand,
                      ),
                    ],
                  ),
                ),
                const CustomSizedBox(width: 8),
                CustomContainer(
                  color: colors.background,
                  borderRadius: UiUtils.borderRadiusOf8,
                  padding: const EdgeInsets.all(8),
                  child: CustomText(
                    (payment.translatedStatus ?? '').capitalize(),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colors.text,
                  ),
                ),
              ],
            ),
            const CustomSizedBox(height: 12),
            _buildDivider(),
            const CustomSizedBox(height: 12),
            _buildFieldRow(
              'bookingId'.translate(context: context),
              payment.orderId ?? '-',
            ),
            const CustomSizedBox(height: 12),
            if ((payment.transactionDate ?? '').isNotEmpty) ...[
              _buildFieldRow(
                'date'.translate(context: context),
                payment.transactionDate!.formatDateAndTime(),
              ),
              const CustomSizedBox(height: 12),
            ],
            _buildFieldRow(
              'paymentMode'.translate(context: context),
              (payment.type ?? '').capitalize(),
            ),
            const CustomSizedBox(height: 12),
            _buildDivider(),
            const CustomSizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  'amount'.translate(context: context),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textPrimary,
                ),
                CustomText(
                  payment.status == 'failed'
                      ? '- ${(payment.amount ?? '0').priceFormat(context, currencySymbol: payment.currencySymbol, decimalPlaces: payment.currencyDecimalPlaces)}'
                      : (payment.amount ?? '0').priceFormat(
                          context,
                          currencySymbol: payment.currencySymbol,
                          decimalPlaces: payment.currencyDecimalPlaces,
                        ),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textPrimary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) => AnnotatedSafeArea(
    isAnnotated: true,
    applyBottomInset: false,
    child: Scaffold(
      backgroundColor: context.colors.backgroundSecondary,
      appBar: UiUtils.getSimpleAppBar(
        context: context,
        title: 'payment'.translate(context: context),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(68.rh(context)),
          child: _buildQuickFilterBar(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                BlocBuilder<
                  FetchUserPaymentDetailsCubit,
                  FetchUserPaymentDetailsState
                >(
                  builder:
                      (
                        final BuildContext context,
                        final FetchUserPaymentDetailsState state,
                      ) {
                        if (state is FetchUserPaymentDetailsFailure) {
                          return ErrorContainer(
                            errorMessage: state.errorMessage,
                            onTapRetry: () {
                              fetchPaymentDetails();
                            },
                          );
                        }
                        if (state is FetchUserPaymentDetailsSuccess) {
                          if (state.paymentDetails.isEmpty) {
                            return Center(
                              child: NoDataFoundWidget(
                                titleKey: 'noPaymentDetailsFound'.translate(
                                  context: context,
                                ),
                                subtitleKey: 'noPaymentDetailsFoundSubTitle'
                                    .translate(context: context),
                              ),
                            );
                          }
                          return CustomRefreshIndicator(
                            displacment: 12,
                            onRefreshCallback: () {
                              fetchPaymentDetails();
                            },
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16).copyWith(
                                bottom:
                                    16 +
                                    MediaQuery.viewPaddingOf(context).bottom,
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                      bottom: 12,
                                    ),
                                    child: _buildCardList(
                                      state.paymentDetails
                                          .map(_buildTransactionCard)
                                          .toList(),
                                    ),
                                  ),
                                  if (state.isLoadingMorePayments ||
                                      state.isLoadingMoreError) ...[
                                    CustomLoadingMoreContainer(
                                      isError: state.isLoadingMoreError,
                                      onErrorButtonPressed: () {
                                        fetchMorePaymentDetails();
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }
                        return _buildPaymentDetailsShimmerLoading();
                      },
                ),
          ),
        ],
      ),
    ),
  );
}
