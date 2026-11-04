import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

import 'myRequestBidderCard.dart';

class MyRequestBidTab extends StatelessWidget {
  const MyRequestBidTab({
    required this.bidders,
    required this.currentStatus,
    required this.canBook,
    required this.customJobRequestId,
    this.selectedSortBy,
    this.isSorting = false,
    super.key,
  });

  final List<BidProvider> bidders;
  final String currentStatus;
  final bool canBook;
  final String customJobRequestId;
  final String? selectedSortBy;
  final bool isSorting;

  void _openSortBottomSheet(
    final BuildContext context,
    final String? currentSortBy,
  ) {
    SortByBottomSheet.show(
      context,
      currentSortBy: currentSortBy,
      onSelected: (final sortBy) {
        context.read<MyRequestDetailsCubit>().sortBidders(
          customJobRequestId: customJobRequestId,
          sortBy: sortBy,
        );
      },
    );
  }

  @override
  Widget build(final BuildContext context) {
    if (bidders.isEmpty && !isSorting) {
      return Center(
        child: NoDataFoundWidget(
          titleKey: 'noOneHasBidYet'.translate(context: context),
        ),
      );
    }

    // Tablet shows 2-column bidder cards; phone keeps the single column.
    // Each list row holds one grid row.
    final bool isTablet = ResponsiveHelper.isTabletDevice(context);
    final int columns = isTablet ? 2 : 1;

    return Column(
      children: [
        CustomContainer(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: CustomText(
                  'availableProviderBid'.translate(context: context),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textPrimary,
                ),
              ),
              CustomInkWellContainer(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _openSortBottomSheet(context, selectedSortBy),
                child: CustomContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  color: context.colors.surfacePrimary,
                  borderRadius: 8,
                  border: Border.all(
                    color: context.colors.borderDefault,
                    width: 1.5,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(
                        'sortBy'.translate(context: context),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: context.colors.textPrimary,
                      ),
                      const CustomSizedBox(width: 4),
                      CustomSvgPicture(
                        svgImage: AppAssets.downArrow,
                        height: 16,
                        width: 16,
                        color: context.colors.textPrimary,
                        avoideResponsive: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: isSorting
              ? const Center(child: CustomCircularProgressIndicator())
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  separatorBuilder: (_, __) => const CustomSizedBox(height: 14),
                  itemCount: (bidders.length / columns).ceil(),
                  itemBuilder: (ctx, idx) {
                    final List<Widget> cards = bidders
                        .skip(idx * columns)
                        .take(columns)
                        .map(
                          (final bidder) => MyRequestBidderCard(
                            bidder: bidder,
                            currentStatus: currentStatus,
                            canBook: canBook,
                            customJobRequestId: customJobRequestId,
                          ),
                        )
                        .toList();
                    return isTablet
                        ? EqualHeightGrid(spacing: 14, children: cards)
                        : cards.first;
                  },
                ),
        ),
      ],
    );
  }
}
