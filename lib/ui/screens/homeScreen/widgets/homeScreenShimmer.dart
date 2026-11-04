import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class HomeScreenShimmer extends StatelessWidget {
  const HomeScreenShimmer({super.key});

  Widget _titleShimmer() => const CustomShimmerLoadingContainer(
    width: 350,
    height: 20,
    borderRadius: UiUtils.borderRadiusOf10,
  );

  Widget _sliderShimmer(final BuildContext context) => Padding(
    padding: EdgeInsetsDirectional.only(
      start: 15.rw(context),
      end: 15.rw(context),
      top: 15.rh(context),
    ),
    child: CustomShimmerLoadingContainer(
      width: context.screenWidth,
      height: 200.rh(context),
      borderRadius: UiUtils.borderRadiusOf10,
    ),
  );

  Widget _categoryShimmer(final BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsetsDirectional.only(start: 15, end: 15, top: 15),
        child: _titleShimmer(),
      ),
      Padding(
        padding: EdgeInsetsDirectional.only(top: 15.rs(context)),
        child: SingleChildScrollView(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 5.rw(context)),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              UiUtils.numberOfShimmerContainer,
              (final int index) => const Column(
                children: [
                  CustomShimmerLoadingContainer(
                    width: 210,
                    height: 60,
                    borderRadius: UiUtils.borderRadiusOf10,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _singleSectionShimmer(final BuildContext context) => Padding(
    padding: EdgeInsetsDirectional.only(top: 15.rs(context)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 15.rw(context)),
          child: _titleShimmer(),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              ResponsiveHelper.isTabletDevice(context) ? 9 : 4,
              (final int index) => Padding(
                padding: EdgeInsetsDirectional.only(
                  top: 10.rw(context),
                  end: 5.rw(context),
                  start: 5.rw(context),
                ),
                child: const CustomShimmerLoadingContainer(
                  width: 120,
                  height: 140,
                  borderRadius: UiUtils.borderRadiusOf10,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(final BuildContext context) => SingleChildScrollView(
    padding: EdgeInsetsDirectional.only(
      bottom: UiUtils.getScrollViewBottomPadding(context),
    ),
    child: Column(
      children: [
        _sliderShimmer(context),
        const CustomSizedBox(height: 15),
        _categoryShimmer(context),
        Column(
          children: List.generate(
            UiUtils.numberOfShimmerContainer,
            (final int index) => _singleSectionShimmer(context),
          ),
        ),
      ],
    ),
  );
}
