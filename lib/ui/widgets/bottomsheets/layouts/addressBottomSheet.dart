import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class AddressSheet extends StatefulWidget {
  const AddressSheet({
    required this.addressDataModel,
    final Key? key,
    this.addressId,
    this.isUpdateAddress,
    this.isBilling = false,
  }) : super(key: key);

  /// Billing mode (checkout): the same form, but Save returns the entered
  /// address as a [GetAddressModel] via `Navigator.pop` instead of saving it
  /// to the account.
  final bool isBilling;
  final bool? isUpdateAddress;
  final String? addressId;
  final AddressModel addressDataModel;

  @override
  State<AddressSheet> createState() => _AddressSheetState();
}

class _AddressSheetState extends State<AddressSheet> {
  int locationTypeAddressIndex = 0;
  late AddressModel addressDataModel;
  Map<int, String> locationType = {0: "home", 1: "Office", 2: "Other"};
  bool isSetDefaultAddress = false;
  final GlobalKey<FormState> _addressFormKey = GlobalKey<FormState>();

  // Key to access CustomFieldsForm state for getValues()
  final GlobalKey<CustomFieldsFormState> _customFieldsFormKey =
      GlobalKey<CustomFieldsFormState>();

  late final TextEditingController mobileNumberFieldController =
      TextEditingController(text: addressDataModel.mobile);

  // Country / region pickers. Both are optional: without a country the backend
  // decides it from the address coordinates.
  final AddressRepository _addressRepository = AddressRepository();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  List<Country> _countries = [];
  List<Region> _regions = [];
  Country? _selectedCountry;
  Region? _selectedRegion;
  // Fields render immediately with a spinner instead of popping in once the
  // lists arrive.
  bool _isLoadingCountries = true;
  bool _isLoadingRegions = false;

  @override
  void initState() {
    super.initState();
    isSetDefaultAddress = widget.addressDataModel.isDefault?.toString() == '1';
    addressDataModel = widget.addressDataModel;
    locationTypeAddressIndex = widget.addressDataModel.type == "Office"
        ? 1
        : widget.addressDataModel.type == "Other"
        ? 2
        : 0;
    _loadCountries();
  }

