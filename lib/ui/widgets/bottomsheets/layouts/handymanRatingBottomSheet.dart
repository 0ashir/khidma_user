import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class HandymanRatingBottomSheet extends StatefulWidget {
  final String orderId;
  final String handymanId;
  final String handymanName;
  final String? ratingId;
  final int? initialRating;
  final String? initialReview;
  final List<String>? initialReviewImages;

  const HandymanRatingBottomSheet({
    super.key,
    required this.orderId,
    required this.handymanId,
    required this.handymanName,
    this.ratingId,
    this.initialRating,
    this.initialReview,
    this.initialReviewImages,
  });

  @override
  State<HandymanRatingBottomSheet> createState() =>
      _HandymanRatingBottomSheetState();
}

class _HandymanRatingBottomSheetState extends State<HandymanRatingBottomSheet> {
  final TextEditingController reviewController = TextEditingController();

  int? selectedRating;

  final ImagePicker imagePicker = ImagePicker();
  ValueNotifier<List<XFile>> reviewImages = ValueNotifier([]);
  ValueNotifier<List<String>> pastReviewImages = ValueNotifier([]);

  Set<String> deletedPastReviewImages = {};

  bool get _isEditing => (widget.initialRating ?? 0) > 0;

  bool get _canDelete => _isEditing && (widget.ratingId?.isNotEmpty ?? false);

