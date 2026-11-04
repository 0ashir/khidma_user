import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

import 'serviceSectionTitle.dart';

class ServiceSimilarSection extends StatelessWidget {
  const ServiceSimilarSection({
    required this.relatedServices,
    required this.providerId,
    super.key,
  });

  final List<RelatedService> relatedServices;
  final String providerId;

  Services _relatedServiceToServices(final RelatedService relatedService) =>
      Services(
        id: relatedService.id,
        userId: '',
        categoryId: relatedService.categoryId,
        categoryName: relatedService.categoryName,
        partnerName: '',
        translatedPartnerName: '',
        title: relatedService.title,
        translatedTitle: relatedService.title,
        slug: relatedService.slug,
        description: relatedService.description,
        translatedDescription: relatedService.description,
        tags: '',
        imageOfTheService: relatedService.image,
        price: relatedService.price,
        discountedPrice: relatedService.discountedPrice,
        originalPriceWithTax: relatedService.price,
        taxAmount: '0',
        priceWithTax: relatedService.discountedPrice != '0'
            ? relatedService.discountedPrice
            : relatedService.price,
        numberOfMembersRequired: relatedService.numberOfMembersRequired,
        duration: relatedService.duration,
        rating: relatedService.averageRating,
        averageRating: relatedService.averageRating,
        numberOfRatings: relatedService.numberOfRatings,
        maxQuantityAllowed: '10',
        isPayLaterAllowed: '',
        status: '',
        longDescription: relatedService.description,
        translatedLongDescription: relatedService.description,
        otherImagesOfTheService: const [],
        discountPercentage: relatedService.discountPercentage,
        currencySymbol: relatedService.currencySymbol,
        durationType: relatedService.durationType,
      );

  @override
  Widget build(final BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        ServiceSectionTitle('similarServices'.translate(context: context)),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: List.generate(relatedServices.length, (final int index) {
              final RelatedService relatedService = relatedServices[index];
              return ServiceCard(
                key: ValueKey(relatedService.id),
                width: context.screenWidth - 76,
                serviceId: relatedService.id ?? '',
                providerId: providerId,
                title: relatedService.title,
                image: relatedService.image,
                price: relatedService.price,
                discountedPrice: relatedService.discountedPrice,
                discountPercentage: relatedService.discountPercentage,
                duration: relatedService.duration,
                durationType: relatedService.durationType,
                numberOfMembersRequired: relatedService.numberOfMembersRequired,
                averageRating: relatedService.averageRating,
                maximumAllowedQuantity: 10,
                isProviderAvailableAtLocation: '1',
                companyName: relatedService.companyName,
                isProviderVerified: relatedService.isProviderVerified == '1',
                isBookmarked: relatedService.isBookmarked == '1',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    providerServiceDetails,
                    arguments: {
                      'serviceDetails': _relatedServiceToServices(
                        relatedService,
                      ),
                      'serviceId': relatedService.id ?? '',
                      'providerId': providerId,
                    },
                  );
                },
              );
            }),
          ),
        ),
      ],
    );
  }
}
