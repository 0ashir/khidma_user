import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/cubits/blogs/blogsCubit.dart';
import 'package:e_demand/data/baseState.dart';
import 'package:e_demand/data/model/blogs/blogModel.dart';
import 'package:e_demand/data/repository/blogsRepository.dart';
import 'package:e_demand/ui/screens/blogs/widgets/blogCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class BlogDetailsScreen extends StatefulWidget {
  final String blogId;

  const BlogDetailsScreen({super.key, required this.blogId});

  static Route route(final RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>;
    return CupertinoPageRoute(
      builder: (final BuildContext context) => BlocProvider(
        create: (context) => BlogDetailsCubit(BlogsRepository()),
        child: BlogDetailsScreen(blogId: arguments['blogId'] as String),
      ),
    );
  }

  @override
  State<BlogDetailsScreen> createState() => _BlogDetailsScreenState();
}

class _BlogDetailsScreenState extends State<BlogDetailsScreen> {
  late BlogDetailsCubit _blogDetailsCubit;

  @override
  void initState() {
    super.initState();
    _blogDetailsCubit = context.read<BlogDetailsCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _blogDetailsCubit.getBlogDetails(widget.blogId);
    });
  }

  Widget _getBlogDetailsShimmerLoading() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.rw(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomShimmerLoadingContainer(
            margin: EdgeInsets.all(16.rw(context)),
            height: 260.rh(context),
            borderRadius: 10,
          ),
          CustomShimmerLoadingContainer(
            margin: EdgeInsets.all(16.rw(context)),
            height: 20.rh(context),
            width: 260.rw(context),
            borderRadius: 10,
          ),
          CustomShimmerLoadingContainer(
            margin: EdgeInsets.all(16.rw(context)),
            height: 100.rh(context),
            width: double.infinity,
            borderRadius: 10,
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: 2,
            itemBuilder: (context, index) {
              return CustomShimmerLoadingContainer(
                height: 60.rh(context),
                margin: EdgeInsets.symmetric(
                  horizontal: 16.rw(context),
                  vertical: 5.rh(context),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleShareBlog(BlogModel blog) async {
    final String shareURL =
        '$deepLinkDomain/blog-details/${blog.slug}?lang=${HiveRepository.getCurrentLanguage()!.languageCode}';
    await UiUtils.share(context: context, shareURL, subject: "Share Blog");
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedSafeArea(
      isAnnotated: true,
      applyBottomInset: false,
      child: Scaffold(
        backgroundColor: context.colors.backgroundSecondary,
        appBar: UiUtils.getSimpleAppBar(
          context: context,
          title: 'blogDetails'.translate(context: context),
          isLeadingIconEnable: true,
          elevation: 0.5,
          actions: [
            BlocBuilder<BlogDetailsCubit, BaseState>(
              builder: (context, state) {
                if (state is! SuccessState<BlogDetailsData>) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: CustomInkWellContainer(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => _handleShareBlog(state.data.blogDetails),
                    child: CustomContainer(
                      color: context.colors.backgroundPrimary,
                      shape: BoxShape.circle,
                      padding: const EdgeInsets.all(8),
                      child: CustomSvgPicture(
                        svgImage: AppAssets.drShare,
                        height: 24,
                        width: 24,
                        color: context.colors.iconPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<BlogDetailsCubit, BaseState>(
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
              return _getBlogDetailsShimmerLoading();
            }

            if (state is FailureState) {
              return ErrorContainer(
                errorMessage: state.message,
                showRetryButton: true,
                onTapRetry: () {
                  _blogDetailsCubit.getBlogDetails(widget.blogId);
                },
              );
            }

            if (state is SuccessState<BlogDetailsData>) {
              final blogData = state.data;
              return _buildBlogContent(blogData);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildBlogContent(BlogDetailsData blogData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(
        16,
      ).copyWith(bottom: 16 + MediaQuery.viewPaddingOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBlogHeader(blogData.blogDetails),
          const CustomSizedBox(height: 12),
          _buildBlogHtmlContent(blogData.blogDetails),
          const CustomSizedBox(height: 12),
          if (blogData.relevantBlogs.isNotEmpty) ...[
            _buildRelevantBlogsSection(blogData.relevantBlogs),
          ],
        ],
      ),
    );
  }

  Widget _buildBlogHeader(BlogModel blog) {
    return CustomContainer(
      width: double.infinity,
      color: context.colors.surfacePrimary,
      borderRadius: UiUtils.borderRadiusOf12,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            blog.translatedTitle ?? '',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.colors.textPrimary,
            textAlign: TextAlign.start,
          ),
          const CustomSizedBox(height: 12),
          Row(
            children: [
              if ((blog.translatedCategoryName ?? '').isNotEmpty) ...[
                CustomContainer(
                  color: context.colors.backgroundBrandSubtle,
                  borderRadius: UiUtils.borderRadiusOf8,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: CustomText(
                    blog.translatedCategoryName ?? '',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: context.colors.textPrimary,
                  ),
                ),
                const CustomSizedBox(width: 8),
                CustomContainer(
                  width: 4,
                  height: 4,
                  color: context.colors.textTertiary,
                  shape: BoxShape.circle,
                ),
                const CustomSizedBox(width: 8),
              ],
              CustomText(
                (blog.createdAt ?? '').formatDateForBlogs(),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: context.colors.textPrimary,
              ),
            ],
          ),
          const CustomSizedBox(height: 12),
          AspectRatio(
            aspectRatio: 316 / 169,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf8),
              child: CustomCachedNetworkImage(
                networkImageUrl: blog.image ?? '',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlogHtmlContent(BlogModel blog) {
    return CustomContainer(
      width: double.infinity,
      color: context.colors.surfacePrimary,
      borderRadius: UiUtils.borderRadiusOf12,
      padding: const EdgeInsets.all(12),
      child: HtmlWidget(
        blog.translatedDescription ?? '',
        textStyle: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          height: 20 / 14,
          color: context.colors.textSecondary,
        ),
        onTapUrl: (url) async {
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(
              Uri.parse(url),
              mode: LaunchMode.externalApplication,
            );
          }
          return true;
        },
      ),
    );
  }

  Widget _buildRelevantBlogsSection(List<BlogModel> relevantBlogs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'relatedBlogs'.translate(context: context),
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: context.colors.textPrimary,
        ),

        const CustomSizedBox(height: 16),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 4.rw(context)),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int index = 0; index < relevantBlogs.length; index++) ...[
                  if (index != 0) const CustomSizedBox(width: 10),
                  CustomSizedBox(
                    width: 310,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          blogDetailsScreen,
                          arguments: {'blogId': relevantBlogs[index].id},
                        );
                      },
                      borderRadius: BorderRadius.circular(
                        UiUtils.borderRadiusOf12,
                      ),
                      child: BlogCard(
                        blog: relevantBlogs[index],
                        isBorder: true,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
