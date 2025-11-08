import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/cubits/blogs/blogCategoryCubit.dart';
import 'package:e_demand/cubits/blogs/blogsCubit.dart';
import 'package:e_demand/data/baseState.dart';
import 'package:e_demand/data/model/blogs/blogCategoryModel.dart';
import 'package:e_demand/data/model/blogs/blogModel.dart';
import 'package:e_demand/ui/screens/blogs/widgets/blogCard.dart';
import 'package:e_demand/ui/screens/blogs/widgets/categoryFilterBottomSheet.dart';

import 'package:e_demand/ui/widgets/paginatedListview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BlogsScreen extends StatefulWidget {
  const BlogsScreen({super.key});

  static Route route(final RouteSettings routeSettings) => CupertinoPageRoute(
        builder: (final BuildContext context) => const BlogsScreen(),
      );

  @override
  State<BlogsScreen> createState() => _BlogsScreenState();
}

class _BlogsScreenState extends State<BlogsScreen> {
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BlogCategoryCubit>().getBlogCategories();
      context.read<BlogsCubit>().getBlogs();
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategoryId = category == 'all' ? null : category;
    });
    context
        .read<BlogsCubit>()
        .getBlogs(categoryId: category == 'all' ? null : category);
    Navigator.pop(context);
  }

  Widget _getBlogShimmerLoading({required final int numberOfShimmerContainer}) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        bottom: UiUtils.getScrollViewBottomPadding(context),
      ),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        itemCount: numberOfShimmerContainer,
        itemBuilder: (context, index) {
          return CustomShimmerLoadingContainer(
            margin: EdgeInsets.all(16.rw(context)),
            height: 240,
            borderRadius: 10,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UiUtils.getSimpleAppBar(
        context: context,
        title: 'blogs'.translate(context: context),
        // fontWeight: FontWeight.w600,
        // fontSize: 18,
        elevation: 0.5,
        actions: [
          IconButton(
            onPressed: () {
              _showCategoryFilter();
            },
            icon: CustomSvgPicture(
              svgImage: AppAssets.short,
              color: context.colorScheme.accentColor,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<BlogsCubit>().getBlogs(categoryId: selectedCategoryId);
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
              return _getBlogShimmerLoading(
                numberOfShimmerContainer: 10,
              );
            }

            if (state is FailureState) {
              return ErrorContainer(
                errorMessage: state.message,
                showRetryButton: true,
                onTapRetry: () {
                  context
                      .read<BlogsCubit>()
                      .getBlogs(categoryId: selectedCategoryId);
                },
              );
            }

            if (state is SuccessState<List<BlogModel>>) {
              if (state.data.isEmpty) {
                return NoDataFoundWidget(
                  titleKey: 'noBlogsAvailable'.translate(context: context),
                );
              }

              return PaginatedListView(
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
                  context
                      .read<BlogsCubit>()
                      .getMoreBlogs(categoryId: selectedCategoryId);
                },
                isLoadingMore: state.isLoadingMoreData,
                separatorBuilder: (context, index) =>
                    SizedBox(height: 16.rh(context)),
                padding: EdgeInsets.all(16.rw(context)),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _showCategoryFilter() {
    UiUtils.showBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      enableDrag: true,
      child: BlocBuilder<BlogCategoryCubit, BaseState>(
        builder: (context, state) {
          if (state is LoadingState) {
            return SizedBox(
              height: 200.rh(context),
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is FailureState) {
            return SizedBox(
              height: 200.rh(context),
              child: Center(
                child: CustomText(
                  state.message,
                  color: context.colorScheme.error,
                ),
              ),
            );
          }

          if (state is SuccessState<List<BlogCategoryModel>>) {
            return CategoryFilterBottomSheet(
              categories: state.data,
              selectedCategory: selectedCategoryId,
              onCategorySelected: _onCategorySelected,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