  @override
  void dispose() {
    mobileNumberFieldController.dispose();
    _countryController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  /// Loads active countries and, when editing, pre-selects the saved
  /// country/region. Failure just hides the pickers.
  Future<void> _loadCountries() async {
    try {
      final List<Country> countries = await _addressRepository.fetchCountries();
      if (!mounted) return;
      setState(() {
        _countries = countries;
        _isLoadingCountries = false;
      });

      final String savedCountryId = addressDataModel.countryId ?? '';
      if (savedCountryId.isNotEmpty) {
        final Country? saved = countries
            .where((final c) => c.id == savedCountryId)
            .firstOrNull;
        if (saved == null) return;
        await _applyCountry(saved, savedRegionId: addressDataModel.regionId);
        return;
      }

      // No saved country (new or legacy address): detect it from the pin's
      // coordinates against each country's boundary (language independent).
      final double? lat = double.tryParse(addressDataModel.latitude ?? '');
      final double? lng = double.tryParse(addressDataModel.longitude ?? '');
      if (lat == null || lng == null) return;
      final Country? detected = findByBoundary<Country>(
        countries,
        lat,
        lng,
        (final c) => c.boundary,
      );
      if (detected == null) return;
      addressDataModel = addressDataModel.copyWith(
        countryId: detected.id,
        regionId: '',
      );
      await _applyCountry(detected, detectLat: lat, detectLng: lng);
    } catch (_) {
      if (mounted) setState(() => _isLoadingCountries = false);
    }
  }

  Future<void> _applyCountry(
    final Country country, {
    final String? savedRegionId,
    final double? detectLat,
    final double? detectLng,
  }) async {
    setState(() {
      _selectedCountry = country;
      _selectedRegion = null;
      _regions = [];
      _countryController.text = country.name;
      _regionController.clear();
      _isLoadingRegions = true;
    });
    try {
      final List<Region> regions = await _addressRepository.fetchRegions(
        country.id,
      );
      if (!mounted || _selectedCountry?.id != country.id) return;
      final Region? saved = (savedRegionId ?? '').isNotEmpty
          ? regions.where((final r) => r.id == savedRegionId).firstOrNull
          : (detectLat == null || detectLng == null)
          ? null
          : findByBoundary<Region>(
              regions,
              detectLat,
              detectLng,
              (final r) => r.boundary,
            );
      if (saved != null && (savedRegionId ?? '').isEmpty) {
        addressDataModel = addressDataModel.copyWith(regionId: saved.id);
      }
      setState(() {
        _regions = regions;
        _selectedRegion = saved;
        _regionController.text = saved?.name ?? '';
        _isLoadingRegions = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingRegions = false);
    }
  }

  /// Billing mode: hands the entered country/region/custom fields/mobile back
  /// to the caller. The backend needs a country for a separate billing address.
  void _submitBilling() {
    final Country? country = _selectedCountry;
    if (country == null) {
      UiUtils.showMessage(
        context,
        'selectCountryForBilling'.translate(context: context),
        ToastificationType.warning,
      );
      return;
    }
    final List<Map<String, dynamic>>? values = _customFieldsFormKey.currentState
        ?.getValues();
    Navigator.pop(
      context,
      GetAddressModel(
        id: '',
        type: locationType[locationTypeAddressIndex],
        address: '',
        mobile: mobileNumberFieldController.text.trim(),
        countryId: country.id,
        country: country.name,
        regionId: _selectedRegion?.id ?? '',
        region: _selectedRegion?.name ?? '',
        customFieldValues: {
          for (final Map<String, dynamic> v in values ?? const [])
            '${v['custom_field_id']}': v['value'],
        },
      ),
    );
  }

  Future<void> _pickCountry() async {
    final Country? picked = await _showOptionsSheet<Country>(
      titleKey: 'country',
      items: _countries,
      labelOf: (final c) => c.name,
      flagOf: (final c) => c.flag,
      selected: _selectedCountry,
    );
    if (picked == null || picked.id == _selectedCountry?.id) return;
    // A new country invalidates the stored region.
    addressDataModel = addressDataModel.copyWith(
      countryId: picked.id,
      regionId: '',
    );
    await _applyCountry(picked);
  }

  Future<void> _pickRegion() async {
    final Region? picked = await _showOptionsSheet<Region>(
      titleKey: 'region',
      items: _regions,
      labelOf: (final r) => r.name,
      selected: _selectedRegion,
    );
    if (picked == null) return;
    addressDataModel = addressDataModel.copyWith(regionId: picked.id);
    setState(() {
      _selectedRegion = picked;
      _regionController.text = picked.name;
    });
  }

  /// Single-choice list in the shared [BottomSheetLayout]. [titleKey] is a
  /// translation key (the layout translates it).
  Future<T?> _showOptionsSheet<T>({
    required final String titleKey,
    required final List<T> items,
    required final String Function(T) labelOf,
    required final T? selected,
    final String Function(T)? flagOf,
  }) async => UiUtils.showBottomSheet(
    context: context,
    enableDrag: true,
    // Keep a long country list below the status bar instead of under it.
    useSafeArea: true,
    child: BottomSheetLayout(
      title: titleKey,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            for (final T item in items)
              CustomInkWellContainer(
                onTap: () => Navigator.pop(context, item),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    spacing: 12,
                    children: [
                      if ((flagOf?.call(item) ?? '').isNotEmpty)
                        CustomCachedNetworkImage(
                          networkImageUrl: flagOf!(item),
                          width: 24,
                          height: 16,
                          fit: BoxFit.cover,
                          avoideResponsive: true,
                        ),
                      Expanded(
                        child: CustomText(
                          labelOf(item),
                          fontSize: 14,
                          fontWeight: item == selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: item == selected
                              ? context.colors.textBrand
                              : context.colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  ).then((final value) => value as T?);

  Widget _buildPickerField({
    required final TextEditingController controller,
    required final String labelKey,
    required final VoidCallback onTap,
    final bool isLoading = false,
  }) => CustomTextFormField(
    bottomPadding: 10,
    controller: controller,
    isReadOnly: true,
    callback: isLoading ? null : onTap,
    fillColor: context.colors.backgroundSecondary,
    labelText: labelKey.translate(context: context),
    // Same label-as-hint pattern as the custom address fields above/below.
    hintText: labelKey.translate(context: context),
    suffixIcon: Padding(
      padding: const EdgeInsets.all(12),
      child: isLoading
          ? CustomCircularProgressIndicator(
              color: context.colors.iconPrimary,
              strokeWidth: 2,
              widthAndHeight: 20,
            )
          : CustomSvgPicture(
              svgImage: AppAssets.downArrow,
              height: 24,
              width: 24,
              color: context.colors.iconPrimary,
              avoideResponsive: true,
            ),
    ),
  );

  @override
  Widget build(final BuildContext context) => CustomContainer(
    color: context.colors.backgroundPrimary,
    borderRadiusStyle: const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 8,
                  decoration: BoxDecoration(
                    color: context.colors.borderDefault,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              const CustomSizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: CustomText(
                  (widget.isBilling ? 'billingAddress' : 'manageAddress')
                      .translate(context: context),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textPrimary,
                ),
              ),
              const CustomSizedBox(height: 8),
              CustomContainer(
                height: 1.5,
                color: context.colors.backgroundSecondary,
              ),
            ],
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _addressFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- Address Type (Home / Office / Other) ---
                    StatefulBuilder(
                      builder: (final context, final setState) {
                        addressDataModel = addressDataModel.copyWith(
                          type: locationType[locationTypeAddressIndex],
                        );
                        return Row(
                          children: <Widget>[
                            FlatOutlinedButton(
                              icon: AppAssets.homeAdd,
                              isSelected: locationTypeAddressIndex == 0,
                              name: 'home'.translate(context: context),
                              onTap: () {
                                addressDataModel = addressDataModel.copyWith(
                                  type: 'Home',
                                );
                                locationTypeAddressIndex = 0;
                                setState(() {});
                              },
                            ),
                            const CustomSizedBox(width: 8),
                            FlatOutlinedButton(
                              icon: AppAssets.officeAdd,
                              isSelected: locationTypeAddressIndex == 1,
                              name: 'office'.translate(context: context),
                              onTap: () {
                                addressDataModel = addressDataModel.copyWith(
                                  type: 'Office',
                                );
                                locationTypeAddressIndex = 1;
                                setState(() {});
                              },
                            ),
                            const CustomSizedBox(width: 8),
                            FlatOutlinedButton(
                              icon: AppAssets.mapPinArea,
                              isSelected: locationTypeAddressIndex == 2,
                              name: 'other'.translate(context: context),
                              onTap: () {
                                addressDataModel = addressDataModel.copyWith(
                                  type: 'Other',
                                );
                                locationTypeAddressIndex = 2;
                                setState(() {});
                              },
                            ),
                          ],
                        );
                      },
                    ),

                    const CustomSizedBox(height: 16),

                    // --- Country / region (optional) ---
                    if (_isLoadingCountries || _countries.isNotEmpty)
                      _buildPickerField(
                        controller: _countryController,
                        labelKey: 'country',
                        onTap: _pickCountry,
                        isLoading: _isLoadingCountries,
                      ),
                    // Region slides in (spinner first) instead of popping in.
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment.topCenter,
                      child:
                          _selectedCountry != null &&
                              (_isLoadingRegions || _regions.isNotEmpty)
                          ? _buildPickerField(
                              controller: _regionController,
                              labelKey: 'region',
                              onTap: _pickRegion,
                              isLoading: _isLoadingRegions,
                            )
                          : const SizedBox(width: double.infinity),
                    ),

                    // --- Dynamic custom fields (replaces address + area) ---
                    BlocBuilder<GetCustomFieldsCubit, GetCustomFieldsState>(
                      builder: (context, state) {
                        if (state is GetCustomFieldsInProgress) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: CustomCircularProgressIndicator(),
                            ),
                          );
                        } else if (state is GetCustomFieldsSuccess &&
                            state.fields.isNotEmpty) {
                          return CustomFieldsForm(
                            key: _customFieldsFormKey,
                            fields: state.fields,
                            initialValues: state.savedValues,
                          );
                        } else if (state is GetCustomFieldsFail) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: ErrorContainer(
                              errorMessage: state.error,
                              showErrorImage: false,
                              errorMessageFontSize: 12,
                              onTapRetry: () {
                                context
                                    .read<GetCustomFieldsCubit>()
                                    .fetchCustomFields(
                                      addressId: widget.addressId,
                                    );
                              },
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    // --- Mobile (always shown) ---
                    CustomTextFormField(
                      bottomPadding: 10,
                      validator: (number) => isValidMobileNumber(
                        number: number ?? '',
                        context: context,
                      ),
                      inputFormatters: UiUtils.allowOnlyDigits(),
                      controller: mobileNumberFieldController,
                      textInputType: TextInputType.number,
                      fillColor: context.colors.backgroundSecondary,
                      labelText: 'mobileNumber'.translate(context: context),
                      isRequired: true,
                      hintText: 'enterYourPhoneNumber'.translate(
                        context: context,
                      ),
                    ),

                    // --- Set as Default ---
                    if (!widget.isBilling)
                      Row(
                        children: [
                          StatefulBuilder(
                            builder: (final context, final setState) =>
                                CustomSizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Checkbox(
                                    activeColor: context.colors.backgroundBrand,
                                    fillColor: WidgetStateProperty.resolveWith(
                                      (states) =>
                                          states.contains(WidgetState.selected)
                                          ? context.colors.backgroundBrand
                                          : context.colors.backgroundPrimary,
                                    ),
                                    side: WidgetStateBorderSide.resolveWith(
                                      (states) => BorderSide(
                                        width: 1.0,
                                        color: context.colors.iconPrimary,
                                      ),
                                    ),
                                    shape: const CircleBorder(),
                                    visualDensity: VisualDensity.standard,
                                    checkColor: context.colors.textInverseLight,
                                    value: isSetDefaultAddress,
                                    onChanged: (final value) {
                                      isSetDefaultAddress =
                                          !isSetDefaultAddress;
                                      addressDataModel = addressDataModel
                                          .copyWith(
                                            isDefault: isSetDefaultAddress
                                                ? "1"
                                                : "0",
                                          );
                                      setState(() {});
                                    },
                                  ),
                                ),
                          ),
                          const CustomSizedBox(width: 8),
                          Expanded(
                            child: CustomInkWellContainer(
                              onTap: () {
                                isSetDefaultAddress = !isSetDefaultAddress;
                                addressDataModel = addressDataModel.copyWith(
                                  isDefault: isSetDefaultAddress ? "1" : "0",
                                );
                                setState(() {});
                              },
                              child: CustomText(
                                'setDefaultAddress'.translate(context: context),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: context.colors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: ClipShadowBottom(
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
              child: Padding(
                padding: const EdgeInsets.all(16).copyWith(
                  bottom: 16 + MediaQuery.viewPaddingOf(context).bottom,
                ),
                child: BlocConsumer<AddAddressCubit, AddAddressState>(
                  listener: (final context, final state) {
                    if (state is AddAddressSuccess) {
                      UiUtils.showMessage(
                        context,
                        widget.isUpdateAddress ?? false
                            ? 'addressUpdatedSuccessfully'.translate(
                                context: context,
                              )
                            : 'addressAddedSuccessfully'.translate(
                                context: context,
                              ),
                        ToastificationType.success,
                      );
                    } else if (state is AddAddressFail) {
                      UiUtils.showMessage(
                        context,
                        state.error.toString(),
                        ToastificationType.error,
                      );
                    }
                  },
                  builder: (final context, AddAddressState state) {
                    Widget? child;
                    if (state is AddAddressInProgress) {
                      child = CustomCircularProgressIndicator(
                        color: context.colors.textInverseLight,
                        widthAndHeight: 24,
                      );
                    }

                    void handleSave() {
                      if (state is AddAddressInProgress) return;
                      UiUtils.removeFocus();

                      if (_addressFormKey.currentState!.validate()) {
                        if (widget.isBilling) {
                          _submitBilling();
                          return;
                        }
                        // Collect custom field values (if form is active)
                        final customValues = _customFieldsFormKey.currentState
                            ?.getValues();

                        addressDataModel = addressDataModel.copyWith(
                          mobile: mobileNumberFieldController.value.text.trim(),
                          customFieldValues: customValues,
                        );

                        if (widget.isUpdateAddress ?? false) {
                          final AddressModel model = addressDataModel.copyWith(
                            addressId: widget.addressId,
                          );
                          context.read<AddAddressCubit>().addAddress(model);
                        } else {
                          context.read<AddAddressCubit>().addAddress(
                            addressDataModel,
                          );
                        }
                      }
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: CustomInkWellContainer(
                            borderRadius: BorderRadius.circular(
                              UiUtils.borderRadiusOf12,
                            ),
                            onTap: () => Navigator.pop(context),
                            child: CustomContainer(
                              height: 48,
                              color: context.colors.backgroundBrandSubtle,
                              border: Border.all(
                                color: context.colors.borderBrand,
                              ),
                              borderRadius: UiUtils.borderRadiusOf12,
                              child: Center(
                                child: CustomText(
                                  'close'.translate(context: context),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: context.colors.textBrand,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const CustomSizedBox(width: 12),
                        Expanded(
                          child: CustomInkWellContainer(
                            borderRadius: BorderRadius.circular(
                              UiUtils.borderRadiusOf12,
                            ),
                            onTap: handleSave,
                            child: CustomContainer(
                              height: 48,
                              color: context.colors.backgroundBrand,
                              borderRadius: UiUtils.borderRadiusOf12,
                              child: Center(
                                child:
                                    child ??
                                    CustomText(
                                      (widget.isBilling
                                              ? 'save'
                                              : 'saveAddress')
                                          .translate(context: context),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: context.colors.textInverseLight,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
