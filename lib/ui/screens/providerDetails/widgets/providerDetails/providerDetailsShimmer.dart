import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class ProviderDetailsShimmer extends StatelessWidget {
  const ProviderDetailsShimmer({required this.tabCount, super.key});

  final int tabCount;

  @override
  Widget build(final BuildContext context) {
    final double appbarimageContainerHight = context.screenHeight * 0.27;
    final double providerContainerHight = 280.rh(context);
    final double cardOverlapAmount = 45.rh(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          CustomSizedBox(
            height:
                appbarimageContainerHight +
                (providerContainerHight - cardOverlapAmount),
            width: double.maxFinite,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                  child: CustomShimmerLoadingContainer(
                    height: appbarimageContainerHight,
                    width: context.screenWidth,
                    borderRadius: 0,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsetsDirectional.symmetric(
                      horizontal: 16.rw(context),
                    ),
                    child: CustomShimmerLoadingContainer(
                      height: providerContainerHight,
                      width: double.infinity,
                      borderRadius: UiUtils.borderRadiusOf12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          CustomSizedBox(height: 16.rh(context)),
          Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: 16.rw(context),
            ),
            child: Row(
              children: List.generate(
                tabCount,
                (final int index) => Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      end: index == tabCount - 1 ? 0 : 8.rw(context),
                    ),
                    child: const CustomShimmerLoadingContainer(
                      height: 32,
                      borderRadius: 8,
                    ),
                  ),
                ),
              ),
            ),
          ),
          CustomSizedBox(height: 12.rh(context)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: 16.rw(context),
            ),
            child: Row(
              children: List.generate(
                4,
                (final int index) => Padding(
                  padding: EdgeInsetsDirectional.only(
                    end: index == 3 ? 0 : 8.rw(context),
                  ),
                  child: CustomShimmerLoadingContainer(
                    height: 32,
                    width: 80.rw(context),
                    borderRadius: 8,
                  ),
                ),
              ),
            ),
          ),
          CustomSizedBox(height: 16.rh(context)),
          Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: 16.rw(context),
            ),
            child: Column(
              children: List.generate(
                UiUtils.numberOfShimmerContainer,
                (final int index) => Padding(
                  padding: EdgeInsetsDirectional.only(bottom: 12.rh(context)),
                  child: const CustomShimmerLoadingContainer(
                    height: 176,
                    borderRadius: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
