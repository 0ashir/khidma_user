import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'widgets/serviceDetails/serviceAboutSection.dart';
import 'widgets/serviceDetails/serviceHeaderSection.dart';
import 'widgets/serviceDetails/serviceImageGallery.dart';
import 'widgets/serviceDetails/serviceInclusionSection.dart';
import 'widgets/serviceDetails/serviceProviderSection.dart';
import 'widgets/serviceDetails/serviceReviewSection.dart';
import 'widgets/serviceDetails/serviceSectionTitle.dart';
import 'widgets/serviceDetails/serviceSimilarSection.dart';

class ProviderServiceDetailsScreen extends StatefulWidget {
  const ProviderServiceDetailsScreen({
    super.key,
    required this.serviceDetails,
    required this.serviceId,
    required this.providerId,
    this.isProviderAvailableAtLocation,
  });

  final Services serviceDetails;
  final String serviceId;
  final String providerId;
  final String? isProviderAvailableAtLocation;

  @override
  State<ProviderServiceDetailsScreen> createState() =>
      _ProviderServiceDetailsScreenState();

  static Route route(final RouteSettings routeSettings) {
    final Map arguments = routeSettings.arguments as Map;

    return CupertinoPageRoute(
      builder: (final _) => ProviderServiceDetailsScreen(
        serviceDetails: arguments["serviceDetails"],
        serviceId: arguments["serviceId"],
        providerId: arguments["providerId"],
        isProviderAvailableAtLocation:
            arguments["isProviderAvailableAtLocation"],
      ),
    );
  }
}

