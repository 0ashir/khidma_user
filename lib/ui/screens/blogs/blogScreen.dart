import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/cubits/blogs/blogCategoryCubit.dart';
import 'package:e_demand/cubits/blogs/blogTagsCubit.dart';
import 'package:e_demand/cubits/blogs/blogsCubit.dart';
import 'package:e_demand/data/baseState.dart';
import 'package:e_demand/data/model/blogs/blogCategoryModel.dart';
import 'package:e_demand/data/model/blogs/blogModel.dart';
import 'package:e_demand/ui/screens/blogs/widgets/allTagsBottomSheet.dart';
import 'package:e_demand/ui/screens/blogs/widgets/blogCard.dart';

import 'package:e_demand/ui/widgets/paginatedListview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BlogsScreen extends StatefulWidget {
  final String? tagSlug;

  const BlogsScreen({super.key, this.tagSlug});

  static Route route(final RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>?;
    return CupertinoPageRoute(
      builder: (final BuildContext context) =>
          BlogsScreen(tagSlug: arguments?['tagSlug'] as String?),
    );
  }

  @override
  State<BlogsScreen> createState() => _BlogsScreenState();
}

class _BlogsScreenState extends State<BlogsScreen> {
  String? selectedCategoryId;
  String? selectedTagSlug;

