import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RequestServiceCategorySelectionScreen extends StatefulWidget {
  const RequestServiceCategorySelectionScreen({super.key});

  static Route route(final RouteSettings settings) => CupertinoPageRoute(
    builder: (final context) => const RequestServiceCategorySelectionScreen(),
  );

  @override
  State<RequestServiceCategorySelectionScreen> createState() =>
      _RequestServiceCategorySelectionScreenState();
}

class _RequestServiceCategorySelectionScreenState
    extends State<RequestServiceCategorySelectionScreen> {
  final List<AllCategoryModel> _path = [];

  @override
  void initState() {
    super.initState();
    context.read<AllCategoryCubit>().getAllCategory();
  }

  void _openCategory(final AllCategoryModel category) {
    setState(() => _path.add(category));
  }

  void _goToCrumb(final int index) {
    setState(() => _path.removeRange(index, _path.length));
  }

  bool _goBackOneLevel() {
    if (_path.isEmpty) return false;
    setState(() => _path.removeLast());
    return true;
  }

  void _selectLeafCategory(final AllCategoryModel category) {
    Navigator.pushNamed(
      context,
      requestServiceFormScreen,
      arguments: {
        'categoryId': category.id,
        'categoryName': category.translated_name,
        'categoryPath': [
          for (final AllCategoryModel crumb in _path)
            crumb.translated_name ?? '',
          category.translated_name ?? '',
        ],
      },
    );
  }

  Widget _buildBreadcrumb() => CustomContainer(
    width: double.infinity,
    padding: const EdgeInsets.all(8),
    color: context.colors.backgroundSecondary,
    borderRadius: 8,
    child: Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        for (int i = 0; i < _path.length; i++) ...[
          if (i > 0)
            CustomSvgPicture(
              svgImage:
                  Directionality.of(
                    context,
                  ).toString().contains(TextDirection.RTL.value.toLowerCase())
                  ? AppAssets.backArrow
                  : AppAssets.backArrowLtr,
              height: 16,
              width: 16,
              color: context.colors.iconPrimary,
              avoideResponsive: true,
            ),
          CustomInkWellContainer(
            onTap: () => _goToCrumb(i),
            child: CustomText(
              _path[i].translated_name ?? '',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              showUnderline: true,
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ],
    ),
  );

  Widget _buildCategoryRow(final AllCategoryModel category) {
    final bool hasChildren = category.subCategories?.isNotEmpty ?? false;
    return CustomInkWellContainer(
      onTap: () =>
          hasChildren ? _openCategory(category) : _selectLeafCategory(category),
      child: Row(
        children: [
          ClipOval(
            child: CustomCachedNetworkImage(
              avoideResponsive: true,
              height: 32,
              width: 32,
              networkImageUrl: category.image ?? '',
              fit: BoxFit.cover,
              defaultColourFilter: false,
            ),
          ),
          const CustomSizedBox(width: 12),
          Expanded(
            child: CustomText(
              category.translated_name ?? '',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              maxLines: 1,
              color: context.colors.textPrimary,
            ),
          ),
          CustomSvgPicture(
            svgImage:
                Directionality.of(
                  context,
                ).toString().contains(TextDirection.RTL.value.toLowerCase())
                ? AppAssets.backArrow
                : AppAssets.backArrowLtr,
            height: 24,
            width: 24,
            color: context.colors.iconPrimary,
            avoideResponsive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() => BlocBuilder<AllCategoryCubit, AllCategoryState>(
    builder: (context, state) {
      if (state is AllCategoryFetchFailure) {
        return ErrorContainer(
          errorMessage: state.errorMessage.translate(context: context),
          onTapRetry: () => context.read<AllCategoryCubit>().getAllCategory(),
          showRetryButton: true,
        );
      }
      if (state is! AllCategoryFetchSuccess) {
        return const Center(child: CustomCircularProgressIndicator());
      }

      final List<AllCategoryModel> categories = _path.isEmpty
          ? state.allCategoryList
          : _path.last.subCategories ?? [];

      return SingleChildScrollView(
        padding: EdgeInsets.only(
          top: 16,
          bottom: 16 + MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: CustomContainer(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: context.colors.surfacePrimary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_path.isEmpty)
                CustomText(
                  'allCategories'.translate(context: context),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textPrimary,
                )
              else
                _buildBreadcrumb(),
              const CustomSizedBox(height: 16),
              for (int i = 0; i < categories.length; i++) ...[
                if (i > 0) ...[
                  const CustomSizedBox(height: 16),
                  Divider(height: 1, color: context.colors.borderMuted),
                  const CustomSizedBox(height: 16),
                ],
                _buildCategoryRow(categories[i]),
              ],
            ],
          ),
        ),
      );
    },
  );

  @override
  Widget build(final BuildContext context) => PopScope(
    canPop: _path.isEmpty,
    onPopInvokedWithResult: (final didPop, final result) {
      if (!didPop) _goBackOneLevel();
    },
    child: AnnotatedSafeArea(
      isAnnotated: true,
      applyBottomInset: false,
      child: Scaffold(
        backgroundColor: context.colors.backgroundSecondary,
        appBar: UiUtils.getSimpleAppBar(
          context: context,
          title: 'requestService'.translate(context: context),
          isLeadingIconEnable: true,
          onLeadingTap: _path.isEmpty ? null : () => _goBackOneLevel(),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(70.rh(context)),
            child: const RequestServiceStepper(currentStep: 1),
          ),
        ),
        body: _buildBody(),
      ),
    ),
  );
}