class _ProviderServiceDetailsScreenState
    extends State<ProviderServiceDetailsScreen> {
  @override
  void initState() {
    super.initState();
    ClarityService.logAction(ClarityActions.serviceDetailViewed, {
      'service_id': widget.serviceId,
      'service_name': widget.serviceDetails.translatedTitle ?? '',
      'provider_id': widget.providerId,
      'duration': widget.serviceDetails.duration ?? '',
      'price': widget.serviceDetails.priceWithTax ?? '',
    });
    context.read<ServiceReviewCubit>().fetchServiceReview(
      serviceId: widget.serviceId,
      providerId: widget.providerId,
    );
    context.read<ServiceDetailsCubit>().fetchServiceDetails(
      id: widget.serviceId,
    );
  }

  Future<void> _handleShare(final String slug) async {
    final String shareURL =
        '$deepLinkDomain/service-details/$slug?lang=${HiveRepository.getCurrentLanguage()!.languageCode}';
    await UiUtils.share(context: context, shareURL, subject: "Share Service");
  }

  Widget _buildBrochureSection(final List<String> files) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ServiceSectionTitle('brochureOrFiles'.translate(context: context)),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(files.length, (final int index) {
            final fileUrl = files[index];
            final fileName = fileUrl.split("/").last;
            return CustomInkWellContainer(
              borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf8),
              onTap: () {
                launchUrl(
                  Uri.parse(fileUrl),
                  mode: LaunchMode.externalApplication,
                );
              },
              child: CustomContainer(
                color: context.colors.backgroundSecondary,
                borderRadius: UiUtils.borderRadiusOf8,
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 12,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 110),
                      child: CustomText(
                        fileName,
                        color: context.colors.textPrimary,
                        fontSize: 12,
                        maxLines: 1,
                      ),
                    ),
                    CustomSvgPicture(
                      svgImage: AppAssets.download,
                      height: 20,
                      width: 20,
                      color: context.colors.iconPrimary,
                      avoideResponsive: true,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFAQSection(final List<ServiceFaQs> faqs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ServiceSectionTitle('serviceFaqs'.translate(context: context)),
        Column(
          children: List.generate(
            faqs.length,
            (final int index) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FaqItemCard(
                question: faqs[index].question ?? '',
                answer: faqs[index].answer ?? '',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        CustomShimmerLoadingContainer(
          borderRadius: UiUtils.borderRadiusOf8,
          height: 200,
          width: context.screenWidth,
        ),
        CustomShimmerLoadingContainer(
          borderRadius: UiUtils.borderRadiusOf12,
          height: 220,
          width: context.screenWidth,
        ),
        CustomShimmerLoadingContainer(
          borderRadius: UiUtils.borderRadiusOf12,
          height: 100,
          width: context.screenWidth,
        ),
      ],
    ),
  );

  Widget _buildContent(final ServiceDetailsModel details) {
    final List<Widget> sections = [];

    void addSection(final Widget child) {
      if (sections.isNotEmpty) {
        sections.add(const CustomSizedBox(height: 16));
        sections.add(
          CustomSizedBox(
            height: 1,
            width: double.infinity,
            child: DashedRect(
              color: context.colors.borderStrong,
              strokeWidth: 1,
              gap: 4,
            ),
          ),
        );
        sections.add(const CustomSizedBox(height: 16));
      }
      sections.add(child);
    }

    addSection(
      ServiceHeaderSection(
        details: details,
        serviceId: widget.serviceId,
        providerId: widget.providerId,
        isProviderAvailableAtLocation: widget.isProviderAvailableAtLocation,
      ),
    );

    if ((details.description ?? '').isNotEmpty) {
      addSection(ServiceAboutSection(details: details));
    }
    if (details.whatsIncluded.isNotEmpty) {
      addSection(
        ServiceInclusionSection(
          title: "includedInService".translate(context: context),
          items: details.whatsIncluded,
          isIncluded: true,
        ),
      );
    }
    if (details.whatsExcluded.isNotEmpty) {
      addSection(
        ServiceInclusionSection(
          title: "excludedInService".translate(context: context),
          items: details.whatsExcluded,
          isIncluded: false,
        ),
      );
    }
    if (details.provider != null) {
      addSection(
        ServiceProviderSection(
          provider: details.provider!,
          providerId: widget.providerId,
        ),
      );
    }
    if (details.files.isNotEmpty) {
      addSection(_buildBrochureSection(details.files));
    }
    if (details.faqs.isNotEmpty) {
      addSection(_buildFAQSection(details.faqs));
    }

    final ServiceReviewState reviewState = context
        .watch<ServiceReviewCubit>()
        .state;
    if (reviewState is ServiceReviewFetchSuccess &&
        reviewState.reviewList.isNotEmpty) {
      addSection(
        ServiceReviewSection(
          details: details,
          reviewList: reviewState.reviewList,
          serviceId: widget.serviceId,
          providerId: widget.providerId,
        ),
      );
    } else if (reviewState is ServiceReviewInitial ||
        reviewState is ServiceReviewFetchInProgress) {
      addSection(
        CustomShimmerLoadingContainer(
          borderRadius: UiUtils.borderRadiusOf12,
          height: 120,
          width: context.screenWidth,
        ),
      );
    }

    if (details.relatedServices.isNotEmpty) {
      addSection(
        ServiceSimilarSection(
          relatedServices: details.relatedServices,
          providerId: widget.providerId,
        ),
      );
    }

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          ServiceImageGallery(details: details),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: sections,
          ),
          CustomContainer(
            height: 70 + MediaQuery.viewPaddingOf(context).bottom,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedSafeArea(
      isAnnotated: true,
      applyBottomInset: false,
      child: Scaffold(
        backgroundColor: context.colors.backgroundPrimary,
        appBar: UiUtils.getSimpleAppBar(
          context: context,
          title: 'serviceDetails'.translate(context: context),
          actions: [
            BlocBuilder<ServiceDetailsCubit, ServiceDetailsState>(
              builder: (context, state) {
                if (state is! ServiceDetailsFetchSuccess) {
                  return const CustomSizedBox();
                }
                return Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: CustomInkWellContainer(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => _handleShare(state.serviceDetails.slug ?? ''),
                    child: CustomContainer(
                      color: context.colors.backgroundPrimary,
                      shape: BoxShape.circle,
                      padding: const EdgeInsets.all(8),
                      child: CustomSvgPicture(
                        svgImage: AppAssets.drShare,
                        height: 24,
                        width: 24,
                        color: context.colors.iconPrimary,
                        avoideResponsive: true,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            BlocBuilder<ServiceDetailsCubit, ServiceDetailsState>(
              builder: (context, state) {
                if (state is ServiceDetailsFetchFailure) {
                  return ErrorContainer(
                    errorMessage: state.errorMessage,
                    onTapRetry: () {
                      context.read<ServiceDetailsCubit>().fetchServiceDetails(
                        id: widget.serviceId,
                      );
                    },
                  );
                }
                if (state is ServiceDetailsFetchSuccess) {
                  return _buildContent(state.serviceDetails);
                }
                return _buildShimmerLoading();
              },
            ),
            if ((context.watch<CartCubit>().state is CartFetchSuccess) &&
                (context.watch<CartCubit>().state as CartFetchSuccess)
                        .cartData
                        .providerId ==
                    widget.providerId)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.viewPaddingOf(context).bottom,
                  ),
                  child: const AddToCartComtainer(),
                ),
              ),
            if (context.watch<CartCubit>().state is CartFetchSuccess &&
                ((context.watch<CartCubit>().state as CartFetchSuccess)
                            .cartData
                            .cartDetails ??
                        [])
                    .isNotEmpty &&
                ((context.watch<CartCubit>().state as CartFetchSuccess)
                        .cartData
                        .providerId !=
                    widget.providerId)) ...[
              Align(
                alignment: Alignment.bottomCenter,
                child: CartSubDetailsContainer(providerID: widget.providerId),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
