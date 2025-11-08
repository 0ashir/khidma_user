import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class LocationBottomSheet extends StatefulWidget {
  const LocationBottomSheet({final Key? key}) : super(key: key);

  @override
  State<LocationBottomSheet> createState() => CityBottomSheetState();
}

class CityBottomSheetState extends State<LocationBottomSheet> {
  final TextEditingController _searchLocation = TextEditingController();
  Timer? delayTimer;
  GooglePlaceAutocompleteCubit? cubitReference;
  int searchedTextLength = 0;
  ValueNotifier<int> previousSearchedTextLength = ValueNotifier(0);
  bool curruntlocationprogress = false;

  void _requestLocationPermission() {
    setState(() {
      curruntlocationprogress = true;
    });
    LocationRepository.requestPermission(
      allowed: (final Position position) {
        setState(() {
          curruntlocationprogress = false;
        });
        Navigator.pop(
          context,
          {
            'navigateToMap': true,
            "latitude": position.latitude.toString(),
            "longitude": position.longitude.toString()
          },
        );
      },
      onRejected: () async {},
      onGranted: (final Position position) async {
        setState(() {
          curruntlocationprogress = false;
        });
        Navigator.pop(
          context,
          {
            'navigateToMap': true,
            "latitude": position.latitude.toString(),
            "longitude": position.longitude.toString()
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _searchLocation.addListener(() {
      previousSearchedTextLength.value = _searchLocation.text.length;
      if (_searchLocation.text.isEmpty) {
        delayTimer?.cancel();
        cubitReference?.clearCubit();
      } else if (_searchLocation.text.length >= 3) {
        if (delayTimer?.isActive ?? false) delayTimer?.cancel();

        delayTimer = Timer(const Duration(milliseconds: 500), () {
          if (_searchLocation.text.isNotEmpty) {
            if (_searchLocation.text.length != searchedTextLength) {
              context
                  .read<GooglePlaceAutocompleteCubit>()
                  .searchLocationFromPlacesAPI(
                      text: Uri.encodeComponent(_searchLocation.text));
              searchedTextLength =
                  Uri.encodeComponent(_searchLocation.text).length;
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _searchLocation.dispose();
    delayTimer?.cancel();
    cubitReference?.clearCubit();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    cubitReference = context.read<GooglePlaceAutocompleteCubit>();
    super.didChangeDependencies();
  }

  Widget getPlaceContainer({
    ///if it is from stored searched places then we will directly navigate to the Map and will not store again in the local data
    required bool isFromHistory,
    required String placeName,
    required String placeId,
    String? latitude,
    String? longitude,
  }) {
    return Column(
      children: [
        CustomInkWellContainer(
          onTap: () async {
            dynamic coOrdinates = null;

            if (!isFromHistory) {
              coOrdinates = await GooglePlaceRepository()
                  .getPlaceDetailsFromPlaceId(placeId);

              HiveRepository.storePlaceInHive(
                placeId: placeId,
                placeName: placeName,
                longitude: coOrdinates['lng'].toString(),
                latitude: coOrdinates['lat'].toString(),
              );
            }

            Future.delayed(Duration.zero, () {
              Navigator.pop(
                context,
                {
                  'navigateToMap': true,
                  "latitude": latitude ?? coOrdinates['lat'].toString(),
                  "longitude": longitude ?? coOrdinates['lng'].toString()
                },
              );
            });
          },
          child: Row(
            children: [
              SizedBox(
                width: 35,
                height: 25,
                child: Icon(
                  Icons.location_city,
                  color: context.colorScheme.accentColor,
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: CustomText(
                  placeName,
                  color: context.colorScheme.blackColor,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 14,
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
        ),
        const CustomDivider(),
      ],
    );
  }

  @override
  Widget build(final BuildContext context) => CustomContainer(
        padding: EdgeInsetsDirectional.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: BottomSheetLayout(
          title: 'selectLocation',
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      flex: 11,
                      child: CustomTextFormField(
                        prefix: const CustomSvgPicture(
                          svgImage: AppAssets.currentLocation,
                          boxFit: BoxFit.scaleDown,
                        ),
                        fillColor: context.colorScheme.primaryColor,
                        hintText:
                            'enterLocationAreaCity'.translate(context: context),
                        controller: _searchLocation,
                        textInputType: TextInputType.text,
                        suffixIcon: ValueListenableBuilder(
                          valueListenable: previousSearchedTextLength,
                          builder: (context, int value, child) {
                            return CustomInkWellContainer(
                              onTap: () {
                                delayTimer?.cancel();
                                cubitReference?.clearCubit();
                                _searchLocation.clear();
                              },
                              child: CustomContainer(
                                  margin:
                                      const EdgeInsetsDirectional.only(end: 5),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 10),
                                  child: value >= 1
                                      ? Icon(
                                          Icons.close,
                                          color: context
                                              .colorScheme.lightGreyColor,
                                        )
                                      : const SizedBox.shrink()),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 2,
                      child: CustomInkWellContainer(
                        onTap: () {
                          if (!curruntlocationprogress) {
                            _requestLocationPermission();
                          }
                        },
                        borderRadius:
                            BorderRadius.circular(UiUtils.borderRadiusOf10),
                        child: CustomContainer(
                          height: 48,
                          width: 48,
                          borderRadius: UiUtils.borderRadiusOf10,
                          color: context.colorScheme.accentColor.withAlpha(20),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: curruntlocationprogress
                              ? CustomCircularProgressIndicator(
                                  strokeWidth: 2,
                                  widthAndHeight: 20,
                                  color: context.colorScheme.accentColor,
                                )
                              : Center(
                                  child: CustomSvgPicture(
                                    svgImage: AppAssets.searchcurrentLocation,
                                    color: context.colorScheme.accentColor,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                BlocBuilder<GooglePlaceAutocompleteCubit,
                    GooglePlaceAutocompleteState>(
                  builder: (BuildContext context, googlePlaceState) {
                    if (googlePlaceState is GooglePlaceAutocompleteInitial) {
                      final List<Map> recentPlaces =
                          HiveRepository.getStoredPlaces;

                      if (recentPlaces.isEmpty) return const SizedBox();
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            CustomText(
                              "recentSearched".translate(context: context),
                              maxLines: 1,
                              color: context.colorScheme.lightGreyColor,
                              fontSize: 14,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            CustomContainer(
                              constraints: BoxConstraints(
                                  minHeight: 100,
                                  maxHeight: context.screenHeight * 0.5),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  children: List.generate(
                                    recentPlaces.length,
                                    (index) => getPlaceContainer(
                                      isFromHistory: true,
                                      longitude: recentPlaces[index]
                                          ["longitude"],
                                      latitude: recentPlaces[index]["latitude"],
                                      placeName: recentPlaces[index]["name"],
                                      placeId: recentPlaces[index]["placeId"],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ]);
                    }
                    if (googlePlaceState is GooglePlaceAutocompleteSuccess) {
                      if ((googlePlaceState.autocompleteResult.predictions ??
                              [])
                          .isNotEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                                CustomText(
                                  "searchResults".translate(context: context),
                                  maxLines: 1,
                                  color: context.colorScheme.blackColor,
                                  fontSize: 14,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ] +
                              List.generate(
                                googlePlaceState
                                    .autocompleteResult.predictions!.length,
                                (index) {
                                  final Prediction placeData = googlePlaceState
                                      .autocompleteResult.predictions![index];
                                  return getPlaceContainer(
                                      isFromHistory: false,
                                      placeName: placeData.description ?? '',
                                      placeId: placeData.placeId ?? '');
                                },
                              ),
                        );
                      }

                      return NoDataFoundWidget(
                          titleKey:
                              'noLocationFound'.translate(context: context),
                          subtitleKey: 'noLocationFoundSubTitle'
                              .translate(context: context));
                    }

                    if (googlePlaceState is GooglePlaceAutocompleteInProgress) {
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(top: 10),
                        child: Center(
                          child: CustomCircularProgressIndicator(
                            color: context.colorScheme.accentColor,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                )
              ],
            ),
          ),
        ),
      );
}
