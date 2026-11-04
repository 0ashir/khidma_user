import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/cubits/chat/reportReasonCubit.dart';
import 'package:e_demand/cubits/chat/submitReportCubit.dart';
import 'package:e_demand/data/model/chat/reportReasonModel.dart';
import 'package:flutter/material.dart';

enum ReportMessageType { success, error, loading }

class ReportReasonBottomSheet extends StatefulWidget {
  final String providerId;
  final bool isBlocked;
  final Function(bool) onBlockStatusChanged;

  const ReportReasonBottomSheet({
    super.key,
    required this.providerId,
    required this.isBlocked,
    required this.onBlockStatusChanged,
  });

  @override
  State<ReportReasonBottomSheet> createState() =>
      _ReportReasonBottomSheetState();
}

class _ReportReasonBottomSheetState extends State<ReportReasonBottomSheet> {
  String? selectedReasonId;
  final TextEditingController additionalInfoController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    additionalInfoController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<GetReportReasonsCubit>().getReportReasons();
  }

  void _onConfirm() {
    if (_formKey.currentState?.validate() ?? false) {
      if (selectedReasonId == null) {
        UiUtils.showMessage(
          context,
          'pleaseSelectReason'.translate(context: context),
          ToastificationType.error,
        );
        return;
      }
      context.read<SubmitReportCubit>().submitReport(
        providerId: widget.providerId,
        reasonId: selectedReasonId!,
        additionalInfo: additionalInfoController.text,
      );
    }
  }

  Widget _radioIndicator(BuildContext context, bool isSelected) {
    return CustomContainer(
      height: 24,
      width: 24,
      shape: BoxShape.circle,
      border: Border.all(
        width: 1.5,
        color: isSelected
            ? context.colors.borderBrand
            : context.colors.borderDefault,
      ),
      child: isSelected
          ? Center(
              child: CustomContainer(
                height: 12,
                width: 12,
                shape: BoxShape.circle,
                color: context.colors.backgroundBrand,
              ),
            )
          : null,
    );
  }

  Widget _buildReasonItem({
    required BuildContext context,
    required ReportReasonModel reason,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomInkWellContainer(
          onTap: onTap,
          borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
          child: CustomContainer(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            borderRadius: UiUtils.borderRadiusOf12,
            border: Border.all(
              width: 1.5,
              color: isSelected
                  ? context.colors.borderBrand
                  : context.colors.borderDefault,
            ),
            child: Row(
              spacing: 8,
              children: [
                _radioIndicator(context, isSelected),
                Expanded(
                  child: CustomText(
                    reason.translatedReason?.translate(context: context) ?? '',
                    color: isSelected
                        ? context.colors.textPrimary
                        : context.colors.textSecondary,
                    fontSize: 14,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isSelected && reason.needsAdditionalInfo == "1") ...[
          const CustomSizedBox(height: 12),
          CustomTextFormField(
            controller: additionalInfoController,
            hintText: 'enterAdditionalInfo'.translate(context: context),
            hintTextColor: context.colors.textTertiary,
            fillColor: context.colors.backgroundSecondary,
            borderColor: context.colors.borderDefault,
            borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf8),
            textInputType: TextInputType.multiline,
            minLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'pleaseEnterAdditionalInfo'.translate(context: context);
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
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
              'reportUser'.translate(context: context),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: context.colors.textPrimary,
            ),
          ),
          const CustomSizedBox(height: 8),
          CustomContainer(height: 1, color: context.colors.borderDefault),
        ],
      ),
    );
  }

  Widget _shell(
    BuildContext context, {
    required Widget content,
    Widget? footer,
  }) {
    return CustomContainer(
      color: context.colors.backgroundPrimary,
      borderRadiusStyle: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(context),
            Flexible(child: SingleChildScrollView(child: content)),
            if (footer != null) footer,
          ],
        ),
      ),
    );
  }

  Widget _confirmButton(BuildContext context, SubmitReportState submitState) {
    final bool isLoading = submitState is SubmitReportInProgress;
    return ClipShadowBottom(
      child: CustomContainer(
        color: context.colors.backgroundPrimary,
        padding: const EdgeInsets.all(
          16,
        ).copyWith(bottom: 16 + MediaQuery.viewPaddingOf(context).bottom),
        boxShadow: [
          BoxShadow(
            color: context.colors.overlayFooterShadow,
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
        child: CustomInkWellContainer(
          borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
          onTap: isLoading ? null : _onConfirm,
          child: CustomContainer(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            borderRadius: UiUtils.borderRadiusOf12,
            color: context.colors.backgroundBrand,
            child: Center(
              child: isLoading
                  ? CustomCircularProgressIndicator(
                      color: context.colors.textInverseLight,
                    )
                  : CustomText(
                      'confirm'.translate(context: context),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: context.colors.textInverseLight,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SubmitReportCubit, SubmitReportState>(
          listener: (context, state) {
            if (state is SubmitReportSuccess) {
              widget.onBlockStatusChanged(true);
              Navigator.pop(context);
              UiUtils.showMessage(
                context,
                state.message.translate(context: context),
                ToastificationType.success,
              );
            } else if (state is SubmitReportFailure) {
              UiUtils.showMessage(
                context,
                state.errorMessage,
                ToastificationType.error,
              );
            }
          },
        ),
      ],
      child: BlocBuilder<GetReportReasonsCubit, GetReportReasonsState>(
        builder: (context, state) {
          if (state is GetReportReasonsInProgress) {
            return _shell(
              context,
              content: const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CustomCircularProgressIndicator()),
              ),
            );
          } else if (state is GetReportReasonsFailure) {
            return _shell(
              context,
              content: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: ErrorContainer(
                  errorMessage: state.errorMessage,
                  onTapRetry: () {
                    context.read<GetReportReasonsCubit>().getReportReasons();
                  },
                ),
              ),
            );
          } else if (state is GetReportReasonsSuccess) {
            if (state.reportReasons.isEmpty) {
              // Directly submit report with empty values when list is empty
              context.read<SubmitReportCubit>().submitReport(
                providerId: widget.providerId,
                reasonId: '',
                additionalInfo: '',
              );
              return const SizedBox.shrink();
            }
            return Form(
              key: _formKey,
              child: _shell(
                context,
                content: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 12,
                    children: state.reportReasons
                        .map(
                          (reason) => _buildReasonItem(
                            context: context,
                            reason: reason,
                            isSelected: selectedReasonId == reason.id,
                            onTap: () {
                              setState(() {
                                selectedReasonId = reason.id;
                                if (reason.needsAdditionalInfo != "1") {
                                  additionalInfoController.clear();
                                }
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
                footer: BlocBuilder<SubmitReportCubit, SubmitReportState>(
                  builder: (context, submitState) =>
                      _confirmButton(context, submitState),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
