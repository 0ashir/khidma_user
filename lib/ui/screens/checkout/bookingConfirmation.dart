import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OrderConfirm extends StatefulWidget {
  const OrderConfirm({
    required this.isSuccess,
    required this.orderId,
    this.isPending = false,
    this.isFromAdditionalCharge,
    this.paymentGatewayName,
    this.transactionId,
    this.isReorder,
    this.customJobRequestId,
    super.key,
  });

  final bool isSuccess;
  final bool isPending;
  final String orderId;
  final bool? isFromAdditionalCharge;
  final String? paymentGatewayName;
  final String? transactionId;
  final String? isReorder;
  final String? customJobRequestId;

  static Route route(final RouteSettings routeSettings) {
    final Map arguments = routeSettings.arguments as Map;

    return CupertinoPageRoute(
      builder: (final _) => BlocProvider<AddTransactionCubit>(
        create: (final BuildContext context) =>
            AddTransactionCubit(bookingRepository: BookingRepository()),
        child: OrderConfirm(
          isSuccess: arguments["isSuccess"],
          isPending: arguments["isPending"] ?? false,
          orderId: arguments["orderId"],
          isFromAdditionalCharge: arguments["isFromAdditionalCharge"],
          paymentGatewayName: arguments["paymentGatewayName"],
          transactionId: arguments["transactionId"],
          isReorder: arguments['isReBooking'],
          customJobRequestId: arguments['customJobRequestId'],
        ),
      ),
    );
  }

  @override
  State<OrderConfirm> createState() => _OrderConfirmState();
}

class _OrderConfirmState extends State<OrderConfirm> {
  @override
  void initState() {
    super.initState();
    callAPIs();
  }

  Future<void> callAPIs() async {
    Future.delayed(Duration.zero).then((final value) async {
      if (!mounted) return;
      await context.read<AddTransactionCubit>().addTransaction(
        status: widget.isSuccess
            ? "success"
            : widget.isPending
            ? "pending"
            : "cancelled",
        orderID: widget.orderId,
        isAdditionalCharge: (widget.isFromAdditionalCharge ?? false) ? '1' : '',
        paymentGatewayName: widget.paymentGatewayName ?? '',
        transactionId: widget.transactionId ?? '',
        isReorder: widget.isReorder,
      );

      // Track additional charge approval if successful
      if (widget.isFromAdditionalCharge == true && widget.isSuccess) {
        ClarityService.logAction(
          ClarityActions.bookingAdditionalChargeApproved,
          {
            'order_id': widget.orderId,
            'payment_method': widget.paymentGatewayName ?? '',
            'transaction_id': widget.transactionId ?? '',
          },
        );
      }

      if (!mounted) return;
      UiUtils.bookingScreenGlobalKey.currentState?.fetchBookingDetails();
      context.read<CartCubit>().getCartDetails(isReorderCart: false);
      context.read<MyRequestListCubit>().fetchRequests();
    });
  }

