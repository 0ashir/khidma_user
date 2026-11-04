import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

/// this screen stays agnostic to whether it's rating services or handymen.
class RateableCardConfig {
  RateableCardConfig({
    required this.avatarUrl,
    required this.avatarSize,
    required this.avatarRadius,
    required this.titleWidget,
    this.existingRating,
    this.existingReview = '',
    this.existingImages = const [],
    required this.onSubmit,
    this.onSuccess,
  });

  final String avatarUrl;
  final double avatarSize;
  final double avatarRadius;

  final Widget titleWidget;

  final int? existingRating;
  final String existingReview;
  final List<String> existingImages;

  final Future<Map<String, dynamic>> Function({
    required int rating,
    required String review,
    required List<XFile> newImages,
    required List<String> deletedImages,
  })
  onSubmit;

  /// Called with the API's `data` payload right after a successful submit,
  /// so the caller can patch its own local model in place instead of the
  /// whole screen refetching booking details.
  final void Function(Map<String, dynamic>? data)? onSuccess;
}

class RateReviewsScreen extends StatefulWidget {
  const RateReviewsScreen({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<RateableCardConfig> items;

  @override
  State<RateReviewsScreen> createState() => _RateReviewsScreenState();
}

class _ReviewDraft {
  _ReviewDraft(final RateableCardConfig config)
    : rating = (config.existingRating ?? 0) > 0 ? config.existingRating : null,
      reviewController = TextEditingController(text: config.existingReview),
      pastImages = List<String>.from(config.existingImages);

  int? rating;
  final TextEditingController reviewController;
  final List<String> pastImages;
  List<XFile> newImages = [];
  final Set<String> deletedPastImages = {};

  void dispose() => reviewController.dispose();
}

class _RateReviewsScreenState extends State<RateReviewsScreen> {
  late final List<_ReviewDraft> _drafts = widget.items
      .map(_ReviewDraft.new)
      .toList();

  late int _activeIndex = () {
    final int firstUnrated = _drafts.indexWhere(
      (final d) => (d.rating ?? 0) <= 0,
    );
    return firstUnrated >= 0 ? firstUnrated : 0;
  }();

  final ImagePicker _imagePicker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void dispose() {
    for (final draft in _drafts) {
      draft.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImages(final int index) async {
    final List<XFile> picked = await _imagePicker.pickMultiImage();
    if (picked.isEmpty) return;
    setState(() {
      _drafts[index].newImages = [..._drafts[index].newImages, ...picked];
    });
  }

  Future<void> _submit() async {
    final List<int> ratedIndices = [
      for (int i = 0; i < _drafts.length; i++)
        if ((_drafts[i].rating ?? 0) > 0) i,
    ];

    if (ratedIndices.isEmpty) {
      UiUtils.showMessage(
        context,
        'pleaseGiveRating'.translate(context: context),
        ToastificationType.warning,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      for (final index in ratedIndices) {
        final _ReviewDraft draft = _drafts[index];
        final response = await widget.items[index].onSubmit(
          rating: draft.rating!,
          review: draft.reviewController.text.trim(),
          newImages: draft.newImages,
          deletedImages: draft.deletedPastImages.toList(),
        );
        if (response['error'] == true) {
          throw ApiException(response['message']?.toString() ?? '');
        }
        widget.items[index].onSuccess?.call(
          response['data'] as Map<String, dynamic>?,
        );
      }
      if (!mounted) return;
      UiUtils.showMessage(
        context,
        'reviewSubmittedSuccessfully'.translate(context: context),
        ToastificationType.success,
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      UiUtils.showMessage(
        context,
        'somethingWentWrong'.translate(context: context),
        ToastificationType.error,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildInteractiveStars(final int index) {
    final int rating = _drafts[index].rating ?? 0;
    final bool isTablet = ResponsiveHelper.isTabletDevice(context);
    return Row(
      mainAxisAlignment: isTablet
          ? MainAxisAlignment.start
          : MainAxisAlignment.spaceBetween,
      spacing: isTablet ? 12 : 0,
      children: List.generate(5, (final starIndex) {
        final bool filled = starIndex < rating;
        return CustomInkWellContainer(
          borderRadius: BorderRadius.circular(8),
          onTap: () => setState(() => _drafts[index].rating = starIndex + 1),
          child: CustomContainer(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            color: context.colors.backgroundPrimary,
            border: Border.all(color: context.colors.borderDefault),
            borderRadius: 8,
            alignment: Alignment.center,
            child: CustomSvgPicture(
              avoideResponsive: true,
              svgImage: filled ? AppAssets.icStar : AppAssets.starOutline,
              height: 20,
              width: 20,
              color: filled
                  ? context.colors.iconWarning
                  : context.colors.iconSecondary,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCollapsedStars(final int index) {
    final int rating = _drafts[index].rating ?? 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: List.generate(5, (final starIndex) {
        final bool filled = starIndex < rating;
        return CustomSvgPicture(
          avoideResponsive: true,
          svgImage: filled ? AppAssets.icStar : AppAssets.starOutline,
          height: 16,
          width: 16,
          color: filled
              ? context.colors.iconWarning
              : context.colors.iconSecondary,
        );
      }),
    );
  }

  Widget _buildHeaderRow(final int index) {
    final RateableCardConfig config = widget.items[index];
    final bool isActive = _activeIndex == index;
    return CustomInkWellContainer(
      showRippleEffect: false,
      onTap: () => setState(() => _activeIndex = isActive ? -1 : index),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(config.avatarRadius),
            child: CustomCachedNetworkImage(
              avoideResponsive: true,
              height: config.avatarSize,
              width: config.avatarSize,
              networkImageUrl: config.avatarUrl,
              fit: BoxFit.cover,
            ),
          ),
          const CustomSizedBox(width: 12),
          Expanded(child: config.titleWidget),
          CustomSvgPicture(
            avoideResponsive: true,
            svgImage: isActive ? AppAssets.upArrow : AppAssets.downArrow,
            color: context.colors.iconPrimary,
            height: 24,
            width: 24,
          ),
          // Icon(
          //   isActive ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          //   color: context.colors.iconPrimary,
          // ),
        ],
      ),
    );
  }

  Widget _buildReviewInput(final int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        CustomText(
          'review'.translate(context: context),
          fontSize: 12,
          color: context.colors.textPrimary,
        ),
        CustomContainer(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: context.colors.backgroundSecondary,
          border: Border.all(color: context.colors.borderDefault),
          borderRadius: 8,
          child: TextField(
            controller: _drafts[index].reviewController,
            maxLines: 4,
            minLines: 4,
            style: TextStyle(fontSize: 12, color: context.colors.textPrimary),
            decoration: InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              hintText: 'yourReviewHelpsOtherCustomers'.translate(
                context: context,
              ),
              hintStyle: TextStyle(
                fontSize: 12,
                color: context.colors.textTertiary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageThumb({
    required final Widget child,
    required final VoidCallback onRemove,
  }) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: SizedBox(width: 32, height: 32, child: child),
          ),
          Positioned(
            right: -4,
            top: -4,
            child: CustomInkWellContainer(
              onTap: onRemove,
              child: CustomContainer(
                width: 16,
                height: 16,
                color: context.colors.backgroundPrimary,
                shape: BoxShape.circle,
                alignment: Alignment.center,
                child: Icon(
                  Icons.close,
                  size: 10,
                  color: context.colors.iconPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadRow(final int index) {
    final _ReviewDraft draft = _drafts[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        CustomText(
          'addImage'.translate(context: context),
          fontSize: 12,
          color: context.colors.textPrimary,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 12,
            children: [
              CustomInkWellContainer(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _pickImages(index),
                child: CustomContainer(
                  width: 36,
                  height: 36,
                  padding: const EdgeInsets.all(8),
                  color: context.colors.backgroundSecondary,
                  borderRadius: 12,
                  child: Icon(
                    Icons.upload_rounded,
                    size: 20,
                    color: context.colors.iconPrimary,
                  ),
                ),
              ),
              for (int i = 0; i < draft.pastImages.length; i++)
                _buildImageThumb(
                  child: CustomCachedNetworkImage(
                    avoideResponsive: true,
                    height: 32,
                    width: 32,
                    networkImageUrl: draft.pastImages[i],
                    fit: BoxFit.cover,
                  ),
                  onRemove: () => setState(() {
                    draft.deletedPastImages.add(draft.pastImages[i]);
                    draft.pastImages.removeAt(i);
                  }),
                ),
              for (int i = 0; i < draft.newImages.length; i++)
                _buildImageThumb(
                  child: Image.file(
                    File(draft.newImages[i].path),
                    height: 32,
                    width: 32,
                    fit: BoxFit.cover,
                  ),
                  onRemove: () => setState(() => draft.newImages.removeAt(i)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(final int index) {
    final bool isActive = _activeIndex == index;
    return CustomContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: context.colors.surfacePrimary,
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          _buildHeaderRow(index),
          if (isActive) ...[
            _buildInteractiveStars(index),
            _buildReviewInput(index),
            _buildImageUploadRow(index),
          ] else ...[
            CustomContainer(height: 1, color: context.colors.borderDefault),
            _buildCollapsedStars(index),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(final BuildContext context) => AnnotatedSafeArea(
    isAnnotated: true,
    applyBottomInset: false,
    child: Scaffold(
      appBar: UiUtils.getSimpleAppBar(context: context, title: widget.title),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  for (int i = 0; i < widget.items.length; i++) _buildCard(i),
                ],
              ),
            ),
          ),
          ClipShadowBottom(
            child: CustomContainer(
              color: context.colors.backgroundPrimary,
              padding: const EdgeInsets.all(
                16,
              ).copyWith(bottom: 16 + MediaQuery.viewPaddingOf(context).bottom),
              boxShadow: [
                BoxShadow(
                  color: context.colors.overlayFooterShadow,
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
              child: CustomInkWellContainer(
                borderRadius: BorderRadius.circular(12),
                onTap: _isSubmitting ? null : _submit,
                child: CustomContainer(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: context.colors.backgroundBrand,
                  borderRadius: 12,
                  alignment: Alignment.center,
                  child: _isSubmitting
                      ? CustomCircularProgressIndicator(
                          color: context.colors.textInverseLight,
                        )
                      : CustomText(
                          'submitReviews'.translate(context: context),
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
