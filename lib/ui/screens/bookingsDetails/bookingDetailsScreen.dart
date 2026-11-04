import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/cubits/bookingCubits/fetchBookingDetailsCubit.dart';
import 'package:e_demand/ui/screens/bookingsDetails/paymentGatewayManager.dart';
import 'package:e_demand/ui/screens/bookingsDetails/widgets/bookingActionBar.dart';
import 'package:e_demand/ui/screens/bookingsDetails/rateReviewsScreen.dart';
import 'package:e_demand/ui/screens/bookingsDetails/widgets/notesWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef PaymentGatewayDetails = ({String paymentType, String paymentImage});

// ignore: must_be_immutable
class BookingDetails extends StatefulWidget {
  BookingDetailModel? bookingDetails;
  final String? bookingId;
  final String? customRequestOrder;

  BookingDetails({
    final Key? key,
    this.bookingDetails,
    this.bookingId,
    this.customRequestOrder,
  }) : assert(
         bookingDetails != null || bookingId != null,
         'Either bookingDetails or bookingId must be provided',
       ),
       super(key: key);

  static Route route(final RouteSettings routeSettings) {
    final Map parameters = routeSettings.arguments as Map;

    final bool hasBookingId =
        parameters.containsKey("bookingId") && parameters["bookingId"] != null;

    return CupertinoPageRoute(
      builder: (final BuildContext context) => Builder(
        builder: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<AddTransactionCubit>(
                create: (context) =>
                    AddTransactionCubit(bookingRepository: BookingRepository()),
              ),
              BlocProvider<ChangeBookingStatusCubit>(
                create: (context) => ChangeBookingStatusCubit(
                  bookingRepository: BookingRepository(),
                ),
              ),
              BlocProvider<FetchBookingDetailsCubit>(
                create: (context) => FetchBookingDetailsCubit(),
              ),
            ],
            child: hasBookingId
                ? BookingDetails(
                    bookingId: parameters["bookingId"],
                    customRequestOrder: parameters["customRequestOrder"],
                  )
                : BookingDetails(bookingDetails: parameters["bookingDetails"]),
          );
        },
      ),
    );
  }

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  BookingDetailModel? _bookingDetails;

  ValueNotifier<bool> isBillDetailsCollapsed = ValueNotifier(true);
  ValueNotifier<String> paymentButtonName = ValueNotifier('');
  ValueNotifier<bool> isPaymentLoading = ValueNotifier(false);

  PaymentGatewayManager? _paymentManager;
  late List<Map<String, dynamic>> enabledPaymentMethods = [];
  late String selectedPaymentMethod = '';

  dynamic selectedDate;
  dynamic selectedTime;
  String? message;

  late final bool _navigatedByBookingId = widget.bookingId != null;

  bool get isPayLaterAllowed => _bookingDetails?.isPayLaterAllowed ?? false;

  bool get isOnlineAllowed =>
      context.read<SystemSettingCubit>().isOnlinePaymentAllowedGlobally;

  bool get isBookingCompleted => _bookingDetails?.status == "completed";

  bool get isBookingCancelled => _bookingDetails?.status == "cancelled";

  bool get isBookingAwaiting => _bookingDetails?.status == "awaiting";

  bool get isOTPSystemEnabled =>
      context.read<SystemSettingCubit>().isOTPSystemEnable;

  // Driven by the backend's own next_status_available list rather than a
  // client-side guess from the raw status string, so the button set always
  // matches what the API actually allows right now.
  bool get isBookingCancelable =>
      _bookingDetails?.nextStatusAvailable?.contains('cancelled') ?? false;

  bool get canReschedule =>
      _bookingDetails?.nextStatusAvailable?.contains('rescheduled') ?? false;

  bool get isCustomJobRequest => _bookingDetails?.isCustomJobRequest ?? false;

  BookingDetailsService? get _customJobService =>
      (_bookingDetails?.services?.isNotEmpty ?? false)
      ? _bookingDetails!.services![0]
      : null;

  bool get _customJobRatingPromptVisible =>
      isCustomJobRequest && isBookingCompleted && _customJobService != null;

  bool get hasAdditionalCharges => _hasAdditionalChargesCondition();

  bool get hasUnpaidAdditionalCharges => _hasUnpaidAdditionalChargesCondition();

  bool get hasRemarks => _bookingDetails?.remarks?.isNotEmpty ?? false;

  bool get isAtStoreBooking => _bookingDetails?.bookingType == 'at_store';

  bool get canTrackOrder =>
      _bookingDetails?.status == "on_the_way" &&
      !isAtStoreBooking &&
      (_bookingDetails?.liveTrackingStarted ?? false);

  String get _totalAdditionalCharge {
    final charges = _bookingDetails?.additionalCharges;
    if (charges == null || charges.isEmpty) return '0';
    final double sum = charges.fold(
      0.0,
      (total, charge) => total + (double.tryParse(charge.charge ?? '0') ?? 0.0),
    );
    return sum.toString();
  }

  bool _hasAdditionalChargesCondition() {
    return _bookingDetails?.additionalCharges != null &&
        _bookingDetails!.additionalCharges!.isNotEmpty &&
        _isValueGreaterThanZero(_totalAdditionalCharge);
  }

  bool _hasUnpaidAdditionalChargesCondition() {
    if (!hasAdditionalCharges) return false;

    final String? paymentStatus =
        _bookingDetails?.additionalChargesPaymentStatus;
    final bool isCod =
        _bookingDetails?.additionalChargesPaymentMethod?.toLowerCase() == 'cod';

    if (paymentStatus == '') return true;
    if (paymentStatus == '2') return true;
    if (paymentStatus == '0') return !isCod;
    return false;
  }

  bool _isValueGreaterThanZero(String? value) {
    if (value == null || value.isEmpty || value == 'null') {
      return false;
    }
    final doubleValue = double.tryParse(value.replaceAll(",", '')) ?? 0.0;
    return doubleValue > 0;
  }

  @override
  void initState() {
    super.initState();
    _bookingDetails = widget.bookingDetails;
    if (widget.bookingId != null && _bookingDetails == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<FetchBookingDetailsCubit>().fetchBookingDetails(
          bookingId: widget.bookingId!,
        );
      });
    } else {
      _initializePaymentMethods();
      getPaymentGatewayDetails();
    }
  }

  void _initializePaymentMethods() {
    enabledPaymentMethods = context
        .read<SystemSettingCubit>()
        .getEnabledPaymentMethods(
          isPayLaterAllowed: isPayLaterAllowed,
          isOnlinePaymentAllowed: isOnlineAllowed,
        );
  }

  @override
  void dispose() {
    _paymentManager?.dispose();
    paymentButtonName.dispose();
    isBillDetailsCollapsed.dispose();
    super.dispose();
  }

  ({String paymentImage, String paymentType}) getPaymentGatewayDetails() {
    switch (selectedPaymentMethod) {
      case "cod":
        return (paymentType: "cod", paymentImage: AppAssets.cod);
      case "stripe":
        return (paymentType: "stripe", paymentImage: AppAssets.stripe);
      case "razorpay":
        return (paymentType: "razorpay", paymentImage: AppAssets.razorpay);
      case "paystack":
        return (paymentType: "paystack", paymentImage: AppAssets.paystack);
      case "paypal":
        return (paymentType: "paypal", paymentImage: AppAssets.paypal);
      case "flutterwave":
        return (
          paymentType: "flutterwave",
          paymentImage: AppAssets.flutterwave,
        );
      case "cashfree":
        return (paymentType: "cashfree", paymentImage: AppAssets.cashfree);
      default:
        return (paymentType: "cod", paymentImage: AppAssets.cod);
    }
  }

  @override
  Widget build(final BuildContext context) => AnnotatedSafeArea(
    isAnnotated: true,
    applyBottomInset: false,
    child: Scaffold(
      appBar: UiUtils.getSimpleAppBar(
        context: context,
        title: 'bookingDetails'.translate(context: context),
      ),
      body: _buildBody(),
    ),
  );

  Widget _buildBody() {
    return BlocListener<ChangeBookingStatusCubit, ChangeBookingStatusState>(
      listener: (listenerContext, state) {
        _handleBookingStatusChange(
          listenerContext,
          state,
          parentContext: context,
        );
      },
      child: _navigatedByBookingId
          ? _buildFetchBookingDetailsBody()
          : BlocBuilder<BookingCubit, BookingState>(
              builder: (final BuildContext context, final BookingState state) {
                if (state is BookingFetchSuccess) {
                  return _buildBookingDetailsContent();
                }
                return ErrorContainer(
                  errorMessage: 'somethingWentWrong'.translate(
                    context: context,
                  ),
                );
              },
            ),
    );
  }

  Widget _buildFetchBookingDetailsBody() {
    return BlocConsumer<FetchBookingDetailsCubit, FetchBookingDetailsState>(
      listener: (context, state) {
        if (state is FetchBookingDetailsSuccess) {
          _bookingDetails = state.booking;
          _initializePaymentMethods();
          getPaymentGatewayDetails();
        }
      },
      builder: (context, state) {
        if (state is FetchBookingDetailsInProgress) {
          return _buildBookingDetailsShimmer();
        }

        if (state is FetchBookingDetailsFailure) {
          return ErrorContainer(
            errorMessage: state.errorMessage.translate(context: context),
            onTapRetry: () {
              context.read<FetchBookingDetailsCubit>().fetchBookingDetails(
                bookingId: widget.bookingId!,
              );
            },
          );
        }

        if (state is FetchBookingDetailsSuccess) {
          return _buildBookingDetailsContent();
        }

        return _buildBookingDetailsShimmer();
      },
    );
  }

  void _handleBookingStatusChange(
    BuildContext listenerContext,
    state, {
    required BuildContext parentContext,
  }) {
    if (state is ChangeBookingStatusFailure) {
      UiUtils.showMessage(
        context,
        state.errorMessage,
        ToastificationType.error,
      );
    } else if (state is ChangeBookingStatusSuccess) {
      UiUtils.showMessage(context, state.message, ToastificationType.success);
      _bookingDetails = state.bookingData;
      setState(() {});
      try {
        context.read<BookingCubit>().fetchAllBookings();
      } catch (_) {}
    }
  }

  bool get _showFixedActionBar =>
      isBookingCompleted ||
      canReschedule ||
      isBookingCancelable ||
      hasUnpaidAdditionalCharges;

  Widget _buildBookingDetailsContent() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsetsDirectional.only(
              top: 16,
              bottom: _showFixedActionBar
                  ? 10
                  : 10 + MediaQuery.viewPaddingOf(context).bottom,
            ),
            child: _buildCardStackBookingContent(),
          ),
        ),
        if (_showFixedActionBar)
          BookingActionBar(
            booking: _bookingDetails!,
            isBookingCompleted: isBookingCompleted,
            showReorder:
                !isCustomJobRequest && widget.customRequestOrder != '1',
            canReschedule: canReschedule,
            isBookingCancelable: isBookingCancelable,
            hasUnpaidAdditionalCharges: hasUnpaidAdditionalCharges,
            totalAdditionalCharge: _totalAdditionalCharge,
            onReschedule: _handleRescheduleButton,
            onPayAdditionalCharges: _showAdditionalPaymentBottomSheet,
            onCancel: _handleCancelBooking,
          ),
      ],
    );
  }

  Widget _buildCardStackBookingContent() {
    final booking = _bookingDetails!;
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookingDetailSummaryCard(
            bookingDetails: booking,
            isOTPSystemEnabled: isOTPSystemEnabled,
            serviceName: isCustomJobRequest ? _customJobService?.title : null,
            serviceCategory: isCustomJobRequest
                ? _customJobService?.categoryName
                : null,
            servicePrice: isCustomJobRequest ? _customJobService?.price : null,
          ),
          const CustomSizedBox(height: 16),
          if (_customJobRatingPromptVisible) ...[
            _buildCustomJobRatingCard(),
            const CustomSizedBox(height: 16),
          ],
          if (canTrackOrder) ...[
            _buildTrackOrderMiniMap(),
            const CustomSizedBox(height: 16),
          ],
          if (!isBookingAwaiting) ServiceStatusRow(bookingDetails: booking),

          if (!isCustomJobRequest) ...[
            BookingServicesCard(bookingDetails: booking),
            const CustomSizedBox(height: 16),
          ],
          ServiceTeamCard(bookingDetails: booking),
          if (_hasCustomJobProviderNote()) ...[
            const CustomSizedBox(height: 16),
            _buildCustomJobProviderNoteContainer(),
          ],
          if (hasRemarks) ...[
            const CustomSizedBox(height: 16),
            _buildRemarksSection(),
          ],
          if ((booking.workStartedProof?.isNotEmpty ?? false) ||
              (booking.workCompletedProof?.isNotEmpty ?? false)) ...[
            const CustomSizedBox(height: 16),
            ServiceGalleryCard(bookingDetails: booking),
          ],
          const CustomSizedBox(height: 16),
          PriceBreakdownCard(bookingDetails: booking),
        ],
      ),
    );
  }

  Widget _buildTrackOrderMiniMap() {
    return LiveTrackingMiniMapSection(
      orderId: _bookingDetails!.id!,
      addressId: _bookingDetails!.addressId ?? '',
    );
  }

  Widget _buildRemarksSection() {
    return NotesWidget(notes: _bookingDetails!.remarks!);
  }

  Widget _buildCustomJobProviderNoteContainer() {
    return CustomContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: context.colors.backgroundPrimary,
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            'noteForProvider'.translate(context: context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.colors.textPrimary,
          ),
          const CustomSizedBox(height: 12),
          CustomContainer(height: 1, color: context.colors.borderDefault),
          const CustomSizedBox(height: 12),
          CustomReadMoreTextContainer(
            text: _bookingDetails?.customJobRequest?.providerBidNote ?? '',
            textStyle: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetailsShimmer() => const SingleChildScrollView(
    padding: EdgeInsets.all(10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomShimmerLoadingContainer(
          height: 80,
          borderRadius: UiUtils.borderRadiusOf10,
        ),
        CustomSizedBox(height: 8),
        CustomShimmerLoadingContainer(
          height: 60,
          borderRadius: UiUtils.borderRadiusOf10,
        ),
        CustomSizedBox(height: 8),
        CustomShimmerLoadingContainer(
          height: 120,
          borderRadius: UiUtils.borderRadiusOf10,
        ),
        CustomSizedBox(height: 8),
        CustomShimmerLoadingContainer(
          height: 180,
          borderRadius: UiUtils.borderRadiusOf10,
        ),
        CustomSizedBox(height: 8),
        CustomShimmerLoadingContainer(
          height: 150,
          borderRadius: UiUtils.borderRadiusOf10,
        ),
        CustomSizedBox(height: 8),
        CustomShimmerLoadingContainer(
          height: 100,
          borderRadius: UiUtils.borderRadiusOf10,
        ),
      ],
    ),
  );

  bool _hasCustomJobProviderNote() {
    final providerNote = _bookingDetails?.customJobRequest?.providerBidNote;
    return providerNote != null && providerNote.isNotEmpty;
  }

  Future<void> _openCustomJobRateReviewsScreen(
    final BookingDetailsService service,
  ) async {
    final BookingRepository repository = BookingRepository();
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (final _) => RateReviewsScreen(
          title: 'rateServices'.translate(context: context),
          items: [
            RateableCardConfig(
              avatarUrl: service.image ?? '',
              avatarSize: 40,
              avatarRadius: 8,
              titleWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  CustomText(
                    service.title ?? '',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    maxLines: 1,
                    color: context.colors.textPrimary,
                  ),
                  CustomText(
                    (service.price ?? '0').priceFormat(
                      context,
                      currencySymbol: _bookingDetails?.currencySymbol,
                      decimalPlaces: _bookingDetails?.currencyDecimalPlaces,
                    ),
                    fontSize: 12,
                    color: context.colors.textPrimary,
                  ),
                ],
              ),
              existingRating: service.hasReview ? service.rating : null,
              existingReview: service.review ?? '',
              existingImages: service.reviewImages ?? [],
              onSubmit:
                  ({
                    required final rating,
                    required final review,
                    required final newImages,
                    required final deletedImages,
                  }) => repository.submitReviewToService(
                    serviceId: service.serviceId ?? '',
                    ratingStar: rating.toString(),
                    reviewComment: review,
                    reviewImages: newImages,
                    customJobRequestId: _bookingDetails?.customJobRequest?.id,
                    deletedPastReviewImages: deletedImages,
                  ),
              onSuccess: (final data) {
                if (!mounted) return;
                setState(() {
                  _bookingDetails!.services?[0] = service.copyWith(
                    rating: int.tryParse(data?['rating']?.toString() ?? ''),
                    review: data?['comment']?.toString(),
                    reviewImages: (data?['images'] as List?)
                        ?.map((final e) => e.toString())
                        .toList(),
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomJobRatingCard() {
    final BookingDetailsService? service = _customJobService;
    if (service == null) return const SizedBox.shrink();
    final bool isRated = service.hasReview;
    return CustomContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: context.colors.surfacePrimary,
      borderRadius: 12,
      child: RatingPromptRow(
        title: 'rateYourExperience'.translate(context: context),
        subtitleKey: 'rateYourExperienceWithService',
        onRate: () => _openCustomJobRateReviewsScreen(service),
        buttonLabelKey: (isRated ? 'edit' : 'rate').translate(context: context),
      ),
    );
  }

  void _handleRescheduleButton() {
    Navigator.pushNamed(
      context,
      rescheduleServiceRoute,
      arguments: {
        "bookingDetails": _bookingDetails,
        "selectedDate": selectedDate,
        "selectedTime": selectedTime,
      },
    ).then(_handleRescheduleResult);
  }

  void _handleRescheduleResult(dynamic value) {
    if (value == null) return;

    final bool isSaved = value['isSaved'];
    // selectedDate is now returned as String (YYYY-MM-DD format) from calenderBottomSheet
    final dateValue = value['selectedDate'];
    if (dateValue is String) {
      selectedDate = DateTime.parse(dateValue);
    } else if (dateValue is DateTime) {
      selectedDate = dateValue;
    }
    selectedTime = value['selectedTime'];
    message = value['message'];

    if (selectedTime != null && selectedDate != null && isSaved) {
      // Format selectedDate as date only (YYYY-MM-DD) without time
      final formattedDate = DateFormat(
        'yyyy-MM-dd',
      ).format(selectedDate as DateTime);
      context.read<ChangeBookingStatusCubit>().changeBookingStatus(
        pressedButtonName: "reschedule",
        bookingStatus: 'rescheduled',
        bookingId: _bookingDetails!.id!,
        selectedTime: selectedTime.toString(),
        selectedDate: formattedDate,
      );
    }
  }

  void _showAdditionalPaymentBottomSheet() {
    UiUtils.showBottomSheet(
      context: context,
      enableDrag: true,
      child: _buildAdditionalPaymentWidget(
        context: context,
        bookingDetails: _bookingDetails!,
      ),
    );
  }

  Future<void> _handleCancelBooking() async {
    final changeStatusCubit = context.read<ChangeBookingStatusCubit>();
    final bookingId = _bookingDetails!.id!;

    int reasonCount = 0;
    try {
      final reasons = await BookingRepository().getCancelReasons();
      reasonCount = reasons.length;
    } catch (_) {}

    if (!mounted) return;

    if (reasonCount == 0) {
      changeStatusCubit.changeBookingStatus(
        pressedButtonName: 'cancelBooking',
        bookingStatus: 'cancelled',
        bookingId: bookingId,
        cancelReasonId: '',
        additionalInfo: null,
      );
      return;
    }

    UiUtils.showBottomSheet(
      enableDrag: true,
      context: context,
      child: BlocProvider<FetchCancelReasonsCubit>(
        create: (_) =>
            FetchCancelReasonsCubit(bookingRepository: BookingRepository()),
        child: BookingCancelReasonBottomSheet(
          onConfirm: (reasonId, _, additionalInfo) {
            changeStatusCubit.changeBookingStatus(
              pressedButtonName: 'cancelBooking',
              bookingStatus: 'cancelled',
              bookingId: bookingId,
              cancelReasonId: reasonId,
              additionalInfo: additionalInfo,
            );
          },
        ),
      ),
    );
  }

  Widget _buildAdditionalPaymentWidget({
    required final BuildContext context,
    required final BookingDetailModel bookingDetails,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
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
              const CustomSizedBox(height: 16),
              CustomText(
                'payAdditionalCharges'.translate(context: context),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: context.colors.textPrimary,
              ),
              const CustomSizedBox(height: 16),
              Divider(height: 1, color: context.colors.borderDefault),
              const CustomSizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: enabledPaymentMethods.length,
                separatorBuilder: (final context, final index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: CustomSizedBox(
                    height: 1,
                    width: double.infinity,
                    child: DashedRect(
                      color: context.colors.borderDefault,
                      strokeWidth: 1,
                      gap: 4,
                    ),
                  ),
                ),
                itemBuilder: (context, index) {
                  final Map<String, dynamic> paymentMethod =
                      enabledPaymentMethods[index];
                  return CustomRadioOptionsWidget(
                    image: paymentMethod["image"]!,
                    title: paymentMethod["title"]!,
                    value: paymentMethod["paymentType"]!,
                    groupValue: selectedPaymentMethod,
                    applyAccentColor: false,
                    onChanged: (final Object? selectedValue) {
                      setState(() {
                        selectedPaymentMethod = selectedValue.toString();
                        if (selectedValue.toString() == "cod") {
                          paymentButtonName.value = "payWithCash".translate(
                            context: context,
                          );
                        } else {
                          paymentButtonName.value = "makePayment".translate(
                            context: context,
                          );
                        }
                      });
                      ClarityService.logAction(
                        ClarityActions.paymentMethodSelected,
                        {
                          'order_id': _bookingDetails!.id ?? '',
                          'selected_method': selectedValue.toString(),
                          'current_method':
                              _bookingDetails!.paymentMethod ?? '',
                        },
                      );
                      ClarityService.setTag(
                        'payment_method',
                        selectedValue.toString(),
                      );
                    },
                  );
                },
              ),
              const CustomSizedBox(height: 16),
              if (paymentButtonName.value != '')
                BlocConsumer<AddTransactionCubit, AddTransactionState>(
                  listener: (context, state) {
                    if (state is AddTransactionSuccess) {
                      final totalAdditionalCharge = _totalAdditionalCharge;
                      isPaymentLoading.value = true;
                      _processPayment(
                        state: state,
                        totalAdditionalCharge: totalAdditionalCharge,
                      ).then((value) {
                        isPaymentLoading.value = false;
                      });
                    }
                  },
                  builder: (context, state) {
                    return ValueListenableBuilder(
                      valueListenable: paymentButtonName,
                      builder: (context, String value, _) {
                        return ValueListenableBuilder(
                          valueListenable: isPaymentLoading,
                          builder: (context, isLoading, _) {
                            return CustomRoundedButton(
                              buttonTitle: value,
                              showBorder: true,
                              widthPercentage: 0.8,
                              backgroundColor: context.colors.backgroundBrand,
                              onTap: () async {
                                if (isPaymentLoading.value) return;
                                isPaymentLoading.value = true;
                                ClarityService.logAction(
                                  ClarityActions.paymentStarted,
                                  {
                                    'order_id': _bookingDetails!.id ?? '',
                                    'payment_method': selectedPaymentMethod,
                                    'additional_charge_total':
                                        _totalAdditionalCharge,
                                  },
                                );
                                _paymentManager?.dispose();
                                _paymentManager = PaymentGatewayManager(
                                  placedOrderId: _bookingDetails!.id ?? '',
                                  context: context,
                                  paymentGatewaySetting: context
                                      .read<SystemSettingCubit>()
                                      .paymentGatewaysSettings,
                                );

                                if (selectedPaymentMethod == 'razorpay' ||
                                    selectedPaymentMethod == 'stripe' ||
                                    selectedPaymentMethod == 'cashfree') {
                                  await _processDirectPayment(
                                    _totalAdditionalCharge,
                                  );
                                } else if (selectedPaymentMethod == 'cod') {
                                  await _processDirectPayment(
                                    _totalAdditionalCharge,
                                  );
                                } else {
                                  await context
                                      .read<AddTransactionCubit>()
                                      .addTransaction(
                                        status: "pending",
                                        orderID: _bookingDetails!.id ?? '',
                                        isAdditionalCharge: '1',
                                        paymentGatewayName:
                                            selectedPaymentMethod,
                                      );
                                }
                                isPaymentLoading.value = false;
                              },
                              child: isLoading
                                  ? Center(
                                      child: CustomCircularProgressIndicator(
                                        color: context.colors.textInverseLight,
                                      ),
                                    )
                                  : null,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _processPayment({
    required AddTransactionSuccess state,
    required String? totalAdditionalCharge,
  }) async {
    String? paymentUrl;

    switch (selectedPaymentMethod) {
      case 'paystack':
        paymentUrl = state.paystackUrl;
        break;
      case 'flutterwave':
        paymentUrl = state.flutterwaveUrl;
        break;
      case 'paypal':
        paymentUrl = state.paypalUrl;
        break;
      case 'xendit':
        paymentUrl = state.xenditUrl;
        break;
    }

    if (paymentUrl != null && paymentUrl.isNotEmpty) {
      ClarityService.logAction(ClarityActions.paymentGatewayRedirected, {
        'order_id': _bookingDetails!.id ?? '',
        'payment_method': selectedPaymentMethod,
        'payment_url': paymentUrl,
        'amount': totalAdditionalCharge ?? '',
      });
      await _paymentManager?.processPayment(
        paymentMethod: selectedPaymentMethod,
        amount: double.parse(
          totalAdditionalCharge == '' ? '0' : totalAdditionalCharge ?? '0',
        ),
        orderId: _bookingDetails!.id ?? '',
        paymentUrl: paymentUrl,
      );
    }
  }

  Future<void> _processDirectPayment(String? totalAdditionalCharge) async {
    ClarityService.logAction(ClarityActions.paymentGatewayRedirected, {
      'order_id': _bookingDetails!.id ?? '',
      'payment_method': selectedPaymentMethod,
      'amount': totalAdditionalCharge ?? '',
      'flow': 'direct',
    });
    await _paymentManager?.processPayment(
      paymentMethod: selectedPaymentMethod,
      amount: double.parse(
        totalAdditionalCharge == '' ? '0' : totalAdditionalCharge ?? '0',
      ),
      orderId: _bookingDetails!.id ?? '',
    );
  }
}
