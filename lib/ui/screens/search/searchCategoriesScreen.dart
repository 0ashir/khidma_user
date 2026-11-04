import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchCategoriesScreen extends StatefulWidget {
  const SearchCategoriesScreen({super.key});

  static Route route(final RouteSettings routeSettings) => CupertinoPageRoute(
    builder: (final _) => BlocProvider<CategoryCubit>(
      create: (final _) => CategoryCubit(CategoryRepository()),
      child: const SearchCategoriesScreen(),
    ),
  );

  @override
  State<SearchCategoriesScreen> createState() => _SearchCategoriesScreenState();
}

class _SearchCategoriesScreenState extends State<SearchCategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  List<String> _recentSearches = [];

  bool get _isSearching => _searchController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _recentSearches = HiveRepository.getRecentCategorySearches;
    _scrollController.addListener(_fetchMoreOnScroll);
    _searchController.addListener(_onSearchChanged);
    // autofocus can get swallowed by the CupertinoPageRoute push transition —
    // request focus once it settles instead of relying on TextField.autofocus.
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.removeListener(_fetchMoreOnScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _fetchCategories() {
    context.read<CategoryCubit>().getCategory();
  }

  void _fetchMoreOnScroll() {
    if (!context.read<CategoryCubit>().hasMoreCategory()) return;
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<CategoryCubit>().fetchMoreCategory();
    }
  }

  void _onSearchChanged() {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _onSubmitSearch(_searchController.text);
    });
  }

  void _onTapRecentSearch(final String term) => _onSubmitSearch(term);

  void _onSubmitSearch(final String query) {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) return;
    _debounce?.cancel();
    HiveRepository.addRecentCategorySearch(trimmed);
    setState(() => _recentSearches = HiveRepository.getRecentCategorySearches);
    Navigator.pushNamed(
      context,
      searchResultScreen,
      arguments: {'search': trimmed},
    );
  }

  void _onClearRecentSearches() {
    HiveRepository.clearRecentCategorySearches();
    setState(() => _recentSearches = []);
  }

  Widget _searchField() => CustomContainer(
    color: context.colors.backgroundPrimary,
    borderRadius: UiUtils.borderRadiusOf12,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        CustomSvgPicture(
          avoideResponsive: true,
          svgImage: AppAssets.search,
          height: 24,
          width: 24,
          color: context.colors.iconSecondary,
        ),
        const CustomSizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            textInputAction: TextInputAction.search,
            onSubmitted: _onSubmitSearch,
            style: TextStyle(fontSize: 14, color: context.colors.textPrimary),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              hintText: 'searchCategories'.translate(context: context),
              hintStyle: TextStyle(
                fontSize: 14,
                color: context.colors.textTertiary,
              ),
            ),
          ),
        ),
        if (_isSearching)
          CustomInkWellContainer(
            onTap: () => _searchController.clear(),
            child: Icon(
              Icons.close,
              size: 20,
              color: context.colors.iconSecondary,
            ),
          ),
      ],
    ),
  );

  Widget _recentSearchSection({required final bool isTablet}) {
    return CustomContainer(
      width: double.infinity,
      color: context.colors.backgroundPrimary,
      borderRadius: UiUtils.borderRadiusOf12,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomText(
                  'recentSearched'.translate(context: context),
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: isTablet ? FontWeight.w500 : FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
              CustomInkWellContainer(
                onTap: _onClearRecentSearches,
                child: CustomText(
                  'clear'.translate(context: context),
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: isTablet ? FontWeight.w500 : null,
                  color: context.colors.textBrand,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches
                .map(
                  (final term) => CustomInkWellContainer(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _onTapRecentSearch(term),
                    child: CustomContainer(
                      color: context.colors.backgroundSecondary,
                      borderRadius: 16,
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8,
                        children: [
                          Icon(
                            Icons.history,
                            size: isTablet ? 18 : 16,
                            color: context.colors.iconSecondary,
                          ),
                          CustomText(
                            term,
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: isTablet
                                ? FontWeight.w400
                                : FontWeight.w500,
                            color: context.colors.textPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _categoryRow(
    final CategoryModel category, {
    required final bool isTablet,
  }) {
    final bool showServices = context
        .read<SystemSettingCubit>()
        .isCategoryDetailsViewTypeServices;
    final String count = showServices
        ? (category.totalServices ?? '0')
        : (category.totalProviders ?? '0');
    final bool hasChildren = count.convertToInt() != 0;
    return CustomInkWellContainer(
      borderRadius: BorderRadius.circular(8),
      onTap: hasChildren
          ? () => UiUtils.navigateToCategoryDetails(
              context,
              categoryId: category.id,
              categoryName: category.name,
            )
          : null,
      child: CustomContainer(
        width: double.infinity,
        color: context.colors.backgroundPrimary,
        borderRadius: 8,
        padding: const EdgeInsets.all(8),
        child: Row(
          spacing: 8,
          children: [
            CustomContainer(
              width: isTablet ? 40 : 48,
              height: isTablet ? 40 : 48,
              shape: BoxShape.circle,
              color: context.colors.backgroundSecondary,
              clipBehavior: Clip.antiAlias,
              padding: EdgeInsets.all(isTablet ? 8 : 12),
              child: CustomCachedNetworkImage(
                networkImageUrl: category.categoryImage ?? '',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                defaultColourFilter: false,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  CustomText(
                    category.name ?? '',
                    maxLines: 1,
                    fontSize: 14,
                    color: context.colors.textPrimary,
                  ),
                  CustomText(
                    count.convertToInt() == 0
                        ? 'comingsoon'.translate(context: context)
                        : showServices
                        ? '$count ${count.convertToInt() > 1 ? 'services'.translate(context: context) : 'service'.translate(context: context)}'
                        : '$count ${count.convertToInt() > 1 ? 'providers'.translate(context: context) : 'provider'.translate(context: context)}',
                    maxLines: 1,
                    fontSize: isTablet ? 14 : 11,
                    color: context.colors.textTertiary,
                  ),
                ],
              ),
            ),
            if (hasChildren)
              CustomContainer(
                padding: const EdgeInsets.all(8),
                color: context.colors.backgroundSecondary,
                shape: BoxShape.circle,
                child: CustomSvgPicture(
                  avoideResponsive: true,
                  svgImage: AppAssets.rightArrow,
                  height: 16,
                  width: 16,
                  color: context.colors.iconPrimary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _categoryList(
    final List<CategoryModel> categories, {
    required final bool isTablet,
  }) {
    final List<Widget> rows = categories
        .map((final category) => _categoryRow(category, isTablet: isTablet))
        .toList();
    return isTablet
        ? EqualHeightGrid(children: rows)
        : Column(spacing: 12, children: rows);
  }

  @override
  Widget build(
    final BuildContext context,
  ) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: UiUtils.getSystemUiOverlayStyle(context: context),
    child: AnnotatedSafeArea(
      isAnnotated: true,
      applyBottomInset: false,
      child: Scaffold(
        appBar: UiUtils.getSimpleAppBar(
          context: context,
          title: 'explore'.translate(context: context),
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        body: CustomContainer(
          color: context.colors.backgroundSecondary,
          child: BlocBuilder<CategoryCubit, CategoryState>(
            builder: (final context, final state) {
              final bool isTablet = ResponsiveHelper.isTabletDevice(context);
              Widget content;
              if (state is CategoryFetchFailure) {
                content = ErrorContainer(
                  errorMessage: state.errorMessage.translate(context: context),
                  showRetryButton: true,
                  onTapRetry: _fetchCategories,
                );
              } else if (state is! CategoryFetchSuccess) {
                content = Center(
                  child: CustomCircularProgressIndicator(
                    color: context.colors.iconBrand,
                  ),
                );
              } else if (state.categoryList.isEmpty) {
                content = Center(
                  child: NoDataFoundWidget(
                    titleKey: 'noServicesFound'.translate(context: context),
                    subtitleKey: 'noServicesFoundSubTitle'.translate(
                      context: context,
                    ),
                  ),
                );
              } else {
                content = ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    bottom: UiUtils.getScrollViewBottomPadding(context),
                  ),
                  children: [
                    CustomText(
                      'exploreCategories'.translate(context: context),
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: isTablet ? FontWeight.w500 : FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                    const CustomSizedBox(height: 8),
                    _categoryList(state.categoryList, isTablet: isTablet),
                    if (state.isLoadingMore)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: CustomCircularProgressIndicator(
                            color: context.colors.iconBrand,
                          ),
                        ),
                      ),
                  ],
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    _searchField(),
                    if (!_isSearching && _recentSearches.isNotEmpty)
                      _recentSearchSection(isTablet: isTablet),
                    Expanded(child: content),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}
