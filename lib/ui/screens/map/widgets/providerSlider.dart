import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../app/generalImports.dart';
import '../../../../cubits/fetchMapProviderCubit.dart';

class ProviderSlider extends StatelessWidget {
  final CarouselSliderController providerCarouselController;
  final ValueNotifier<int> selectedProviderIndex;
  final Function(List<Providers> providers) onProvidersUpdate;
  final void Function(double latitude, double longitude) onProviderSelected;

  const ProviderSlider({
    Key? key,
    required this.providerCarouselController,
    required this.selectedProviderIndex,
    required this.onProvidersUpdate,
    required this.onProviderSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<FetchMapProviderCubit, FetchMapProviderState>(
        listener: (context, state) {
          if (state is FetchMapProviderFetchSuccess) {
            onProvidersUpdate(state.filteredProviderList);
          }
        },
        builder: (context, state) {
          if (state is FetchMapProviderFetchSuccess) {
            final providerList = state.filteredProviderList;
            if (providerList.isEmpty) return const SizedBox.shrink();

            return CarouselSlider.builder(
              carouselController: providerCarouselController,
              itemCount: providerList.length,
              itemBuilder: (context, index, realIndex) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: ProviderCard(providerDetails: providerList[index]),
                ),
              ),
              options: CarouselOptions(
                height: ResponsiveHelper.isTabletDevice(context)
                    ? 160.rh(context)
                    : 190.rh(context),
                autoPlay: false,
                viewportFraction: 0.85,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  selectedProviderIndex.value = index;
                  final double? latitude = double.tryParse(
                    providerList[index].latitude ?? '',
                  );
                  final double? longitude = double.tryParse(
                    providerList[index].longitude ?? '',
                  );
                  if (latitude != null && longitude != null) {
                    onProviderSelected(latitude, longitude);
                  }
                },
              ),
            );
          } else if (state is FetchMapProviderFetchFailure) {
            return CustomText(
              "noInternetFound".translate(context: context),
              maxLines: 2,
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: context.colors.textPrimary,
            );
          }
          return const SizedBox.shrink();
        },
      );
}