  Widget _buildSuccessBody(final BuildContext context) => Column(
    children: [
      Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  "assets/animation/success.json",
                  height: 124,
                  width: 124,
                ),
                const CustomSizedBox(height: 16),
                CustomText(
                  'bookedSuccessfully'.translate(context: context),
                  textAlign: TextAlign.center,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
                const CustomSizedBox(height: 8),
                CustomText(
                  (widget.isFromAdditionalCharge == true
                          ? 'additionalChargesSuccessMessage'
                          : 'bookingSuccessMessage')
                      .translate(context: context),
                  textAlign: TextAlign.center,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: context.colors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomRoundedButton(
              widthPercentage: 1,
              height: 48,
              radius: UiUtils.borderRadiusOf12,
              backgroundColor: context.colors.backgroundBrand,
              titleColor: context.colors.textInverseLight,
              buttonTitle: 'viewBooking'.translate(context: context),
              showBorder: false,
              textSize: 16,
              fontWeight: FontWeight.w500,
              onTap: () {
                Navigator.of(
                  context,
                ).popUntil((final Route route) => route.isFirst);
                if (widget.customJobRequestId != null) {
                  Navigator.of(context).pushNamed(
                    myRequestDetailsScreen,
                    arguments: {
                      'customJobRequestId': widget.customJobRequestId,
                      'status': 'booked',
                      'bookingId': widget.orderId,
                    },
                  );
                } else {
                  Navigator.of(context).pushNamed(
                    bookingDetails,
                    arguments: {'bookingId': widget.orderId},
                  );
                }
              },
            ),
            const CustomSizedBox(height: 12),
            CustomInkWellContainer(
              borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
              onTap: () {
                Navigator.of(
                  context,
                ).popUntil((final Route route) => route.isFirst);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: CustomText(
                  'backToHome'.translate(context: context),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: context.colors.textBrand,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  void _goToBooking() {
    Navigator.of(context).popUntil((final Route route) => route.isFirst);
    if (widget.customJobRequestId != null) {
      Navigator.of(context).pushNamed(
        myRequestDetailsScreen,
        arguments: {
          'customJobRequestId': widget.customJobRequestId,
          'status': widget.isPending ? 'pending' : 'booked',
          'bookingId': widget.orderId,
        },
      );
    } else {
      Navigator.of(
        context,
      ).pushNamed(bookingDetails, arguments: {'bookingId': widget.orderId});
    }
  }

  void _backToHome() {
    Navigator.of(context).popUntil((final Route route) => route.isFirst);
  }

  Widget _buildStatusBody(
    final BuildContext context, {
    required final String icon,
    required final String title,
    required final String message,
    required final Widget buttons,
  }) => Column(
    children: [
      Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomSvgPicture(
                  svgImage: icon,
                  height: 124,
                  width: 124,
                  avoideResponsive: true,
                ),
                const CustomSizedBox(height: 16),
                CustomText(
                  title,
                  textAlign: TextAlign.center,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
                const CustomSizedBox(height: 8),
                CustomText(
                  message,
                  textAlign: TextAlign.center,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: context.colors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: buttons,
      ),
    ],
  );

  Widget _buildFailureBody(final BuildContext context) => _buildStatusBody(
    context,
    icon: AppAssets.bookingFailed,
    title: 'serviceBookingFailed'.translate(context: context),
    message: 'serviceBookingFailedMessage'.translate(context: context),
    buttons: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomInkWellContainer(
                borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
                onTap: () => Navigator.pop(context),
                child: CustomContainer(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  color: context.colors.backgroundBrand,
                  borderRadius: UiUtils.borderRadiusOf12,
                  child: Center(
                    child: CustomText(
                      'rePayment'.translate(context: context),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: context.colors.textInverseLight,
                    ),
                  ),
                ),
              ),
            ),
            const CustomSizedBox(width: 12),
            Expanded(
              child: CustomInkWellContainer(
                borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
                onTap: _goToBooking,
                child: CustomContainer(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  color: context.colors.backgroundBrandSubtle,
                  border: Border.all(color: context.colors.borderBrand),
                  borderRadius: UiUtils.borderRadiusOf12,
                  child: Center(
                    child: CustomText(
                      'viewBooking'.translate(context: context),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: context.colors.textBrand,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const CustomSizedBox(height: 12),
        CustomInkWellContainer(
          borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
          onTap: _backToHome,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: CustomText(
              'backToHome'.translate(context: context),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: context.colors.textBrand,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildPendingBody(final BuildContext context) => _buildStatusBody(
    context,
    icon: AppAssets.bookingPending,
    title: 'serviceBookingPending'.translate(context: context),
    message: 'serviceBookingPendingMessage'.translate(context: context),
    buttons: Column(
      children: [
        CustomInkWellContainer(
          borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
          onTap: _goToBooking,
          child: CustomContainer(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: context.colors.backgroundBrand,
            borderRadius: UiUtils.borderRadiusOf12,
            child: Center(
              child: CustomText(
                'viewBooking'.translate(context: context),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: context.colors.textInverseLight,
              ),
            ),
          ),
        ),
        const CustomSizedBox(height: 12),
        CustomInkWellContainer(
          borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
          onTap: _backToHome,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: CustomText(
              'backToHome'.translate(context: context),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: context.colors.textBrand,
            ),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(final BuildContext context) => PopScope(
    canPop: false,
    child: AnnotatedSafeArea(
      isAnnotated: true,
      applyBottomInset: false,
      child: Scaffold(
        backgroundColor: context.colors.backgroundSecondary,
        appBar: widget.isSuccess
            ? null
            : UiUtils.getSimpleAppBar(
                context: context,
                title: 'confirmation'.translate(context: context),
                centerTitle: true,
                isLeadingIconEnable: false,
              ),
        body: SafeArea(
          top: false,
          child: widget.isSuccess
              ? _buildSuccessBody(context)
              : widget.isPending
              ? _buildPendingBody(context)
              : _buildFailureBody(context),
        ),
      ),
    ),
  );
}
