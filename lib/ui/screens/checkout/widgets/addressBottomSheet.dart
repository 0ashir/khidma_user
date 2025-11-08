import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class AddressBotoomSheet extends StatefulWidget {
  const AddressBotoomSheet(
      {super.key, required this.addresses, required this.defaultAddress});
  final List<GetAddressModel> addresses;
  final GetAddressModel defaultAddress;
  @override
  State<AddressBotoomSheet> createState() => _AddressBotoomSheetState();
}

class _AddressBotoomSheetState extends State<AddressBotoomSheet> {
  String? selectedAddressId;

  @override
  void initState() {
    selectedAddressId = widget.defaultAddress.id;
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    return BottomSheetLayout(
      title: 'selectAddress',
      bottomWidget: CustomContainer(
        color: context.colorScheme.secondaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: AddAddressContainer(
          onTap: () {
            Navigator.pushNamed(
              context,
              googleMapRoute,
              arguments: {
                "defaultLatitude": HiveRepository.getLatitude,
                "defaultLongitude": HiveRepository.getLongitude,
                'showAddressForm': true,
                'screenType': GoogleMapScreenType.selectLocationOnMap,
              },
            ).then((final Object? value) {
              context.read<GetAddressCubit>().fetchAddress();
              Navigator.pop(context);
            });
          },
        ),
      ),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              widget.addresses.length,
              (final int index) {
                late GetAddressModel addressData;
                if (widget.addresses.isNotEmpty) {
                  addressData = widget.addresses[index];
                }

                return CustomContainer(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                  color: context.colorScheme.secondaryColor,
                  borderRadius: UiUtils.borderRadiusOf10,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 12.0),
                    child: AddressRadioOptionsWidget(
                      title: addressData.type!,
                      subTitle:
                          '${addressData.address}, ${addressData.area}, ${addressData.cityName}',
                      value: addressData.id!,
                      groupValue: selectedAddressId!,
                      applyAccentColor: true,
                      onChanged: (final Object? selectedValue) {
                        Navigator.pop(
                            context, {'selectedAddress': addressData});
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
