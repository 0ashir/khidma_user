import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class AddressBottomSheet extends StatefulWidget {
  const AddressBottomSheet({
    super.key,
    required this.addresses,
    required this.defaultAddress,
  });
  final List<GetAddressModel> addresses;
  final GetAddressModel defaultAddress;
  @override
  State<AddressBottomSheet> createState() => _AddressBottomSheetState();
}

class _AddressBottomSheetState extends State<AddressBottomSheet> {
  String? _deletingAddressId;

  void _onAddAddressTap() {
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
      if (!mounted) return;
      context.read<GetAddressCubit>().fetchAddress();
      Navigator.pop(context);
    });
  }

  Widget _buildHeader() => Column(
    children: [
      const CustomSizedBox(height: 8),
      Container(
        width: 40,
        height: 8,
        decoration: BoxDecoration(
          color: context.colors.backgroundTertiary,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      const CustomSizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: CustomText(
              'manageLocation'.translate(context: context),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
      const CustomSizedBox(height: 16),
      Divider(height: 1, color: context.colors.borderDefault),
    ],
  );

  Widget _buildAddressCard(final GetAddressModel addressData) => AddressCard(
    title: addressData.type!,
    subTitle: addressData.address ?? '',
    value: addressData.id!,
    addressData: addressData,
    isDeleting: _deletingAddressId == addressData.id,
    onDeleteTap: () {
      setState(() => _deletingAddressId = addressData.id);
      context.read<DeleteAddressCubit>().deleteAddress(addressData.id!);
    },
    onChanged: (final Object? selectedValue) {
      Navigator.pop(context, {'selectedAddress': addressData});
    },
  );

  Widget _buildAddressCards(final List<GetAddressModel> addresses) {
    final List<Widget> cards = addresses.map(_buildAddressCard).toList();
    if (ResponsiveHelper.isTabletDevice(context)) {
      return EqualHeightGrid(children: cards);
    }
    return Column(
      children: [
        for (int index = 0; index < cards.length; index++) ...[
          if (index > 0) const CustomSizedBox(height: 12),
          cards[index],
        ],
      ],
    );
  }

  Widget _buildAddressList() => BlocBuilder<GetAddressCubit, GetAddressState>(
    builder: (context, getAddressState) {
      List<GetAddressModel> addresses = widget.addresses;

      if (getAddressState is GetAddressSuccess) {
        addresses = getAddressState.data;
      }

      if (addresses.isEmpty) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: _buildAddressCards(addresses),
      );
    },
  );

  Widget _buildFooter() => ClipShadowBottom(
    child: CustomContainer(
      color: context.colors.surfacePrimary,
      padding: const EdgeInsets.all(
        16,
      ).copyWith(bottom: 16 + MediaQuery.viewPaddingOf(context).bottom),
      boxShadow: [
        BoxShadow(
          blurRadius: 16,
          offset: const Offset(0, -2),
          color: context.colors.overlayFooterShadow,
        ),
      ],
      child: AddAddressContainer(onTap: _onAddAddressTap),
    ),
  );

  @override
  Widget build(final BuildContext context) => MultiBlocListener(
    listeners: [
      BlocListener<AddAddressCubit, AddAddressState>(
        listener: (context, addAddressState) {
          if (addAddressState is AddAddressSuccess) {
            context.read<GetAddressCubit>().fetchAddress();
          }
        },
      ),
      BlocListener<DeleteAddressCubit, DeleteAddressState>(
        listener: (context, deleteAddressState) {
          if (deleteAddressState is DeleteAddressSuccess) {
            setState(() => _deletingAddressId = null);
            context.read<GetAddressCubit>().fetchAddress();
          } else if (deleteAddressState is DeleteAddressFail) {
            setState(() => _deletingAddressId = null);
          }
        },
      ),
    ],
    child: CustomContainer(
      color: context.colors.surfacePrimary,
      borderRadiusStyle: const BorderRadius.vertical(top: Radius.circular(16)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildHeader(),
            ),
            _buildAddressList(),
            _buildFooter(),
          ],
        ),
      ),
    ),
  );
}
