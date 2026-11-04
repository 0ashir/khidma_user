import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CategoriesBottomSheet extends StatefulWidget {
  const CategoriesBottomSheet({super.key, required this.providerId});

  final String providerId;

  @override
  State<CategoriesBottomSheet> createState() => _CategoriesBottomSheetState();
}

class _CategoriesBottomSheetState extends State<CategoriesBottomSheet> {
  static const double _minListHeightForFewItems = 320;
  static const double _maxListHeightFraction = 0.55;

  final TextEditingController _searchController = TextEditingController();
  final List<AllCategoryModel> _path = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    context.read<AllCategoryCubit>().getAllCategory(
      providerId: widget.providerId,
    );
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCategory(AllCategoryModel category) {
    _searchController.clear();
    setState(() {
      _query = '';
      _path.add(category);
    });
  }

  void _goToCrumb(int index) {
    _searchController.clear();
    setState(() {
      _query = '';
      _path.removeRange(index, _path.length);
    });
  }

  void _selectLeafCategory(AllCategoryModel category) {
    Navigator.pop(context, category);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _path.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          setState(() => _path.removeLast());
        }
      },
      child: CustomContainer(
        color: context.colors.backgroundPrimary,
        margin: EdgeInsetsDirectional.only(
          bottom: MediaQuery.viewPaddingOf(context).bottom,
        ),
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
                        'categories'.translate(context: context),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const CustomSizedBox(height: 8),
                    CustomContainer(
                      height: 1.5,
                      color: context.colors.backgroundSecondary,
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: BlocBuilder<AllCategoryCubit, AllCategoryState>(
                    builder: (context, state) {
                      if (state is AllCategoryFetchFailure) {
                        return ErrorContainer(
                          errorMessage: state.errorMessage.translate(
                            context: context,
                          ),
                          showRetryButton: true,
                          onTapRetry: () => context
                              .read<AllCategoryCubit>()
                              .getAllCategory(providerId: widget.providerId),
                        );
                      }
                      if (state is! AllCategoryFetchSuccess) {
                        return _shimmer();
                      }
                      final List<AllCategoryModel> currentLevel = _path.isEmpty
                          ? state.allCategoryList
                          : (_path.last.subCategories ?? []);
                      final List<AllCategoryModel> visible = _query.isEmpty
                          ? currentLevel
                          : currentLevel
                                .where(
                                  (c) => (c.translated_name ?? '')
                                      .toLowerCase()
                                      .contains(_query),
                                )
                                .toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_path.isNotEmpty) ...[
                            _breadcrumb(context),
                            const CustomSizedBox(height: 12),
                          ],
                          CustomTextFormField(
                            controller: _searchController,
                            hintText: 'searchCategoriesOrSubcategories'
                                .translate(context: context),
                            fillColor: context.colors.backgroundSecondary,
                            bottomPadding: 0,
                            borderColor: context.colors.backgroundSecondary,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(UiUtils.borderRadiusOf12),
                            ),
                            prefix: Padding(
                              padding: const EdgeInsetsDirectional.only(
                                start: 12,
                              ),
                              child: CustomSvgPicture(
                                svgImage: AppAssets.search,
                                color: context.colors.iconTertiary,
                                boxFit: BoxFit.scaleDown,
                              ),
                            ),
                          ),
                          const CustomSizedBox(height: 16),
                          Flexible(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: visible.isNotEmpty
                                    ? _minListHeightForFewItems
                                    : 0,
                                maxHeight:
                                    MediaQuery.sizeOf(context).height *
                                    _maxListHeightFraction,
                              ),
                              child: visible.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 24,
                                      ),
                                      child: Center(
                                        child: CustomText(
                                          'noDataFound'.translate(
                                            context: context,
                                          ),
                                          fontSize: 14,
                                          color: context.colors.textSecondary,
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      shrinkWrap: true,
                                      physics: const ClampingScrollPhysics(),
                                      itemCount: visible.length,
                                      separatorBuilder: (_, __) =>
                                          CustomSizedBox(
                                            height: 1,
                                            width: double.infinity,
                                            child: DashedRect(
                                              color:
                                                  context.colors.borderDefault,
                                              strokeWidth: 1,
                                              gap: 4,
                                            ),
                                          ),
                                      itemBuilder: (context, index) =>
                                          _categoryRow(context, visible[index]),
                                    ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _breadcrumb(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: List.generate(_path.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: CustomSvgPicture(
              svgImage:
                  Directionality.of(
                    context,
                  ).toString().contains(TextDirection.RTL.value.toLowerCase())
                  ? AppAssets.backArrow
                  : AppAssets.backArrowLtr,
              avoideResponsive: true,
              height: 20,
              width: 20,
              color: context.colors.iconPrimary,
            ),
          );
        }
        final int crumbIndex = i ~/ 2;
        return CustomInkWellContainer(
          onTap: () => _goToCrumb(crumbIndex),
          child: CustomText(
            _path[crumbIndex].translated_name ?? '',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: context.colors.textPrimary,
            showUnderline: true,
          ),
        );
      }),
    );
  }

  Widget _categoryRow(BuildContext context, AllCategoryModel category) {
    final bool hasChildren =
        category.subCategories != null && category.subCategories!.isNotEmpty;
    return CustomInkWellContainer(
      onTap: () =>
          hasChildren ? _openCategory(category) : _selectLeafCategory(category),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            CustomImageContainer(
              borderRadius: UiUtils.borderRadiusOf8,
              imageURL: category.image ?? '',
              height: 40,
              width: 40,
              boxFit: BoxFit.cover,
              boxShadow: const [],
            ),
            const CustomSizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    category.translated_name ?? '',
                    fontSize: 14,
                    maxLines: 1,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textPrimary,
                  ),
                  const CustomSizedBox(height: 4),
                  CustomText(
                    '${category.servicesCount ?? 0} ${"services".translate(context: context)}',
                    fontSize: 12,
                    color: context.colors.textSecondary,
                  ),
                ],
              ),
            ),
            if (hasChildren)
              CustomSvgPicture(
                svgImage:
                    Directionality.of(
                      context,
                    ).toString().contains(TextDirection.RTL.value.toLowerCase())
                    ? AppAssets.backArrow
                    : AppAssets.backArrowLtr,
                avoideResponsive: true,
                height: 20,
                width: 20,
                color: context.colors.iconPrimary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _shimmer() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        UiUtils.numberOfShimmerContainer,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: CustomShimmerLoadingContainer(
            height: 56,
            borderRadius: UiUtils.borderRadiusOf8,
          ),
        ),
      ),
    );
  }
}
