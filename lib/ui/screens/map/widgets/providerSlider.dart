import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../app/generalImports.dart';
import '../../../../cubits/fetchMapProviderCubit.dart';
import '../../../../data/model/providerMapModel.dart';
import 'providerMapCard.dart';

class ProviderSlider extends StatelessWidget {
  final CarouselSliderController providerCarouselController;
  final ValueNotifier<int> selectedProviderIndex;
  final Completer<GoogleMapController> controller;
  final Function(List<ProviderMapModel> providers) onProvidersUpdate;

  const ProviderSlider({
    Key? key,
    required this.providerCarouselController,
    required this.selectedProviderIndex,
    required this.controller,
    required this.onProvidersUpdate,
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
              itemBuilder: (context, index, realIndex) => ProviderMapCard(
                provider: providerList[index],
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    providerRoute,
                    arguments: {
                      "providerId": providerList[index].providerId,
                    },
                  );
                },
              ),
              options: CarouselOptions(
                height: 135.rh(context),
                autoPlay: false,
                viewportFraction: 0.85,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  selectedProviderIndex.value = index;
                  controller.future.then((value) {
                    value.animateCamera(
                        CameraUpdate.newCameraPosition(CameraPosition(
                      zoom: 14,
                      target: LatLng(providerList[index].latitude,
                          providerList[index].longitude),
                    )));
                  });
                },
              ),
            );
          } else if (state is FetchMapProviderFetchFailure) {
            return ErrorContainer(
              errorMessage: state.errorMessage.translate(context: context),
              onTapRetry: () {
                context.read<FetchMapProviderCubit>().fetchMapProviders(
                      latitude: '0',
                      longitude: '0',
                    );
              },
            );
          }
          return const SizedBox.shrink();
        },
      );
}
