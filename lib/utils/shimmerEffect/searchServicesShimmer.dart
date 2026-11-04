import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class SearchServicesShimmerEffect extends StatelessWidget {
  const SearchServicesShimmerEffect({super.key});

  Widget _buildServiceCardShimmer(BuildContext context) =>
      const CustomShimmerLoadingContainer(
        width: 290,
        height: 155,
        borderRadius: UiUtils.borderRadiusOf10,
      );

  Widget _buildProviderItemShimmer(BuildContext context) => CustomContainer(
    margin: const EdgeInsetsDirectional.only(start: 15, end: 15, top: 10),
    color: context.colors.surfaceElevated,
    borderRadius: UiUtils.borderRadiusOf10,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              CustomShimmerLoadingContainer(
                width: 35,
                height: 35,
                borderRadius: UiUtils.borderRadiusOf5,
              ),
              CustomSizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomShimmerLoadingContainer(
                      width: 120,
                      height: 10,
                      borderRadius: UiUtils.borderRadiusOf5,
                    ),
                    CustomSizedBox(height: 6),
                    CustomShimmerLoadingContainer(
                      width: 180,
                      height: 12,
                      borderRadius: UiUtils.borderRadiusOf5,
                    ),
                  ],
                ),
              ),
              CustomSizedBox(width: 8),
              CustomShimmerLoadingContainer(
                width: 20,
                height: 20,
                borderRadius: UiUtils.borderRadiusOf5,
              ),
            ],
          ),
        ),
        // Horizontal service cards row
        SizedBox(
          height: 155,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (_, __) => const CustomSizedBox(width: 10),
            itemBuilder: (context, _) => _buildServiceCardShimmer(context),
          ),
        ),
        const CustomSizedBox(height: 10),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    physics: const NeverScrollableScrollPhysics(),
    child: Column(
      children: List.generate(
        UiUtils.numberOfShimmerContainer,
        (_) => _buildProviderItemShimmer(context),
      ),
    ),
  );
}
