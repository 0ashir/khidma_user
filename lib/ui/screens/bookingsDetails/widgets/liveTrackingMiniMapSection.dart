import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class LiveTrackingMiniMapSection extends StatefulWidget {
  final String orderId;
  final String addressId;

  const LiveTrackingMiniMapSection({
    super.key,
    required this.orderId,
    required this.addressId,
  });

  @override
  State<LiveTrackingMiniMapSection> createState() =>
      _LiveTrackingMiniMapSectionState();
}

class _LiveTrackingMiniMapSectionState
    extends State<LiveTrackingMiniMapSection> {
  final GetLiveTrackingDataCubit _cubit = GetLiveTrackingDataCubit();

  double? _orderLat;
  double? _orderLng;
  bool _addressResolved = false;

  @override
  void initState() {
    super.initState();
    _cubit.startPolling(orderId: widget.orderId);
    _resolveOrderAddress();
  }

  Future<void> _resolveOrderAddress() async {
    final addressCubit = context.read<GetAddressCubit>();
    var addressState = addressCubit.state;
    if (addressState is! GetAddressSuccess) {
      await addressCubit.fetchAddress();
      addressState = addressCubit.state;
    }
    if (addressState is GetAddressSuccess) {
      GetAddressModel? matchedAddress;
      for (final address in addressState.data) {
        if (address.id == widget.addressId) {
          matchedAddress = address;
          break;
        }
      }
      _orderLat = double.tryParse(matchedAddress?.lattitude ?? '');
      _orderLng = double.tryParse(matchedAddress?.longitude ?? '');
    }
    if (mounted) setState(() => _addressResolved = true);
  }

  @override
  void dispose() {
    _cubit.stopPolling();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: context.colors.surfacePrimary,
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            'trackProvider'.translate(context: context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.colors.textPrimary,
          ),
          const CustomSizedBox(height: 12),
          Divider(height: 1, color: context.colors.borderDefault),
          const CustomSizedBox(height: 12),
          BlocProvider<GetLiveTrackingDataCubit>.value(
            value: _cubit,
            child:
                BlocBuilder<GetLiveTrackingDataCubit, GetLiveTrackingDataState>(
                  builder: (context, state) {
                    if (!_addressResolved ||
                        state is! GetLiveTrackingDataSuccess) {
                      return const CustomShimmerLoadingContainer(
                        height: 180,
                        borderRadius: UiUtils.borderRadiusOf10,
                      );
                    }
                    return Stack(
                      children: [
                        MiniMapWidget(
                          orderId: widget.orderId,
                          handymanLat: state.data.latitude,
                          handymanLng: state.data.longitude,
                          orderLat: _orderLat,
                          orderLng: _orderLng,
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IgnorePointer(
                            child: CustomContainer(
                              padding: const EdgeInsets.all(8),
                              color: context.colors.backgroundInverse,
                              borderRadius: 100,
                              child: CustomSvgPicture(
                                svgImage: AppAssets.arrowsOutSimple,
                                height: 24,
                                width: 24,
                                color: context.colors.iconInverse,
                                avoideResponsive: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}
