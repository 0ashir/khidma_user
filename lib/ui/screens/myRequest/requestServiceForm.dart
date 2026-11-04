import 'package:e_demand/app/generalImports.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RequestServiceFormScreen extends StatefulWidget {
  const RequestServiceFormScreen({
    final Key? key,
    this.categoryId,
    this.categoryName,
    this.categoryPath,
  }) : super(key: key);

  final String? categoryId;
  final String? categoryName;
  final List<String>? categoryPath;

  static Route route(final RouteSettings settings) {
    final arguments = settings.arguments as Map?;
    return CupertinoPageRoute(
      builder: (final context) => RequestServiceFormScreen(
        categoryId: arguments?['categoryId'],
        categoryName: arguments?['categoryName'],
        categoryPath: (arguments?['categoryPath'] as List?)?.cast<String>(),
      ),
    );
  }

  @override
  State<RequestServiceFormScreen> createState() =>
      _RequestServiceFormScreenState();
}

class _SelectedFile {
  final String path;
  final String name;
  final String type;

  _SelectedFile({required this.path, required this.name, required this.type});
}

class _RequestServiceFormScreenState extends State<RequestServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController serviceTitleController = TextEditingController();
  TextEditingController serviceDescriptionController = TextEditingController();
  TextEditingController minBudgetController = TextEditingController();
  TextEditingController maxBudgetController = TextEditingController();
  TextEditingController startFromController = TextEditingController();
  TextEditingController endAtController = TextEditingController();
  String selectedStartDate = '';
  String selectedStartTime = '';
  String selectedEndDate = '';
  String selectedEndTime = '';
  String rawStartTime = '';
  String rawEndTime = '';
  String get _currencyPrefixText {
    final String countrySymbol =
        context.read<CountrySettingsCubit>().countrySettings?.currencySymbol ??
        '';
    return '${countrySymbol.isNotEmpty ? countrySymbol : context.read<SystemSettingCubit>().systemCurrency} ';
  }

  String? categoryId;
  String? categoryName;
  String? _attachmentType;
  final List<_SelectedFile> _selectedFiles = [];

  @override
  void initState() {
    categoryId = widget.categoryId;
    categoryName = widget.categoryName;
    super.initState();
  }

  @override
  void dispose() {
    serviceTitleController.dispose();
    serviceDescriptionController.dispose();
    minBudgetController.dispose();
    maxBudgetController.dispose();
    startFromController.dispose();
    endAtController.dispose();
    super.dispose();
  }

  List<String> get _selectedCategoryPath =>
      (widget.categoryPath != null && widget.categoryPath!.isNotEmpty)
      ? widget.categoryPath!
      : [if (categoryName != null) categoryName!];

  @override
  Widget build(final BuildContext context) =>
      AnnotatedRegion<SystemUiOverlayStyle>(
        value: UiUtils.getSystemUiOverlayStyle(context: context),
        child: AnnotatedSafeArea(
          isAnnotated: true,
          applyBottomInset: false,
          child: Scaffold(
            backgroundColor: context.colors.backgroundSecondary,
            appBar: UiUtils.getSimpleAppBar(
              context: context,
              title: 'requestService'.translate(context: context),
              isLeadingIconEnable: true,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(70.rh(context)),
                child: const RequestServiceStepper(currentStep: 2),
              ),
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsetsDirectional.only(
                    bottom:
                        (kBottomNavigationBarHeight + 25).rh(context) +
                        MediaQuery.viewPaddingOf(context).bottom,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSelectedCategoriesCard(),
                          const CustomSizedBox(height: 12),
                          _buildServiceDescriptionCard(),
                          const CustomSizedBox(height: 12),
                          _buildPreferredBudgetCard(),
                          const CustomSizedBox(height: 12),
                          _buildRequestDurationCard(),
                          Builder(
                            builder: (context) {
                              final settings = context
                                  .read<SystemSettingCubit>()
                                  .customJobSettings;
                              if (settings == null) {
                                return const SizedBox.shrink();
                              }
                              final Widget? attachSection =
                                  _buildFileAttachSection(settings);
                              if (attachSection == null) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: attachSection,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ClipShadowBottom(
                    child: CustomContainer(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16).copyWith(
                        bottom: 16 + MediaQuery.viewPaddingOf(context).bottom,
                      ),
                      color: context.colors.backgroundPrimary,
                      boxShadow: [
                        BoxShadow(
                          color: context.colors.overlayFooterShadow,
                          offset: const Offset(0, -2),
                          blurRadius: 8,
                        ),
                      ],
                      child: BlocConsumer<MyRequestCubit, MyRequestState>(
                        listener: (context, state) {
                          if (state is MyRequestSSuccess) {
                            context.read<MyRequestListCubit>().fetchRequests();

                            Navigator.of(context).pushNamed(
                              customJobRequestSuccessScreen,
                              arguments: {
                                'requestId':
                                    state.response['data']?['id']?.toString() ??
                                    '',
                              },
                            );
                          }
                        },
                        builder: (context, state) {
                          return CustomRoundedButton(
                            onTap: () {
                              if (state is MyRequestLoading) return;
                              _submitForm(context);
                            },
                            buttonTitle: 'submitRequest'.translate(
                              context: context,
                            ),
                            showBorder: false,
                            widthPercentage: 1,
                            backgroundColor: context.colors.backgroundBrand,
                            radius: UiUtils.borderRadiusOf12,
                            textSize: 16,
                            fontWeight: FontWeight.w500,
                            child:
                                context.read<MyRequestCubit>().state
                                        is MyRequestLoading ||
                                    context.read<MyRequestListCubit>().state
                                        is MyRequestListInProgress
                                ? Center(
                                    child: CustomCircularProgressIndicator(
                                      color: context.colors.textInverseLight,
                                    ),
                                  )
                                : null,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildCard({
    required final String title,
    final Widget? trailingHeader,
    required final Widget child,
  }) => CustomContainer(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    color: context.colors.surfacePrimary,
    borderRadius: 12,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CustomText(
                title,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                maxLines: 1,
                color: context.colors.textPrimary,
              ),
            ),
            if (trailingHeader != null) ...[
              const CustomSizedBox(width: 8),
              trailingHeader,
            ],
          ],
        ),
        const CustomSizedBox(height: 8),
        Divider(height: 1, color: context.colors.borderMuted),
        const CustomSizedBox(height: 8),
        child,
      ],
    ),
  );

  Widget _buildSelectedCategoriesCard() => _buildCard(
    title: 'selectedCategories'.translate(context: context),
    child: Row(
      children: [
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              for (int i = 0; i < _selectedCategoryPath.length; i++) ...[
                if (i > 0)
                  CustomSvgPicture(
                    svgImage:
                        Directionality.of(context).toString().contains(
                          TextDirection.RTL.value.toLowerCase(),
                        )
                        ? AppAssets.backArrow
                        : AppAssets.backArrowLtr,
                    height: 16,
                    width: 16,
                    color: context.colors.iconPrimary,
                    avoideResponsive: true,
                  ),
                CustomText(
                  _selectedCategoryPath[i],
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: context.colors.textPrimary,
                ),
              ],
            ],
          ),
        ),
        const CustomSizedBox(width: 8),
        CustomInkWellContainer(
          onTap: () => Navigator.pop(context),
          child: CustomContainer(
            padding: const EdgeInsets.all(8),
            color: context.colors.backgroundSecondary,
            borderRadius: 24,
            child: CustomSvgPicture(
              svgImage: AppAssets.edit,
              height: 20,
              width: 20,
              color: context.colors.iconPrimary,
              avoideResponsive: true,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildServiceDescriptionCard() => _buildCard(
    title: 'serviceDescription'.translate(context: context),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextFormField(
          controller: serviceTitleController,
          validator: (value) =>
              isTextFieldEmpty(value: value, context: context),
          labelText: 'serviceTitle'.translate(context: context),
          hintText: 'serviceTitle'.translate(context: context),
          isRequired: true,
          fillColor: context.colors.backgroundSecondary,
        ),
        CustomTextFormField(
          validator: (value) =>
              isTextFieldEmpty(value: value, context: context),
          expands: true,
          heightVal: 70,
          textInputType: TextInputType.multiline,
          controller: serviceDescriptionController,
          labelText: 'description'.translate(context: context),
          hintText: 'description'.translate(context: context),
          isRequired: true,
          fillColor: context.colors.backgroundSecondary,
        ),
      ],
    ),
  );

  Widget _buildPreferredBudgetCard() => _buildCard(
    title: 'preferredBudget'.translate(context: context),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomTextFormField(
            prefixText: _currencyPrefixText,
            controller: minBudgetController,
            validator: (value) => value!.isEmpty
                ? 'enterMinPrice'.translate(context: context)
                : null,
            textInputType: TextInputType.number,
            allowOnlySingleDecimalPoint: true,
            labelText: 'min'.translate(context: context),
            isRequired: true,
            fillColor: context.colors.backgroundSecondary,
            bottomPadding: 0,
          ),
        ),
        const CustomSizedBox(width: 12),
        Expanded(
          child: CustomTextFormField(
            prefixText: _currencyPrefixText,
            controller: maxBudgetController,
            textInputType: TextInputType.number,
            validator: (value) => value!.isEmpty
                ? 'enterMaxPrice'.translate(context: context)
                : null,
            allowOnlySingleDecimalPoint: true,
            labelText: 'max'.translate(context: context),
            isRequired: true,
            fillColor: context.colors.backgroundSecondary,
            bottomPadding: 0,
          ),
        ),
      ],
    ),
  );

  Widget _buildDateTimeSuffixIcon() => Padding(
    padding: const EdgeInsets.all(12),
    child: CustomSvgPicture(
      svgImage: AppAssets.calendar,
      height: 24,
      width: 24,
      color: context.colors.iconPrimary,
      avoideResponsive: true,
    ),
  );

  Widget _buildRequestDurationCard() => _buildCard(
    title: 'requestDuration'.translate(context: context),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextFormField(
          validator: (value) => value!.isEmpty
              ? 'selectStartDateTime'.translate(context: context)
              : null,
          hintText: 'selectStartDateTime'.translate(context: context),
          controller: startFromController,
          callback: () => _selectStartDateTime(context),
          textInputType: TextInputType.datetime,
          isReadOnly: true,
          labelText: 'startAt'.translate(context: context),
          isRequired: true,
          fillColor: context.colors.backgroundSecondary,
          suffixIcon: _buildDateTimeSuffixIcon(),
          bottomPadding: 0,
        ),
        const CustomSizedBox(height: 12),
        CustomTextFormField(
          validator: (value) => value!.isEmpty
              ? 'selectEndDateTime'.translate(context: context)
              : null,
          hintText: 'selectEndDateTime'.translate(context: context),
          controller: endAtController,
          isReadOnly: true,
          callback: () => _selectEndDateTime(context),
          labelText: 'endAt'.translate(context: context),
          isRequired: true,
          fillColor: context.colors.backgroundSecondary,
          suffixIcon: _buildDateTimeSuffixIcon(),
          bottomPadding: 0,
        ),
        const CustomSizedBox(height: 8),
        CustomText(
          'bidWindowHelperText'.translate(context: context),
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: context.colors.textTertiary,
        ),
      ],
    ),
  );

  String _attachmentTypeLabel(final String type) => switch (type) {
    'video' => 'videos'.translate(context: context),
    'document' => 'documents'.translate(context: context),
    _ => 'images'.translate(context: context),
  };

  Widget _buildTypeDropdown(final List<String> allowedTypes) =>
      PopupMenuButton<String>(
        onSelected: (value) => setState(() => _attachmentType = value),
        color: context.colors.surfacePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        itemBuilder: (context) => [
          for (final type in allowedTypes)
            PopupMenuItem<String>(
              value: type,
              child: CustomText(
                _attachmentTypeLabel(type),
                fontSize: 14,
                color: context.colors.textPrimary,
              ),
            ),
        ],
        child: CustomContainer(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          color: context.colors.backgroundSecondary,
          border: Border.all(color: context.colors.borderDefault),
          borderRadius: 8,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                _attachmentTypeLabel(_attachmentType!),
                fontSize: 12,
                color: context.colors.textPrimary,
              ),
              const CustomSizedBox(width: 4),
              CustomSvgPicture(
                svgImage: AppAssets.downArrow,
                height: 16,
                width: 16,
                color: context.colors.iconPrimary,
                avoideResponsive: true,
              ),
            ],
          ),
        ),
      );

  Widget _buildUploadBox(final CustomJobSettings settings) {
    final String sizeMb = _attachmentType == 'video'
        ? settings.maxFileSizeVideo.toString()
        : _attachmentType == 'document'
        ? settings.maxFileSizeOther.toString()
        : settings.maxFileSizeImages.toString();
    final String extLabel = _attachmentType == 'video'
        ? 'MP4, MOV'
        : _attachmentType == 'document'
        ? 'PDF, DOC'
        : 'JPG, PNG';
    final String uploadLabelKey = _attachmentType == 'video'
        ? 'uploadVideos'
        : _attachmentType == 'document'
        ? 'uploadDocuments'
        : 'uploadImages';

    return CustomInkWellContainer(
      onTap: () {
        if (_selectedFiles.length >= settings.maxFilesAllowed) {
          UiUtils.showMessage(
            context,
            '${'maxFilesReached'.translate(context: context)} (${settings.maxFilesAllowed})',
            ToastificationType.warning,
          );
          return;
        }
        if (_attachmentType == 'video') {
          _pickVideos(settings);
        } else if (_attachmentType == 'document') {
          _pickDocuments(settings);
        } else {
          _pickImages(settings);
        }
      },
      child: CustomContainer(
        width: double.infinity,
        color: context.colors.backgroundSecondary,
        borderRadius: 8,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: DashedRect(
                color: context.colors.borderDefault,
                strokeWidth: 1.5,
                gap: 4,
                borderRadius: 8,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomContainer(
                    height: 40,
                    width: 40,
                    borderRadius: 24,
                    color: context.colors.backgroundSecondary,
                    child: Center(
                      child: CustomSvgPicture(
                        svgImage: AppAssets.fileText,
                        height: 24,
                        width: 24,
                        color: context.colors.iconPrimary,
                        avoideResponsive: true,
                      ),
                    ),
                  ),
                  const CustomSizedBox(height: 8),
                  CustomText(
                    uploadLabelKey.translate(context: context),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textPrimary,
                  ),
                  const CustomSizedBox(height: 2),
                  CustomText(
                    '${'upTo'.translate(context: context)} $sizeMb${'mb'.translate(context: context)} • $extLabel',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: context.colors.textSecondary,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const int _maxVisibleImageThumbnails = 4;

  Widget _buildImageThumbnail(final _SelectedFile file, final int index) =>
      SizedBox(
        height: 48,
        width: 48,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(file.path),
                height: 48,
                width: 48,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: -4,
              right: -4,
              child: CustomInkWellContainer(
                onTap: () => setState(() => _selectedFiles.removeAt(index)),
                child: CustomContainer(
                  height: 16,
                  width: 16,
                  borderRadius: 8,
                  color: context.colors.surfacePrimary,
                  border: Border.all(color: context.colors.borderDefault),
                  child: Icon(
                    Icons.close_rounded,
                    size: 11,
                    color: context.colors.iconPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildImageOverflowTile(
    final _SelectedFile file,
    final int remaining,
    final List<_SelectedFile> allImages,
  ) => CustomInkWellContainer(
    onTap: () => _showAllImagesBottomSheet(allImages),
    child: SizedBox(
      height: 48,
      width: 48,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Image.file(
              File(file.path),
              height: 48,
              width: 48,
              fit: BoxFit.cover,
            ),
            Container(
              height: 48,
              width: 48,
              color: context.colors.overlayDefault,
              alignment: Alignment.center,
              child: CustomText(
                '+$remaining',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.colors.textInverseLight,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  void _showAllImagesBottomSheet(final List<_SelectedFile> images) {
    UiUtils.showBottomSheet(
      context: context,
      useSafeArea: true,
      child: StatefulBuilder(
        builder: (final context, final setSheetState) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 8,
                  decoration: BoxDecoration(
                    color: context.colors.backgroundTertiary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              const CustomSizedBox(height: 16),
              CustomText(
                'images'.translate(context: context),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: context.colors.textPrimary,
              ),
              const CustomSizedBox(height: 8),
              Divider(height: 1, color: context.colors.borderMuted),
              const CustomSizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final file in List<_SelectedFile>.from(images))
                        _buildBottomSheetImageTile(file, images, setSheetState),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheetImageTile(
    final _SelectedFile file,
    final List<_SelectedFile> images,
    final StateSetter setSheetState,
  ) => SizedBox(
    height: 80,
    width: 80,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.file(
            File(file.path),
            height: 80,
            width: 80,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: CustomInkWellContainer(
            onTap: () {
              setState(() => _selectedFiles.remove(file));
              setSheetState(() => images.remove(file));
              if (images.isEmpty && mounted) Navigator.pop(context);
            },
            child: CustomContainer(
              height: 20,
              width: 20,
              borderRadius: 10,
              color: context.colors.surfacePrimary,
              border: Border.all(color: context.colors.borderDefault),
              child: Icon(
                Icons.close_rounded,
                size: 14,
                color: context.colors.iconPrimary,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildImageRow(final List<_SelectedFile> images) {
    final int visibleCount = images.length > _maxVisibleImageThumbnails
        ? _maxVisibleImageThumbnails
        : images.length;
    final int remaining = images.length - _maxVisibleImageThumbnails;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: visibleCount,
        separatorBuilder: (_, __) => const CustomSizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == visibleCount - 1 && remaining > 0) {
            return _buildImageOverflowTile(images[index], remaining, images);
          }
          return _buildImageThumbnail(
            images[index],
            _selectedFiles.indexOf(images[index]),
          );
        },
      ),
    );
  }

  Widget _buildFileListRow(final _SelectedFile file, final int index) =>
      CustomContainer(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: context.colors.backgroundSecondary,
        borderRadius: 8,
        child: Row(
          children: [
            CustomSvgPicture(
              svgImage: file.type == 'video'
                  ? AppAssets.play
                  : AppAssets.fileText,
              height: 20,
              width: 20,
              color: context.colors.iconSecondary,
              avoideResponsive: true,
            ),
            const CustomSizedBox(width: 8),
            Expanded(
              child: CustomText(
                file.name,
                maxLines: 1,
                fontSize: 13,
                color: context.colors.textPrimary,
              ),
            ),
            CustomInkWellContainer(
              onTap: () => setState(() => _selectedFiles.removeAt(index)),
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: context.colors.iconSecondary,
              ),
            ),
          ],
        ),
      );

  Widget _buildSelectedFilesPreview() {
    final List<_SelectedFile> images = _selectedFiles
        .where((f) => f.type == 'image')
        .toList();
    final List<_SelectedFile> others = _selectedFiles
        .where((f) => f.type != 'image')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (images.isNotEmpty) _buildImageRow(images),
        if (images.isNotEmpty && others.isNotEmpty)
          const CustomSizedBox(height: 12),
        for (int i = 0; i < others.length; i++) ...[
          if (i > 0) const CustomSizedBox(height: 8),
          _buildFileListRow(others[i], _selectedFiles.indexOf(others[i])),
        ],
      ],
    );
  }

  Widget? _buildFileAttachSection(final CustomJobSettings settings) {
    final List<String> allowedTypes = [
      if (settings.allowImageUploads) 'image',
      if (settings.allowVideoUploads) 'video',
      if (settings.allowDocumentUploads) 'document',
    ];
    if (allowedTypes.isEmpty) return null;
    if (_attachmentType == null || !allowedTypes.contains(_attachmentType)) {
      _attachmentType = allowedTypes.first;
    }

    return _buildCard(
      title: 'attachReferenceFiles'.translate(context: context),
      trailingHeader: allowedTypes.length > 1
          ? _buildTypeDropdown(allowedTypes)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUploadBox(settings),
          if (_selectedFiles.isNotEmpty) ...[
            const CustomSizedBox(height: 12),
            _buildSelectedFilesPreview(),
          ],
        ],
      ),
    );
  }

  Future<void> _selectStartDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? widget) => Theme(
        data: ThemeData(
          colorScheme: Theme.of(context).brightness == Brightness.light
              ? ColorScheme.light(primary: context.colors.backgroundBrand)
              : ColorScheme.dark(primary: context.colors.backgroundBrand),
          datePickerTheme: DatePickerThemeData(
            backgroundColor: context.colors.backgroundSecondary,
            dividerColor: Colors.transparent,
            headerBackgroundColor: context.colors.backgroundSecondary,
            headerForegroundColor: context.colors.textBrand,
          ),
        ),
        child: CustomSizedBox(child: widget),
      ),
    );

    if (!context.mounted) return;
    if (pickedDate != null) {
      // Get current locale using common method from StringExtension
      final currentLocale = StringExtension.getCurrentLocale(context);
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          // Override locale to use app's selected language
          return Localizations.override(
            context: context,
            locale: currentLocale,
            child: child,
          );
        },
      );

      if (pickedTime != null) {
        final DateTime pickedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          selectedStartDate =
              '${pickedDate.year}-${pickedDate.month}-${pickedDate.day}';
          selectedStartTime = '${pickedDateTime.hour}:${pickedDateTime.minute}';
          startFromController.text = pickedDateTime
              .toString()
              .formatDateAndTime();
          rawStartTime = pickedDateTime.toString();
        });
      }
    }
  }

  Future<void> _selectEndDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(rawStartTime),
      firstDate: DateTime.parse(rawStartTime),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? widget) => Theme(
        data: ThemeData(
          colorScheme: Theme.of(context).brightness == Brightness.light
              ? ColorScheme.light(primary: context.colors.backgroundBrand)
              : ColorScheme.dark(primary: context.colors.backgroundBrand),
          datePickerTheme: DatePickerThemeData(
            backgroundColor: context.colors.backgroundSecondary,
            dividerColor: Colors.transparent,
            headerBackgroundColor: context.colors.backgroundSecondary,
            headerForegroundColor: context.colors.textBrand,
          ),
        ),
        child: CustomSizedBox(child: widget),
      ),
    );

    if (!context.mounted) return;
    if (pickedDate != null) {
      // Get current locale using common method from StringExtension
      final currentLocale = StringExtension.getCurrentLocale(context);
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
          hour: DateTime.parse(rawStartTime).hour,
          minute: DateTime.parse(rawStartTime).minute,
        ),
        builder: (BuildContext context, Widget? child) {
          // Override locale to use app's selected language
          return Localizations.override(
            context: context,
            locale: currentLocale,
            child: child,
          );
        },
      );

      if (pickedTime != null) {
        final DateTime pickedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          selectedEndDate =
              '${pickedDate.year}-${pickedDate.month}-${pickedDate.day}';
          selectedEndTime = '${pickedDateTime.hour}:${pickedDateTime.minute}';
          endAtController.text = pickedDateTime.toString().formatDateAndTime();
          rawEndTime = pickedDateTime.toString();
        });
      }
    }
  }

  Future<void> _pickImages(CustomJobSettings settings) async {
    if (_selectedFiles.length >= settings.maxFilesAllowed) {
      UiUtils.showMessage(
        context,
        '${'maxFilesReached'.translate(context: context)} (${settings.maxFilesAllowed})',
        ToastificationType.warning,
      );
      return;
    }
    try {
      final picker = ImagePicker();
      final result = await picker.pickMultiImage();
      int oversized = 0;
      for (final file in result) {
        if (_selectedFiles.length >= settings.maxFilesAllowed) break;
        final size = await File(file.path).length();
        if (size > settings.maxFileSizeImages * 1024 * 1024) {
          oversized++;
          continue;
        }
        if (!_selectedFiles.any((f) => f.path == file.path)) {
          _selectedFiles.add(
            _SelectedFile(path: file.path, name: file.name, type: 'image'),
          );
        }
      }
      if (oversized > 0 && mounted) {
        UiUtils.showMessage(
          context,
          '${'fileSizeExceededLimit'.translate(context: context)} (${settings.maxFileSizeImages} ${'mb'.translate(context: context)})',
          ToastificationType.warning,
        );
      }
    } on PlatformException catch (_) {
      if (mounted) {
        UiUtils.showMessage(
          context,
          'permissionNotGiven'.translate(context: context),
          ToastificationType.error,
        );
      }
    }
    setState(() {});
  }

  Future<void> _pickVideos(CustomJobSettings settings) async {
    if (_selectedFiles.length >= settings.maxFilesAllowed) {
      UiUtils.showMessage(
        context,
        '${'maxFilesReached'.translate(context: context)} (${settings.maxFilesAllowed})',
        ToastificationType.warning,
      );
      return;
    }
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'mp4',
          'mov',
          'avi',
          'mkv',
          'wmv',
          '3gp',
          'webm',
          'm4v',
        ],
      );
      if (result.isNotEmpty) {
        int oversized = 0;
        for (final file in result) {
          if (_selectedFiles.length >= settings.maxFilesAllowed) break;
          final path = file.path;
          if (path == null) continue;
          if ((await file.length() ?? 0) >
              settings.maxFileSizeVideo * 1024 * 1024) {
            oversized++;
            continue;
          }
          if (!_selectedFiles.any((f) => f.path == path)) {
            _selectedFiles.add(
              _SelectedFile(path: path, name: file.name, type: 'video'),
            );
          }
        }
        if (oversized > 0 && mounted) {
          UiUtils.showMessage(
            context,
            '${'fileSizeExceededLimit'.translate(context: context)} (${settings.maxFileSizeVideo} ${'mb'.translate(context: context)})',
            ToastificationType.warning,
          );
        }
      }
    } on PlatformException catch (_) {
      if (mounted) {
        UiUtils.showMessage(
          context,
          'permissionNotGiven'.translate(context: context),
          ToastificationType.error,
        );
      }
    }
    setState(() {});
  }

  Future<void> _pickDocuments(CustomJobSettings settings) async {
    if (_selectedFiles.length >= settings.maxFilesAllowed) {
      UiUtils.showMessage(
        context,
        '${'maxFilesReached'.translate(context: context)} (${settings.maxFilesAllowed})',
        ToastificationType.warning,
      );
      return;
    }
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
          'txt',
          'csv',
        ],
      );
      if (result.isNotEmpty) {
        int oversized = 0;
        for (final file in result) {
          if (_selectedFiles.length >= settings.maxFilesAllowed) break;
          final path = file.path;
          if (path == null) continue;
          if ((await file.length() ?? 0) >
              settings.maxFileSizeOther * 1024 * 1024) {
            oversized++;
            continue;
          }
          if (!_selectedFiles.any((f) => f.path == path)) {
            _selectedFiles.add(
              _SelectedFile(path: path, name: file.name, type: 'document'),
            );
          }
        }
        if (oversized > 0 && mounted) {
          UiUtils.showMessage(
            context,
            '${'fileSizeExceededLimit'.translate(context: context)} (${settings.maxFileSizeOther} ${'mb'.translate(context: context)})',
            ToastificationType.warning,
          );
        }
      }
    } on PlatformException catch (_) {
      if (mounted) {
        UiUtils.showMessage(
          context,
          'permissionNotGiven'.translate(context: context),
          ToastificationType.error,
        );
      }
    }
    setState(() {});
  }

  Future<void> _submitForm(BuildContext context) async {
    try {
      UiUtils.removeFocus();

      if (_formKey.currentState!.validate()) {
        final bool checkMinMax =
            double.parse(minBudgetController.text) <
                double.parse(maxBudgetController.text) &&
            (maxBudgetController.text.isNotEmpty &&
                maxBudgetController.text.isNotEmpty);

        final DateTime parsedStartTime = DateTime.parse(rawStartTime);
        final DateTime parsedEndTime = DateTime.parse(rawEndTime);

        if (parsedStartTime.isBefore(DateTime.now())) {
          UiUtils.showMessage(
            context,
            'startTimeMustBeFuture'.translate(context: context),
            ToastificationType.warning,
          );
          return;
        }

        final bool checkTime =
            parsedStartTime.isBefore(parsedEndTime) ||
            parsedStartTime.isAtSameMomentAs(parsedEndTime);
        if (!checkTime) {
          UiUtils.showMessage(
            context,
            'invalidTime'.translate(context: context),
            ToastificationType.warning,
          );
          return;
        }
        if (!checkMinMax) {
          UiUtils.showMessage(
            context,
            'minMaxBudgetWarning'.translate(context: context),
            ToastificationType.warning,
          );
          return;
        }
        final Map<String, dynamic> parameters = <String, dynamic>{
          'category_id': categoryId,
          'service_title': serviceTitleController.text,
          'service_short_description': serviceDescriptionController.text,
          'min_price': minBudgetController.text,
          'max_price': maxBudgetController.text,
          'requested_start_date': selectedStartDate,
          'requested_end_date': selectedEndDate,
          'requested_start_time': selectedStartTime,
          'requested_end_time': selectedEndTime,
          'latitude': HiveRepository.getLatitude,
          'longitude': HiveRepository.getLongitude,
        };
        await context.read<MyRequestCubit>().submitCustomJobRequest(
          parameters: parameters,
          filePaths: _selectedFiles.map((f) => f.path).toList(),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      UiUtils.showMessage(context, e.toString(), ToastificationType.error);
    }
  }
}
