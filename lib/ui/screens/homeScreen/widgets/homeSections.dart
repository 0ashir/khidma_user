import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/ui/screens/homeScreen/widgets/homeCategorySection.dart';
import 'package:flutter/material.dart';

/// Renders the dynamic list of home sections returned by the home API.
class HomeSections extends StatelessWidget {
  const HomeSections({required this.sectionsList, super.key});

  final List<Sections> sectionsList;

  static const double _sideInset = 15;
  static const double _sectionGap = 24;
  static const EdgeInsetsDirectional _cardEndSpacing =
      EdgeInsetsDirectional.only(end: 12);

  void _openServiceDetails(final BuildContext context, final Services service) {
    Navigator.pushNamed(
      context,
      providerServiceDetails,
      arguments: {
        'serviceDetails': service,
        'serviceId': service.id ?? '',
        'providerId': service.userId ?? '0',
      },
    );
  }

  Widget _buildSectionTitle(
    final BuildContext context,
    final Sections sectionData,
  ) => Padding(
    padding: EdgeInsetsDirectional.only(
      start: _sideInset.rs(context),
      end: _sideInset.rs(context),
    ),
    child: Row(
      spacing: 16,
      children: [
        Expanded(
          child: CustomText(
            sectionData.translatedTitle ?? '',
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 16,
            maxLines: 1,
            textAlign: TextAlign.left,
          ),
        ),
        CustomInkWellContainer(
          onTap: () {
            final bool isBookingSection =
                sectionData.onGoingBookings.isNotEmpty ||
                sectionData.previousBookings.isNotEmpty;
            if (isBookingSection) {
              UiUtils
                      .bottomNavigationBarGlobalKey
                      .currentState
                      ?.selectedIndexOfBottomNavigationBar
                      .value =
                  1;
              Navigator.of(context).popUntil((final route) => route.isFirst);
              return;
            }
            Navigator.pushNamed(
              context,
              sectionDetailsRoute,
              arguments: {'sectionData': sectionData},
            );
          },
          child: CustomText(
            'viewAll'.translate(context: context),
            color: context.colors.textBrand,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );

  List<Widget> _providerCards(
    final BuildContext context,
    final Sections sectionData,
  ) => sectionData.providers.map((final Providers provider) {
    return Padding(
      padding: _cardEndSpacing,
      child: SizedBox(
        width: 305.rw(context),
        child: ProviderCard(
          providerDetails: provider,
          height: 76,
          width: 80,
          showBanner: sectionData.providersLayoutType == 'style_1',
          highlightStat: sectionData.sectionType == 'top_rated_partner'
              ? 'rating'
              : 'distance',
          onTap: () {
            ClarityService.logAction(ClarityActions.homePopularServiceTapped, {
              'provider_id': provider.id ?? '',
              'provider_name':
                  provider.translatedCompanyName ?? provider.companyName,
              'services_count': provider.totalServices ?? '',
              'section': sectionData.sectionType ?? '',
            });
            Navigator.pushNamed(
              context,
              providerRoute,
              arguments: {"providerId": provider.id},
            ).then((final Object? value) {
              Routes.previousRoute = Routes.currentRoute;
              Routes.currentRoute = navigationRoute;
            });
          },
        ),
      ),
    );
  }).toList();

  List<Widget> _serviceCards(
    final BuildContext context,
    final Sections sectionData,
  ) => sectionData.services.map((final Services service) {
    return Padding(
      padding: _cardEndSpacing,
      child: SizedBox(
        width: 305.rw(context),
        // ServiceCard reads its "already added" quantity with
        // context.read<CartCubit>() (not watch), so wrap here to rebuild on
        // cart changes and flip Add -> qty stepper immediately.
        child: BlocBuilder<CartCubit, CartState>(
          builder: (final context, final _) => ServiceCard(
            imageWidth: 55,
            imageHeight: 72,
            useDashedDivider: true,
            showBorder: false,
            addButtonBackgroundColor: context.colors.backgroundBrandSubtle,
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
            isBookmarked: service.isBookmarked,
            companyName: service.companyName,
            isProviderVerified: service.isProviderVerified ?? false,
            onTap: () => _openServiceDetails(context, service),
          ),
        ),
      ),
    );
  }).toList();

  List<Widget> _bookingCards(
    final BuildContext context,
    final Sections sectionData,
  ) {
    final bool isOngoing = sectionData.onGoingBookings.isNotEmpty;
    final List<BookingListItem> bookings = isOngoing
        ? sectionData.onGoingBookings
        : sectionData.previousBookings;
    final bool anyHasMoreServices = bookings.any(
      (final b) => (b.otherServicesCount ?? 0) > 0,
    );
    return bookings.map((final BookingListItem bookingData) {
      if (isOngoing) {
        return Padding(
          padding: _cardEndSpacing,
          child: OngoingBookingCard(
            booking: bookingData,
            reserveMoreServicesLine: anyHasMoreServices,
          ),
        );
      }
      return Padding(
        padding: _cardEndSpacing,
        child: SizedBox(
          width: 305.rw(context),
          child: BookingSummaryCard(
            booking: bookingData,
            reserveMoreServicesLine: anyHasMoreServices,
            onTap: () {
              Navigator.pushNamed(
                context,
                bookingDetails,
                arguments: {"bookingId": bookingData.id},
              );
            },
          ),
        ),
      );
    }).toList();
  }

  Widget _buildSectionData(
    final BuildContext context,
    final Sections sectionData,
  ) {
    final List<Widget> cards = sectionData.providers.isNotEmpty
        ? _providerCards(context, sectionData)
        : sectionData.services.isNotEmpty
        ? _serviceCards(context, sectionData)
        : (sectionData.onGoingBookings.isNotEmpty ||
              sectionData.previousBookings.isNotEmpty)
        ? _bookingCards(context, sectionData)
        : const [];

    return CustomSizedBox(
      width: context.screenWidth,
      child: SingleChildScrollView(
        padding: EdgeInsetsDirectional.only(
          end: _sideInset.rs(context),
          start: _sideInset.rs(context),
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: cards,
        ),
      ),
    );
  }

  Widget _buildBanner(final BuildContext context, final Sections sectionData) {
    if ((sectionData.bannerImage ?? '').isEmpty) return const CustomSizedBox();
    final double bannerHeight = ResponsiveHelper.isTabletDevice(context)
        ? 260
        : 200.rs(context);
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: _sideInset.rs(context),
        end: _sideInset.rs(context),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
        child: CustomCachedNetworkImage(
          networkImageUrl: sectionData.bannerImage!,
          width: double.infinity,
          height: bannerHeight,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildSection(
    final Sections sectionData, {
    required final bool isFirstVisible,
  }) => BlocBuilder<UserDetailsCubit, UserDetailsState>(
    builder: (context, state) {
      final token = HiveRepository.getUserToken;
      if ((sectionData.sectionType == "previous_order" && token == '') ||
          (sectionData.sectionType == "ongoing_order" && token == '')) {
        return const CustomSizedBox();
      }

      final double topGap = isFirstVisible ? 0 : _sectionGap;

      switch (sectionData.sectionType) {
        case 'all_categories':
        case 'categories':
          return Padding(
            padding: EdgeInsetsDirectional.only(top: topGap),
            child: HomeCategorySection(
              sectionData: sectionData,
              isAllCategories: sectionData.sectionType == 'all_categories',
            ),
          );
        case 'banner':
          return Padding(
            padding: EdgeInsetsDirectional.only(top: topGap),
            child: _buildBanner(context, sectionData),
          );
        case 'custom_job_requests':
          return Padding(
            padding: EdgeInsetsDirectional.only(
              start: _sideInset.rs(context),
              end: _sideInset.rs(context),
              top: topGap,
            ),
            child: RequestServiceBannerWidget(
              title: sectionData.translatedTitle,
              subtitle: sectionData.description,
            ),
          );
      }

      if (sectionData.offers.isNotEmpty) {
        return Padding(
          padding: EdgeInsetsDirectional.only(
            top: topGap,
            start: _sideInset.rs(context),
            end: _sideInset.rs(context),
          ),
          child: OffersSectionWidget(
            offers: sectionData.offers,
            layoutType: sectionData.offersLayoutType ?? 'one_image',
          ),
        );
      }

      return CustomContainer(
        margin: EdgeInsetsDirectional.only(top: topGap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, sectionData),
            CustomSizedBox(height: 8.rh(context)),
            _buildSectionData(context, sectionData),
          ],
        ),
      );
    },
  );

  @override
  Widget build(final BuildContext context) {
    bool renderedFirstVisible = false;
    return Column(
      children: List.generate(sectionsList.length, (index) {
        final Sections section = sectionsList[index];
        final bool isCustomJobRequestSection =
            section.sectionType == 'custom_job_requests';
        final bool isEmptySection =
            !isCustomJobRequestSection &&
            section.providers.isEmpty &&
            section.onGoingBookings.isEmpty &&
            section.previousBookings.isEmpty &&
            section.services.isEmpty &&
            section.offers.isEmpty &&
            section.categories.isEmpty &&
            (section.bannerImage ?? '').isEmpty;
        if (isEmptySection) return const CustomSizedBox();

        final bool isFirstVisible = !renderedFirstVisible;
        renderedFirstVisible = true;
        return _buildSection(section, isFirstVisible: isFirstVisible);
      }),
    );
  }
}
