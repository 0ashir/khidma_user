import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ManageAddress extends StatefulWidget {
  const ManageAddress({required this.appBarTitle, final Key? key})
    : super(key: key);
  final String appBarTitle;

  @override
  State<ManageAddress> createState() => _ManageAddressState();

  static Route<ManageAddress> route(final RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, String>;
    return CupertinoPageRoute(
      builder: (final _) =>
          ManageAddress(appBarTitle: arguments["appBarTitle"]!),
    );
  }
}

class _ManageAddressState extends State<ManageAddress> {
  String? _deletingAddressId;

  Widget buildAddressSelector() => MultiBlocListener(
    listeners: [
      BlocListener<AddAddressCubit, AddAddressState>(
        listener:
            (final BuildContext context, AddAddressState addAddressState) {
              if (addAddressState is AddAddressSuccess) {
                final GetAddressModel getAddressModel =
                    GetAddressModel.fromJson(addAddressState.result["data"][0]);
                context.read<AddressesCubit>().addAddress(getAddressModel);
              }
            },
      ),
      BlocListener<DeleteAddressCubit, DeleteAddressState>(
        listener: (final BuildContext context, final DeleteAddressState state) {
          if (state is DeleteAddressSuccess) {
            // When a new default was assigned the API returns the remaining
            // addresses, so reload from them to reflect the new default.
            if (state.data.isNotEmpty) {
              context.read<AddressesCubit>().load(state.data);
            } else {
              context.read<AddressesCubit>().removeAddress(state.id);
            }
            setState(() => _deletingAddressId = null);
          } else if (state is DeleteAddressFail) {
            setState(() => _deletingAddressId = null);
          }
        },
      ),
    ],
    child: BlocConsumer<GetAddressCubit, GetAddressState>(
      listener:
          (final BuildContext context, final GetAddressState getAddressState) {
            if (getAddressState is GetAddressSuccess) {
              context.read<AddressesCubit>().load(getAddressState.data);
            }
          },
      builder: (final BuildContext context, final GetAddressState getAddressState) {
        if (getAddressState is GetAddressFail) {
          return ErrorContainer(
            errorMessage: getAddressState.error.translate(context: context),
            showRetryButton: true,
            onTapRetry: () {
              context.read<GetAddressCubit>().fetchAddress();
            },
          );
        }

        if (getAddressState is GetAddressSuccess) {
          return BlocBuilder<AddressesCubit, AddressesState>(
            builder: (final context, final AddressesState addressesState) {
              if (addressesState is Addresses) {
                if (addressesState.addresses.isEmpty) {
                  return Center(
                    child: NoDataFoundWidget(
                      titleKey: "noAddressFound".translate(context: context),
                      subtitleKey: 'noAddressFoundSubTitle'.translate(
                        context: context,
                      ),
                    ),
                  );
                }
                // Tablet shows 2-column cards (the grid owns the outer
                // padding and gaps); phone keeps the single column.
                final bool isTablet = ResponsiveHelper.isTabletDevice(context);
                final List<Widget>
                cards = List.generate(addressesState.addresses.length, (
                  final int index,
                ) {
                  late GetAddressModel addressData;
                  if (getAddressState.data.isNotEmpty) {
                    addressData = addressesState.addresses[index];
                  }

                  return CustomContainer(
                    margin: isTablet
                        ? EdgeInsets.zero
                        : const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                    padding: const EdgeInsets.all(12),
                    color: context.colors.surfacePrimary,
                    borderRadius: UiUtils.borderRadiusOf12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CustomContainer(
                              color: context.colors.backgroundSecondary,
                              borderRadius: UiUtils.borderRadiusOf8,
                              padding: const EdgeInsets.all(8),
                              child: CustomSvgPicture(
                                svgImage: addressData.type == 'Home'
                                    ? AppAssets.homeAdd
                                    : addressData.type == 'Other'
                                    ? AppAssets.icLocation
                                    : AppAssets.officeAdd,
                                color: context.colors.iconPrimary,
                                height: 24,
                                width: 24,
                                avoideResponsive: true,
                              ),
                            ),
                            const CustomSizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomText(
                                    addressData.type
                                        .toString()
                                        .toLowerCase()
                                        .translate(context: context)
                                        .capitalize(),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: context.colors.textPrimary,
                                  ),
                                  if (addressData.isDefault == '1') ...[
                                    const CustomSizedBox(height: 4),
                                    CustomText(
                                      'defaultAddress'.translate(
                                        context: context,
                                      ),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      color: context.colors.textBrand,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const CustomSizedBox(width: 12),
                            CustomInkWellContainer(
                              borderRadius: BorderRadius.circular(100),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  googleMapRoute,
                                  arguments: {
                                    'screenType':
                                        GoogleMapScreenType.selectLocationOnMap,
                                    "defaultLatitude": addressData.lattitude
                                        .toString(),
                                    "defaultLongitude": addressData.longitude
                                        .toString(),
                                    'details': addressData,
                                    'showAddressForm': true,
                                  },
                                ).then((final Object? value) {
                                  if (!context.mounted) return;
                                  if (value == true) {
                                    context
                                        .read<GetAddressCubit>()
                                        .fetchAddress();
                                  }
                                });
                              },
                              child: CustomContainer(
                                color: context.colors.backgroundSecondary,
                                borderRadius: 100,
                                padding: const EdgeInsets.all(8),
                                child: CustomSvgPicture(
                                  svgImage: AppAssets.edit,
                                  color: context.colors.iconPrimary,
                                  avoideResponsive: true,
                                  height: 20,
                                  width: 20,
                                ),
                              ),
                            ),
                            const CustomSizedBox(width: 12),
                            CustomInkWellContainer(
                              borderRadius: BorderRadius.circular(100),
                              onTap: () {
                                UiUtils.showBottomSheet(
                                  context: context,
                                  enableDrag: true,
                                  isScrollControlled: true,
                                  child: DeleteAddressSheet(
                                    onConfirmButtonPressed: () {
                                      try {
                                        setState(
                                          () => _deletingAddressId =
                                              addressData.id,
                                        );
                                        context
                                            .read<DeleteAddressCubit>()
                                            .deleteAddress(
                                              addressData.id as String,
                                            );
                                        Navigator.pop(context);
                                      } catch (_) {}
                                    },
                                  ),
                                );
                              },
                              child: CustomContainer(
                                color: context.colors.backgroundSecondary,
                                borderRadius: 100,
                                padding: const EdgeInsets.all(8),
                                child:
                                    BlocBuilder<
                                      DeleteAddressCubit,
                                      DeleteAddressState
                                    >(
                                      builder: (context, deleteState) {
                                        if (deleteState
                                                is DeleteAddressInProgress &&
                                            _deletingAddressId ==
                                                addressData.id) {
                                          return CustomCircularProgressIndicator(
                                            color: context.colors.iconPrimary,
                                            widthAndHeight: 20,
                                          );
                                        }
                                        return CustomSvgPicture(
                                          svgImage: AppAssets.drDeleteAccount,
                                          color: context.colors.iconPrimary,
                                          avoideResponsive: true,
                                          height: 20,
                                          width: 20,
                                        );
                                      },
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const CustomSizedBox(height: 12),
                        CustomSizedBox(
                          height: 1,
                          width: double.infinity,
                          child: DashedRect(
                            color: context.colors.borderDefault,
                            strokeWidth: 1,
                            gap: 4,
                          ),
                        ),
                        const CustomSizedBox(height: 12),
                        CustomText(
                          addressData.address ?? '',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: context.colors.textSecondary,
                          maxLines: 3,
                          textAlign: TextAlign.start,
                        ),
                        if (addressData.regionAndCountry.isNotEmpty) ...[
                          const CustomSizedBox(height: 4),
                          CustomText(
                            addressData.regionAndCountry,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: context.colors.textSecondary,
                            maxLines: 1,
                            textAlign: TextAlign.start,
                          ),
                        ],
                        const CustomSizedBox(height: 12),
                        CustomContainer(
                          width: double.infinity,
                          color: context.colors.backgroundSecondary,
                          borderRadius: UiUtils.borderRadiusOf8,
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              CustomSvgPicture(
                                svgImage: AppAssets.phoneCall,
                                color: context.colors.iconPrimary,
                                height: 20,
                                width: 20,
                                avoideResponsive: true,
                              ),
                              const CustomSizedBox(width: 8),
                              CustomText(
                                '${addressData.mobile}',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: context.colors.textPrimary,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                });
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      top: 16.0,
                      bottom: 8.0,
                    ),
                    child: isTablet
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: EqualHeightGrid(
                              spacing: 16,
                              children: cards,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: cards,
                          ),
                  ),
                );
              }

              return const CustomSizedBox();
            },
          );
        }
        const Widget shimmer = CustomShimmerLoadingContainer(
          margin: EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          height: 140,
          width: 24,
        );
        final int columns = ResponsiveHelper.isTabletDevice(context) ? 2 : 1;
        return ListView.builder(
          itemCount: (UiUtils.numberOfShimmerContainer / columns).ceil(),
          shrinkWrap: true,
          itemBuilder: (context, int index) => columns > 1
              ? EqualHeightGrid(
                  spacing: 8,
                  children: List.filled(columns, shimmer),
                )
              : shimmer,
        );
      },
    ),
  );

  @override
  void initState() {
    super.initState();
    context.read<GetAddressCubit>().fetchAddress();
  }

  @override
  Widget build(final BuildContext context) => InterstitialAdWidget(
    child: AnnotatedSafeArea(
      isAnnotated: true,
      applyBottomInset: false,
      child: Scaffold(
        backgroundColor: context.colors.backgroundSecondary,
        appBar: UiUtils.getSimpleAppBar(
          context: context,
          title: widget.appBarTitle.translate(context: context).capitalize(),
        ),
        body: CustomRefreshIndicator(
          displacment: 12,
          onRefreshCallback: () {
            context.read<GetAddressCubit>().fetchAddress();
          },
          child: buildAddressSelector(),
        ),
        bottomNavigationBar: ClipShadowBottom(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.colors.backgroundPrimary,
              boxShadow: [
                BoxShadow(
                  color: context.colors.overlayFooterShadow,
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AddAddressContainer(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      googleMapRoute,
                      arguments: {
                        'screenType': GoogleMapScreenType.selectLocationOnMap,
                        "defaultLatitude": HiveRepository.getLatitude,
                        "defaultLongitude": HiveRepository.getLongitude,
                        'showAddressForm': true,
                      },
                    ).then((final Object? value) {
                      if (!context.mounted) return;
                      context.read<GetAddressCubit>().fetchAddress();
                    });
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
