import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class MyRequestCancelButton extends StatelessWidget {
  const MyRequestCancelButton({
    required this.job,
    required this.customJobRequestId,
    super.key,
  });

  final CustomJob job;
  final String customJobRequestId;

  @override
  Widget build(
    final BuildContext context,
  ) => BlocListener<CancelCustomJobRequestCubit, CancelCustomJobRequestState>(
    listener: (_, state) {
      if (state is CancelCustomJobRequestSuccess) {
        UiUtils.showMessage(
          context,
          state.response,
          ToastificationType.success,
        );
        context.read<MyRequestDetailsCubit>().markCancelled(
          cancelReason: state.cancelReasonText,
        );
        context.read<MyRequestListCubit>().updateRequestStatusLocally(
          requestId: customJobRequestId,
          status: 'cancelled',
        );
      } else if (state is CancelCustomJobRequestFailure) {
        UiUtils.showMessage(
          context,
          state.errorMessage.translate(context: context),
          ToastificationType.error,
        );
      }
    },
    child:
        BlocBuilder<CancelCustomJobRequestCubit, CancelCustomJobRequestState>(
          builder: (ctx, cancelState) {
            final isLoading = cancelState is CancelCustomJobRequestInProgress;
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(
                16,
              ).copyWith(bottom: 16 + MediaQuery.viewPaddingOf(context).bottom),
              decoration: BoxDecoration(
                color: context.colors.backgroundPrimary,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                    color: context.colors.overlayFooterShadow,
                  ),
                ],
              ),
              child: CustomContainer(
                height: 48,
                borderRadius: 12,
                color: context.colors.backgroundErrorSubtle,
                border: Border.all(color: context.colors.borderError, width: 1),
                child: CustomInkWellContainer(
                  borderRadius: BorderRadius.circular(12),
                  onTap: isLoading
                      ? null
                      : () async {
                          final cancelCubit = context
                              .read<CancelCustomJobRequestCubit>();
                          final requestId = job.id ?? customJobRequestId;

                          int reasonCount = 0;
                          try {
                            final reasons = await BookingRepository()
                                .getCancelReasons();
                            reasonCount = reasons.length;
                          } catch (_) {}

                          if (!context.mounted) return;

                          if (reasonCount == 0) {
                            cancelCubit.cancelBooking(
                              customJobRequestId: requestId,
                              cancelReasonId: '',
                              additionalInfo: null,
                            );
                            return;
                          }

                          UiUtils.showBottomSheet(
                            context: context,
                            enableDrag: true,
                            isScrollControlled: true,
                            useSafeArea: true,
                            child: BlocProvider<FetchCancelReasonsCubit>(
                              create: (_) => FetchCancelReasonsCubit(
                                bookingRepository: BookingRepository(),
                              ),
                              child: BookingCancelReasonBottomSheet(
                                onConfirm:
                                    (reasonId, reasonText, additionalInfo) {
                                      cancelCubit.cancelBooking(
                                        customJobRequestId: requestId,
                                        cancelReasonId: reasonId,
                                        cancelReasonText: reasonText,
                                        additionalInfo: additionalInfo,
                                      );
                                    },
                              ),
                            ),
                          );
                        },
                  child: Center(
                    child: isLoading
                        ? CustomCircularProgressIndicator(
                            color: context.colors.textError,
                            widthAndHeight: 22,
                          )
                        : CustomText(
                            'cancelRequest'.translate(context: context),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: context.colors.textError,
                          ),
                  ),
                ),
              ),
            );
          },
        ),
  );
}
