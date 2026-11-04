import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FaqsScreen extends StatefulWidget {
  const FaqsScreen({final Key? key}) : super(key: key);

  static Route route(final RouteSettings routeSettings) => CupertinoPageRoute(
    builder: (final _) => BlocProvider<FandqsCubit>(
      create: (final BuildContext context) => FandqsCubit(SystemRepository()),
      child: const FaqsScreen(),
    ),
  );

  @override
  State<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends State<FaqsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    setScrollListener();
    Future.delayed(Duration.zero).then((final value) {
      fetchFAQs();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void setScrollListener() {
    _scrollController.addListener(fetchMoreFaqs);
  }

  void fetchFAQs() {
    context.read<FandqsCubit>().fetchFAQs();
  }

  void fetchMoreFaqs() {
    if (!context.read<FandqsCubit>().hasMoreFAndQs()) {
      return;
    }

    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;

    if (position.maxScrollExtent <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && context.read<FandqsCubit>().hasMoreFAndQs()) {
          context.read<FandqsCubit>().fetchMoreFAndQs();
        }
      });
      return;
    }

    const threshold = 200.0;
    final nextPageTrigger = 0.7 * position.maxScrollExtent;
    final distanceFromBottom = position.maxScrollExtent - position.pixels;

    if (position.pixels > nextPageTrigger || distanceFromBottom < threshold) {
      if (mounted) {
        context.read<FandqsCubit>().fetchMoreFAndQs();
      }
    }
  }

  @override
  Widget build(final BuildContext context) => InterstitialAdWidget(
    child: AnnotatedSafeArea(
      isAnnotated: true,
      applyBottomInset: false,
      child: Scaffold(
        backgroundColor: context.colors.backgroundSecondary,
        appBar: UiUtils.getSimpleAppBar(
          context: context,
          title: 'faqs'.translate(context: context),
        ),
        bottomNavigationBar: const BannerAdWidget(applyBottomInset: true),
        body: UiUtils.restoreBottomInset(
          inset: MediaQuery.viewPaddingOf(context).bottom,
          child: CustomRefreshIndicator(
            displacment: 12,
            onRefreshCallback: () {
              fetchFAQs();
            },
            child: BlocBuilder<FandqsCubit, FandqsState>(
              builder:
                  (final BuildContext context, final FandqsState faqState) {
                    if (faqState is FaqsFetchFailure) {
                      return ErrorContainer(
                        errorMessage: faqState.errorMessage.translate(
                          context: context,
                        ),
                        onTapRetry: fetchFAQs,
                        showRetryButton: true,
                      );
                    } else if (faqState is FaqsFetchSuccess) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted &&
                            context.read<FandqsCubit>().hasMoreFAndQs() &&
                            _scrollController.hasClients) {
                          final position = _scrollController.position;
                          if (position.maxScrollExtent <= 0 ||
                              position.maxScrollExtent <
                                  position.viewportDimension) {
                            context.read<FandqsCubit>().fetchMoreFAndQs();
                          }
                        }
                      });

                      return faqState.faqsList.isEmpty
                          ? Center(
                              child: NoDataFoundWidget(
                                titleKey: 'noFaqsFound'.translate(
                                  context: context,
                                ),
                                subtitleKey: "noFaqsFoundSubTitle".translate(
                                  context: context,
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              controller: _scrollController,
                              padding: EdgeInsets.fromLTRB(
                                16,
                                24,
                                16,
                                24 + MediaQuery.viewPaddingOf(context).bottom,
                              ),
                              child: Column(
                                children: List.generate(
                                  faqState.faqsList.length +
                                      (faqState.isLoadingMoreFaqs ||
                                              faqState.isLoadingMoreError
                                          ? 1
                                          : 0),
                                  (final int index) {
                                    if (index >= faqState.faqsList.length) {
                                      return CustomLoadingMoreContainer(
                                        isError: faqState.isLoadingMoreError,
                                        onErrorButtonPressed: () {
                                          fetchMoreFaqs();
                                        },
                                      );
                                    }
                                    return Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                        bottom: 12,
                                      ),
                                      child: FaqItemCard(
                                        highlightExpandedHeader: false,
                                        question: faqState
                                            .faqsList[index]
                                            .translatedQuestion,
                                        answer: faqState
                                            .faqsList[index]
                                            .translatedAnswer,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                    }

                    return _getShimmerEffect();
                  },
            ),
          ),
        ),
      ),
    ),
  );

  Widget _getShimmerEffect() => Padding(
    padding: const EdgeInsetsDirectional.only(start: 15, end: 15, top: 15),
    child: SingleChildScrollView(
      child: Column(
        children: List.generate(
          UiUtils.numberOfShimmerContainer,
          (final index) => CustomShimmerLoadingContainer(
            margin: const EdgeInsets.all(15),
            width: context.screenWidth,
            height: 50,
            borderRadius: UiUtils.borderRadiusOf10,
          ),
        ),
      ),
    ),
  );
}