  Future<void> selectReviewImage() async {
    final List<XFile> listOfSelectedImage = await imagePicker.pickMultiImage();
    if (listOfSelectedImage.isNotEmpty) {
      reviewImages.value = listOfSelectedImage;
    }
  }

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      reviewController.text = widget.initialReview ?? '';
      selectedRating = widget.initialRating! - 1;
      pastReviewImages.value = widget.initialReviewImages ?? [];
    }
  }

  @override
  void dispose() {
    reviewImages.dispose();
    reviewController.dispose();
    pastReviewImages.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation(BuildContext context) {
    final deleteReviewCubit = context.read<DeleteHandymanReviewCubit>();
    UiUtils.showAnimatedDialog(
      context: context,
      child: CustomDialogLayout(
        showProgressIndicator: false,
        icon: CustomContainer(
          height: 70,
          width: 70,
          padding: const EdgeInsets.all(10),
          color: context.colors.surfaceElevated,
          borderRadius: UiUtils.borderRadiusOf50,
          child: Icon(Icons.help, color: context.colors.textBrand, size: 70),
        ),
        title: "deleteReview",
        description: "doYouReallyWantToDelete",
        cancelButtonName: "cancel",
        cancelButtonBackgroundColor: context.colors.surfaceElevated,
        cancelButtonPressed: () {
          Navigator.of(context).pop();
        },
        confirmButtonName: "delete",
        confirmButtonBackgroundColor: context.colors.textError,
        confirmButtonPressed: () {
          Navigator.of(context).pop();
          deleteReviewCubit.deleteReview(
            ratingId: widget.ratingId!,
            handymanId: widget.handymanId,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: BottomSheetLayout(
        title: _isEditing ? "editReview" : "reviewAndRating",
        child: MultiBlocListener(
          listeners: [
            BlocListener<SaveHandymanReviewCubit, SaveHandymanReviewState>(
              listener: (context, state) {
                if (state is SaveHandymanReviewSuccess) {
                  UiUtils.showMessage(
                    context,
                    'reviewSubmittedSuccessfully'.translate(context: context),
                    ToastificationType.success,
                  );
                  Navigator.pop(context, state.review);
                } else if (state is SaveHandymanReviewFailure) {
                  UiUtils.showMessage(
                    context,
                    state.errorMessage,
                    ToastificationType.error,
                  );
                }
              },
            ),
            BlocListener<DeleteHandymanReviewCubit, DeleteHandymanReviewState>(
              listener: (context, state) {
                if (state is DeleteHandymanReviewSuccess) {
                  UiUtils.showMessage(
                    context,
                    'reviewDeletedSuccessfully'.translate(context: context),
                    ToastificationType.success,
                  );
                  Navigator.pop(context, DeletedHandymanReviewSignal.instance);
                } else if (state is DeleteHandymanReviewFailure) {
                  UiUtils.showMessage(
                    context,
                    state.errorMessage,
                    ToastificationType.error,
                  );
                }
              },
            ),
          ],
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              bottom: 10,
              start: 10,
              end: 15,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomContainer(
                  margin: const EdgeInsetsDirectional.only(
                    bottom: 10,
                    start: 5,
                    top: 5,
                  ),
                  child: CustomText(
                    widget.handymanName,
                    color: context.colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    children: List.generate(5, (index) {
                      return CustomInkWellContainer(
                        onTap: () {
                          selectedRating = index;
                          setState(() {});
                        },
                        child: CustomContainer(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 5,
                          ),
                          width: 40,
                          height: 25,
                          color: selectedRating == index
                              ? context.colors.backgroundBrand
                              : null,
                          borderRadius: UiUtils.borderRadiusOf5,
                          border: Border.all(
                            color: context.colors.backgroundBrand,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomText(
                                  '${index + 1}',
                                  color: selectedRating == index
                                      ? context.colors.textInverseLight
                                      : context.colors.textSecondary,
                                  fontSize: 12,
                                ),
                                Icon(
                                  Icons.star_outlined,
                                  size: 15,
                                  color: selectedRating == index
                                      ? context.colors.textInverseLight
                                      : context.colors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                CustomContainer(
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 5,
                  ),
                  height: 100,
                  child: TextField(
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.textPrimary,
                    ),
                    maxLines: 5,
                    textAlign: TextAlign.start,
                    controller: reviewController,
                    cursorColor: context.colors.textPrimary,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(15),
                      filled: false,
                      fillColor: context.colors.surfaceElevated,
                      hintText:
                          "${"writeReview".translate(context: context)} for ${widget.handymanName}",
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: context.colors.textSecondary,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: context.colors.backgroundBrand,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(UiUtils.borderRadiusOf5),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: context.colors.backgroundBrand,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(UiUtils.borderRadiusOf5),
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: context.colors.backgroundBrand,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(UiUtils.borderRadiusOf5),
                        ),
                      ),
                    ),
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: pastReviewImages,
                  builder: (context, pastValue, child) {
                    return ValueListenableBuilder(
                      valueListenable: reviewImages,
                      builder: (context, List<XFile?> value, child) {
                        final bool areThereNoImages =
                            value.isEmpty && pastValue.isEmpty;
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: areThereNoImages
                              ? const NeverScrollableScrollPhysics()
                              : const AlwaysScrollableScrollPhysics(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomInkWellContainer(
                                onTap: selectReviewImage,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                  ),
                                  child: DottedBorderWithHint(
                                    width: areThereNoImages
                                        ? context.screenWidth - 40
                                        : 100,
                                    height: 100,
                                    radius: 5,
                                    borderColor: context.colors.backgroundBrand,
                                    hint: "chooseImage".translate(
                                      context: context,
                                    ),
                                    svgImage: AppAssets.imageIcon,
                                    needToShowHintText: areThereNoImages,
                                  ),
                                ),
                              ),
                              if (value.isNotEmpty)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    value.length,
                                    (index) => CustomContainer(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                      ),
                                      height: 100,
                                      width: 100,
                                      border: Border.all(
                                        color: context.colors.textPrimary
                                            .withValues(alpha: 0.5),
                                      ),
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: Image.file(
                                              File(value[index]!.path),
                                            ),
                                          ),
                                          Align(
                                            alignment:
                                                AlignmentDirectional.topEnd,
                                            child: CustomInkWellContainer(
                                              onTap: () async {
                                                reviewImages.value = List.from(
                                                  reviewImages.value,
                                                )..removeAt(index);
                                              },
                                              child: CustomContainer(
                                                height: 20,
                                                width: 20,
                                                color: context
                                                    .colors
                                                    .textPrimary
                                                    .withValues(alpha: 0.4),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.clear_rounded,
                                                    size: 15,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              if (pastValue.isNotEmpty)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    pastValue.length,
                                    (index) => CustomContainer(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                      ),
                                      height: 100,
                                      width: 100,
                                      border: Border.all(
                                        color: context.colors.textPrimary
                                            .withValues(alpha: 0.5),
                                      ),
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: CustomCachedNetworkImage(
                                              networkImageUrl: pastValue[index],
                                            ),
                                          ),
                                          Align(
                                            alignment:
                                                AlignmentDirectional.topEnd,
                                            child: CustomInkWellContainer(
                                              onTap: () async {
                                                pastReviewImages.value =
                                                    List.from(
                                                      pastReviewImages.value,
                                                    )..removeAt(index);
                                                deletedPastReviewImages.add(
                                                  pastValue[index],
                                                );
                                              },
                                              child: CustomContainer(
                                                height: 20,
                                                width: 20,
                                                color: context
                                                    .colors
                                                    .textPrimary
                                                    .withValues(alpha: 0.4),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.clear_rounded,
                                                    size: 15,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const CustomSizedBox(height: 8),
                Row(
                  children: [
                    if (_canDelete) ...[
                      Expanded(
                        child:
                            BlocBuilder<
                              DeleteHandymanReviewCubit,
                              DeleteHandymanReviewState
                            >(
                              builder: (context, state) {
                                return CustomRoundedButton(
                                  onTap: () {
                                    if (state
                                        is DeleteHandymanReviewInProgress) {
                                      return;
                                    }
                                    _showDeleteConfirmation(context);
                                  },
                                  widthPercentage: 1,
                                  backgroundColor: context.colors.textPrimary
                                      .withValues(alpha: 0.05),
                                  titleColor: context.colors.textPrimary,
                                  buttonTitle: "delete".translate(
                                    context: context,
                                  ),
                                  showBorder: false,
                                  child: state is DeleteHandymanReviewInProgress
                                      ? CustomCircularProgressIndicator(
                                          color: context.colors.textPrimary,
                                        )
                                      : null,
                                );
                              },
                            ),
                      ),
                      const CustomSizedBox(width: 10),
                    ],
                    Expanded(
                      child:
                          BlocBuilder<
                            SaveHandymanReviewCubit,
                            SaveHandymanReviewState
                          >(
                            builder: (context, state) {
                              return CustomRoundedButton(
                                onTap: () {
                                  if (state is SaveHandymanReviewInProgress) {
                                    return;
                                  }
                                  if (selectedRating == null ||
                                      selectedRating! < 0) {
                                    UiUtils.showMessage(
                                      context,
                                      'pleaseGiveRating'.translate(
                                        context: context,
                                      ),
                                      ToastificationType.warning,
                                    );
                                    return;
                                  }

                                  context
                                      .read<SaveHandymanReviewCubit>()
                                      .saveReview(
                                        ratingId: widget.ratingId,
                                        orderId: widget.orderId,
                                        handymanId: widget.handymanId,
                                        rating: (selectedRating! + 1)
                                            .toString(),
                                        review: reviewController.text.trim(),
                                        reviewImages: reviewImages.value,
                                        deletedPastReviewImages:
                                            deletedPastReviewImages.toList(),
                                      );
                                },
                                widthPercentage: 1,
                                backgroundColor: context.colors.backgroundBrand,
                                buttonTitle: "submitReview".translate(
                                  context: context,
                                ),
                                showBorder: false,
                                child: state is SaveHandymanReviewInProgress
                                    ? CustomCircularProgressIndicator(
                                        color: context.colors.textInverseLight,
                                      )
                                    : null,
                              );
                            },
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DeletedHandymanReviewSignal {
  const DeletedHandymanReviewSignal._();
  static const instance = DeletedHandymanReviewSignal._();
}
