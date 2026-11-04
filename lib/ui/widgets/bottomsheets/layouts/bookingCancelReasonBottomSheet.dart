import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/data/model/chat/reportReasonModel.dart';
import 'package:flutter/material.dart';

class BookingCancelReasonBottomSheet extends StatefulWidget {
  final void Function(
    String reasonId,
    String? reasonText,
    String? additionalInfo,
  )
  onConfirm;

  const BookingCancelReasonBottomSheet({super.key, required this.onConfirm});

  @override
  State<BookingCancelReasonBottomSheet> createState() =>
      _BookingCancelReasonBottomSheetState();
}

class _BookingCancelReasonBottomSheetState
    extends State<BookingCancelReasonBottomSheet> {
  String? selectedReasonId;
  ReportReasonModel? selectedReason;
  final TextEditingController _additionalInfoController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    context.read<FetchCancelReasonsCubit>().fetchCancelReasons();
  }

  @override
  void dispose() {
    _additionalInfoController.dispose();
    super.dispose();
  }

  void _onConfirm(BuildContext context) {
    if (selectedReasonId == null) {
      UiUtils.showMessage(
        context,
        'pleaseSelectReason'.translate(context: context),
        ToastificationType.error,
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? true)) return;

    Navigator.of(context).pop();
    widget.onConfirm(
      selectedReasonId!,
      selectedReason?.reason,
      selectedReason?.needsAdditionalInfo == '1'
          ? _additionalInfoController.text.trim()
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: context.colors.surfacePrimary,
      borderRadiusStyle: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 8,
                    decoration: BoxDecoration(
                      color: context.colors.borderDefault,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                const CustomSizedBox(height: 8),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: CustomText(
                    'selectCancellationReason'.translate(context: context),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textPrimary,
                  ),
                ),
                const CustomSizedBox(height: 8),
                Divider(height: 1, color: context.colors.borderDefault),
              ],
            ),
          ),
          Flexible(
            child:
                BlocBuilder<FetchCancelReasonsCubit, FetchCancelReasonsState>(
                  builder: (context, state) {
                    if (state is FetchCancelReasonsInProgress) {
                      return const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CustomCircularProgressIndicator()),
                      );
                    }
                    if (state is FetchCancelReasonsFailure) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: ErrorContainer(
                          errorMessage: state.errorMessage,
                          onTapRetry: () => context
                              .read<FetchCancelReasonsCubit>()
                              .fetchCancelReasons(),
                        ),
                      );
                    }
                    if (state is FetchCancelReasonsSuccess) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          16,
                          16,
                          MediaQuery.viewInsetsOf(context).bottom + 16,
                        ),
                        child: Form(
                          key: _formKey,
                          child: _buildReasonList(context, state.reasons),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildReasonList(
    BuildContext context,
    List<ReportReasonModel> reasons,
  ) {
    if (reasons.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: CustomText(
            'noCancelReasonsAvailable'.translate(context: context),
            color: context.colors.textSecondary,
            fontSize: 14,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < reasons.length; i++) ...[
          if (i > 0) const CustomSizedBox(height: 12),
          _buildReasonCard(context, reasons[i]),
        ],
        if (selectedReason?.needsAdditionalInfo == '1') ...[
          const CustomSizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text:
                      '${'additionalCommentsFor'.translate(context: context)} ${selectedReason?.reason}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textError,
                  ),
                ),
              ],
            ),
          ),
          const CustomSizedBox(height: 6),
          CustomTextFormField(
            controller: _additionalInfoController,
            hintText: 'typeYourCommentHere'.translate(context: context),
            textInputType: TextInputType.multiline,
            minLines: 3,
            expands: false,
            showFullBorder: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'pleaseEnterAdditionalInfo'.translate(context: context);
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildReasonCard(BuildContext context, ReportReasonModel reason) {
    final bool isSelected = selectedReasonId == reason.id;
    return CustomInkWellContainer(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() {
          selectedReasonId = reason.id;
          selectedReason = reason;
          if (reason.needsAdditionalInfo != '1') {
            _additionalInfoController.clear();
          }
        });
      },
      child: CustomContainer(
        width: double.infinity,
        borderRadius: 12,
        color: context.colors.surfacePrimary,
        border: Border.all(
          color: isSelected
              ? context.colors.borderBrand
              : context.colors.borderDefault,
          width: 1.5,
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 24,
              color: isSelected
                  ? context.colors.iconBrand
                  : context.colors.iconTertiary,
            ),
            const CustomSizedBox(width: 8),
            Expanded(
              child: CustomText(
                reason.reason ?? '',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: isSelected
                    ? context.colors.textPrimary
                    : context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return ClipShadowBottom(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(
          16,
        ).copyWith(bottom: 16 + MediaQuery.viewPaddingOf(context).bottom),
        decoration: BoxDecoration(
          color: context.colors.surfacePrimary,
          boxShadow: [
            BoxShadow(
              color: context.colors.overlayFooterShadow,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: CustomInkWellContainer(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.of(context).pop(),
                child: CustomContainer(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: context.colors.backgroundBrandSubtle,
                  borderRadius: 12,
                  border: Border.all(color: context.colors.borderBrand),
                  child: Center(
                    child: CustomText(
                      'cancel'.translate(context: context),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: context.colors.textBrand,
                    ),
                  ),
                ),
              ),
            ),
            const CustomSizedBox(width: 12),
            Expanded(
              child: CustomInkWellContainer(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _onConfirm(context),
                child: CustomContainer(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: context.colors.backgroundBrand,
                  borderRadius: 12,
                  child: Center(
                    child: CustomText(
                      'confirm'.translate(context: context),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: context.colors.textInverseLight,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