  @override
  void initState() {
    super.initState();
    selectedTagSlug = widget.tagSlug;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BlogCategoryCubit>().getBlogCategories();
      context.read<BlogTagsCubit>().getBlogTags();
      context.read<BlogsCubit>().getBlogs(tagSlug: selectedTagSlug);
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategoryId = category == 'all' ? null : category;
      // Clear tag filter when category is selected
      selectedTagSlug = null;
    });
    context.read<BlogsCubit>().getBlogs(
      categoryId: category == 'all' ? null : category,
      tagSlug: null,
    );
  }

  void _onTagSelected(String tagSlug) {
    setState(() {
      // Tapping the active tag again clears the filter
      selectedTagSlug = selectedTagSlug == tagSlug ? null : tagSlug;
      selectedCategoryId = null;
    });
    context.read<BlogsCubit>().getBlogs(tagSlug: selectedTagSlug);
  }

  // Tablet shows 3 blog cards per row (16 gap); phone keeps the single column.
  int get _columns => ResponsiveHelper.isTabletDevice(context) ? 3 : 1;

  double get _columnSpacing => _columns > 1 ? 16 : 12;

  Widget _getBlogShimmerLoading({required final int numberOfShimmerContainer}) {
    final int columns = _columns;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        top: 10,
        left: 10,
        right: 10,
        bottom:
            UiUtils.getScrollViewBottomPadding(context) +
            10 +
            MediaQuery.viewPaddingOf(context).bottom,
      ),
      itemCount: (numberOfShimmerContainer / columns).ceil(),
      itemBuilder: (context, index) {
        if (columns > 1) {
          return Padding(
            padding: EdgeInsets.only(bottom: _columnSpacing),
            child: EqualHeightGrid(
              columns: columns,
              spacing: _columnSpacing,
              children: List.generate(
                columns,
                (_) => const CustomShimmerLoadingContainer(
                  height: 240,
                  borderRadius: 10,
                ),
              ),
            ),
          );
        }
        return CustomShimmerLoadingContainer(
          margin: EdgeInsets.all(16.rw(context)),
          height: 240,
          borderRadius: 10,
        );
      },
    );
  }

  Widget _buildQuickFilterBar() => CustomContainer(
    width: double.infinity,
    color: context.colors.backgroundPrimary,
    padding: const EdgeInsets.symmetric(vertical: 16),
    boxShadow: [
      BoxShadow(
        blurRadius: 16,
        color: context.colors.overlayHeaderShadow,
        offset: const Offset(0, 8),
      ),
    ],
    child: BlocBuilder<BlogCategoryCubit, BaseState>(
      builder: (context, state) {
        if (state is! SuccessState<List<BlogCategoryModel>>) {
          return const SizedBox.shrink();
        }

        final categories = state.data;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: categories.map((category) {
              final bool isSelected =
                  (selectedCategoryId == null && category.id == 'all') ||
                  selectedCategoryId == category.id;
              final String label = category.id == 'all'
                  ? "${'all'.translate(context: context)} (${category.blogCount})"
                  : category.translatedName;

              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: FlatOutlinedButton(
                  name: label,
                  isSelected: isSelected,
                  onTap: () => _onCategorySelected(category.id),
                ),
              );
            }).toList(),
          ),
        );
      },
    ),
  );

  Widget _buildPopularTagsCard() => BlocBuilder<BlogTagsCubit, BaseState>(
    builder: (context, state) {
      if (state is! SuccessState<List<BlogTag>>) return const SizedBox.shrink();

      final tags = state.data;
      if (tags.isEmpty) return const SizedBox.shrink();

      final bool canExpand = tags.length > 6;
      final visibleTags = tags.take(6).toList();

      return Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 16),
        child: CustomContainer(
          color: context.colors.surfacePrimary,
          borderRadius: UiUtils.borderRadiusOf12,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomText(
                        'popularTags'.translate(context: context),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    if (canExpand)
                      CustomInkWellContainer(
                        onTap: () => _showAllTagsSheet(tags),
                        child: CustomText(
                          'viewAll'.translate(context: context),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: context.colors.textBrand,
                        ),
                      ),
                  ],
                ),
              ),
              CustomContainer(height: 1, color: context.colors.borderDefault),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: visibleTags.map((tag) {
                    final bool isSelected = selectedTagSlug == tag.slug;
                    return FlatOutlinedButton(
                      name: tag.translatedName,
                      isSelected: isSelected,
                      onTap: () => _onTagSelected(tag.slug),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  void _showAllTagsSheet(List<BlogTag> tags) {
    UiUtils.showBottomSheet(
      context: context,
      enableDrag: true,
      isScrollControlled: true,
      useSafeArea: true,
      child: AllTagsBottomSheet(
        tags: tags,
        selectedTagSlug: selectedTagSlug,
        onTagSelected: _onTagSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedSafeArea(
      isAnnotated: true,
      applyBottomInset: false,
      child: InterstitialAdWidget(
        child: Scaffold(
          backgroundColor: context.colors.backgroundSecondary,
          appBar: UiUtils.getSimpleAppBar(
            context: context,
            title: 'blogs'.translate(context: context),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(68.rh(context)),
              child: _buildQuickFilterBar(),
            ),
          ),
          bottomNavigationBar: const BannerAdWidget(applyBottomInset: true),
          body: UiUtils.restoreBottomInset(
            inset: MediaQuery.viewPaddingOf(context).bottom,
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<BlogsCubit>().getBlogs(
                  categoryId: selectedCategoryId,
                  tagSlug: selectedTagSlug,
                );
              },
              child: BlocConsumer<BlogsCubit, BaseState>(
                listener: (context, state) {
                  if (state is FailureState) {
                    UiUtils.showMessage(
                      context,
                      state.message,
                      ToastificationType.error,
                    );
                  }
                },
                builder: (context, state) {
                  if (state is LoadingState) {
                    return _getBlogShimmerLoading(numberOfShimmerContainer: 10);
                  }

                  if (state is FailureState) {
                    return ErrorContainer(
                      errorMessage: state.message,
                      showRetryButton: true,
                      onTapRetry: () {
                        context.read<BlogsCubit>().getBlogs(
                          categoryId: selectedCategoryId,
                          tagSlug: selectedTagSlug,
                        );
                      },
                    );
                  }

                  if (state is SuccessState<List<BlogModel>>) {
                    return PaginatedListView(
                      header: _buildPopularTagsCard(),
                      noDataTitleKey: 'noBlogsAvailable'.translate(
                        context: context,
                      ),
                      items: state.data,
                      itemBuilder: (context, blog) {
                        return InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              blogDetailsScreen,
                              arguments: {'blogId': blog.id},
                            );
                          },
                          child: BlogCard(blog: blog),
                        );
                      },
                      isLoadingMoreError: state.isLoadingMoreError,
                      onLoadMore: () async {
                        context.read<BlogsCubit>().getMoreBlogs(
                          categoryId: selectedCategoryId,
                          tagSlug: selectedTagSlug,
                        );
                      },
                      isLoadingMore: state.isLoadingMoreData,
                      columns: _columns,
                      columnSpacing: _columnSpacing,
                      separatorBuilder: (context, index) =>
                          CustomSizedBox(height: _columnSpacing),
                      padding: EdgeInsets.all(16.rw(context)).copyWith(
                        bottom:
                            UiUtils.getScrollViewBottomPadding(context) +
                            MediaQuery.viewPaddingOf(context).bottom,
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
