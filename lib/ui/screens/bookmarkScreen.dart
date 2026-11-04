import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // ignore_for_file: file_names

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({final Key? key}) : super(key: key);

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();

  static Route route(final RouteSettings routeSettings) => CupertinoPageRoute(
    builder: (final BuildContext context) => const BookmarkScreen(),
  );
}

class _BookmarkScreenState extends State<BookmarkScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );
  final ScrollController _servicesScrollController = ScrollController();
  final ScrollController _providersScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch once; switching tabs reuses the loaded list (pull to refresh).
    if (context.read<ServiceBookmarkCubit>().state
        is! ServiceBookmarkFetchSuccess) {
      context.read<ServiceBookmarkCubit>().fetchServiceBookmark();
    }
    if (context.read<BookmarkCubit>().state is! BookmarkFetchSuccess) {
      context.read<BookmarkCubit>().fetchBookmark(type: 'list');
    }
    _servicesScrollController.addListener(_fetchMoreServices);
    _providersScrollController.addListener(_fetchMoreProviders);
  }

  void _fetchMoreServices() {
    final ServiceBookmarkCubit cubit = context.read<ServiceBookmarkCubit>();
    if (!cubit.hasMoreBookMark()) return;

    final double nextPageTrigger =
        0.7 * _servicesScrollController.position.maxScrollExtent;
    if (_servicesScrollController.position.pixels > nextPageTrigger) {
      if (mounted) cubit.fetchMoreServiceBookmark();
    }
  }

  void _fetchMoreProviders() {
    final BookmarkCubit cubit = context.read<BookmarkCubit>();
    if (!cubit.hasMoreBookMark()) return;

    final double nextPageTrigger =
        0.7 * _providersScrollController.position.maxScrollExtent;
    if (_providersScrollController.position.pixels > nextPageTrigger) {
      if (mounted) cubit.fetchMoreBookmark(type: 'list');
    }
  }

  @override
  void dispose() {
    _servicesScrollController.dispose();
    _providersScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String? _serviceProviderName(final Services service) =>
      (service.translatedPartnerName ?? '').isNotEmpty
      ? service.translatedPartnerName
      : ((service.companyName ?? '').isNotEmpty
            ? service.companyName
            : service.partnerName);

  @override
  Widget build(final BuildContext context) => InterstitialAdWidget(
    child: AnnotatedSafeArea(
      isAnnotated: true,
      applyBottomInset: false,
      child: Scaffold(
        appBar: UiUtils.getSimpleAppBar(
          context: context,
          title: 'bookmark'.translate(context: context),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48.rh(context)),
            child: TopRoundedUnderlineTabBar(
              controller: _tabController,
              boxShadow: [
                BoxShadow(
                  color: context.colors.overlayHeaderShadow,
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
              tabs: [
                BlocBuilder<ServiceBookmarkCubit, ServiceBookmarkState>(
                  builder: (final context, final state) => Text(
                    '${'services'.translate(context: context)} '
                    '(${state is ServiceBookmarkFetchSuccess ? state.totalBookmark : 0})',
                  ),
                ),
                BlocBuilder<BookmarkCubit, BookmarkState>(
                  builder: (final context, final state) => Text(
                    '${'providers'.translate(context: context)} '
                    '(${state is BookmarkFetchSuccess ? state.totalBookmark : 0})',
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom,
          ),
          child: const BannerAdWidget(),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_buildServicesTab(), _buildProvidersTab()],
        ),
      ),
    ),
  );

  Widget _buildServicesTab() =>
      BlocConsumer<ServiceBookmarkCubit, ServiceBookmarkState>(
        listener:
            (final BuildContext context, final ServiceBookmarkState state) {
              if (state is ServiceBookmarkFetchFailure) {
                UiUtils.showMessage(
                  context,
                  state.errorMessage,
                  ToastificationType.error,
                );
              }
            },
        builder:
            (final BuildContext context, final ServiceBookmarkState state) {
              if (state is ServiceBookmarkFetchFailure) {
                return Center(
                  child: ErrorContainer(
                    errorMessage: state.errorMessage.translate(
                      context: context,
                    ),
                    onTapRetry: () => context
                        .read<ServiceBookmarkCubit>()
                        .fetchServiceBookmark(),
                    showRetryButton: true,
                  ),
                );
              } else if (state is ServiceBookmarkFetchSuccess) {
                if (state.bookmarkList.isEmpty) {
                  return Center(
                    child: NoDataFoundWidget(
                      titleKey: 'noBookmarkFound'.translate(context: context),
                      subtitleKey: 'noBookmarkFoundSubTitle'.translate(
                        context: context,
                      ),
                      imagePath: AppAssets.noBooking,
                    ),
                  );
                }
                return _buildServicesList(
                  services: state.bookmarkList,
                  isLoadingMoreData: state.isLoadingMoreData,
                  isLoadingMoreError: state.isLoadingMoreError,
                );
              }
              return _buildShimmerList();
            },
      );

  // Tablet shows 2 cards per list row (20 gap, same as the provider services
  // tab); phone keeps the single column.
  int get _columns => ResponsiveHelper.isTabletDevice(context) ? 2 : 1;

  double get _gap => _columns > 1 ? 20 : 12;

  Widget _gridRow(final List<Widget> cards) => _columns > 1
      ? EqualHeightGrid(spacing: _gap, children: cards)
      : cards.first;

  Widget _buildServiceCard(final Services service) =>
      BlocBuilder<CartCubit, CartState>(
        builder: (final BuildContext context, final _) => ServiceCard(
          serviceId: service.id ?? '',
          providerId: service.userId ?? '0',
          title: service.translatedTitle,
          image: service.imageOfTheService,
          price: service.price,
          discountedPrice: service.discountedPrice,
          discountPercentage: service.discountPercentage,
          duration: service.duration,
          durationType: service.durationType,
          numberOfMembersRequired: service.numberOfMembersRequired,
          averageRating: service.averageRating ?? service.rating,
          maximumAllowedQuantity:
              int.tryParse(service.maxQuantityAllowed ?? '0') ?? 0,
          companyName: service.companyName,
          isProviderVerified: service.isProviderVerified ?? false,
          isBookmarked: service.isBookmarked,
          serviceProviderName: _serviceProviderName(service),
          showBorder: false,
          onBookmarkChanged: (final bool bookmarked) {
            if (!bookmarked) {
              context.read<ServiceBookmarkCubit>().removeBookmark(
                service.id ?? '',
              );
            }
          },
          onTap: () {
            Navigator.pushNamed(
              context,
              providerServiceDetails,
              arguments: {
                'serviceDetails': service,
                'serviceId': service.id ?? '',
                'providerId': service.userId ?? '0',
              },
            );
          },
        ),
      );

  Widget _buildServicesList({
    required final List<Services> services,
    required final bool isLoadingMoreData,
    required final bool isLoadingMoreError,
  }) {
    final int rowCount = (services.length / _columns).ceil();
    return _refreshable(
      onRefresh: () =>
          context.read<ServiceBookmarkCubit>().fetchServiceBookmark(),
      child: ListView.separated(
        key: const PageStorageKey('bookmarkServices'),
        controller: _servicesScrollController,
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          UiUtils.getScrollViewBottomPadding(context),
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        separatorBuilder: (final _, final __) => CustomSizedBox(height: _gap),
        itemCount: rowCount + (isLoadingMoreData || isLoadingMoreError ? 1 : 0),
        itemBuilder: (final BuildContext context, final int index) {
          if (index >= rowCount) {
            return CustomLoadingMoreContainer(
              isError: isLoadingMoreError,
              onErrorButtonPressed: _fetchMoreServices,
            );
          }
          return _gridRow(
            services
                .skip(index * _columns)
                .take(_columns)
                .map(_buildServiceCard)
                .toList(),
          );
        },
      ),
    );
  }

  Widget _buildProvidersTab() => BlocConsumer<BookmarkCubit, BookmarkState>(
    listener: (final BuildContext context, final BookmarkState state) {
      if (state is BookmarkFetchFailure) {
        UiUtils.showMessage(
          context,
          state.errorMessage,
          ToastificationType.error,
        );
      }
    },
    builder: (final BuildContext context, final BookmarkState state) {
      if (state is BookmarkFetchFailure) {
        return Center(
          child: ErrorContainer(
            errorMessage: state.errorMessage.translate(context: context),
            onTapRetry: () =>
                context.read<BookmarkCubit>().fetchBookmark(type: 'list'),
            showRetryButton: true,
          ),
        );
      } else if (state is BookmarkFetchSuccess) {
        if (state.bookmarkList.isEmpty) {
          return Center(
            child: NoDataFoundWidget(
              titleKey: 'noBookmarkFound'.translate(context: context),
              subtitleKey: 'noBookmarkFoundSubTitle'.translate(
                context: context,
              ),
              imagePath: AppAssets.noBooking,
            ),
          );
        }
        return _buildProvidersList(
          providers: state.bookmarkList,
          isLoadingMoreData: state.isLoadingMoreData,
          isLoadingMoreError: state.isLoadingMoreError,
        );
      }
      return _buildShimmerList();
    },
  );

  Widget _buildProvidersList({
    required final List<Providers> providers,
    required final bool isLoadingMoreData,
    required final bool isLoadingMoreError,
  }) {
    final int rowCount = (providers.length / _columns).ceil();
    return _refreshable(
      onRefresh: () =>
          context.read<BookmarkCubit>().fetchBookmark(type: 'list'),
      child: ListView.separated(
        key: const PageStorageKey('bookmarkProviders'),
        controller: _providersScrollController,
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          UiUtils.getScrollViewBottomPadding(context),
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        separatorBuilder: (final _, final __) => CustomSizedBox(height: _gap),
        itemCount: rowCount + (isLoadingMoreData || isLoadingMoreError ? 1 : 0),
        itemBuilder: (final BuildContext context, final int index) {
          if (index >= rowCount) {
            return CustomLoadingMoreContainer(
              isError: isLoadingMoreError,
              onErrorButtonPressed: _fetchMoreProviders,
            );
          }
          return _gridRow(
            providers
                .skip(index * _columns)
                .take(_columns)
                .map(
                  (final provider) => ProviderCard(providerDetails: provider),
                )
                .toList(),
          );
        },
      ),
    );
  }

  Widget _refreshable({
    required final VoidCallback onRefresh,
    required final Widget child,
  }) => CustomRefreshIndicator(
    displacment: 12,
    onRefreshCallback: onRefresh,
    child: child,
  );

  Widget _buildShimmerList() => ListView.separated(
    padding: const EdgeInsets.all(16),
    physics: const NeverScrollableScrollPhysics(),
    itemCount: (UiUtils.numberOfShimmerContainer / _columns).ceil(),
    separatorBuilder: (final _, final __) => CustomSizedBox(height: _gap),
    itemBuilder: (final BuildContext context, final int index) => _gridRow(
      List.generate(
        _columns,
        (final _) => const CustomShimmerLoadingContainer(
          height: 176,
          width: double.infinity,
          borderRadius: UiUtils.borderRadiusOf12,
        ),
      ),
    ),
  );
}
