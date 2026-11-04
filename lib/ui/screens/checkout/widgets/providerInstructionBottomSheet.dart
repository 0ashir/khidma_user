import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class ProviderInstructionBottomSheet extends StatefulWidget {
  const ProviderInstructionBottomSheet({super.key, this.initialInstruction});

  final String? initialInstruction;

  bool get isEdit => (initialInstruction ?? '').trim().isNotEmpty;

  @override
  State<ProviderInstructionBottomSheet> createState() =>
      _ProviderInstructionBottomSheetState();
}

class _ProviderInstructionBottomSheetState
    extends State<ProviderInstructionBottomSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialInstruction,
  );

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
              (widget.isEdit
                      ? 'editInstructionForProvider'
                      : 'writeInstructionForProvider')
                  .translate(context: context),
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

  Widget _buildInputField() => TextFormField(
    controller: _controller,
    autofocus: false,
    minLines: 5,
    maxLines: 8,
    style: TextStyle(fontSize: 14, color: context.colors.textPrimary),
    decoration: InputDecoration(
      filled: true,
      fillColor: context.colors.backgroundSecondary,
      hintText: 'writeInstruction'.translate(context: context),
      hintStyle: TextStyle(fontSize: 14, color: context.colors.textTertiary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: context.colors.borderDefault),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: context.colors.borderDefault),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: context.colors.borderBrand),
      ),
    ),
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
      child: CustomRoundedButton(
        buttonTitle: (widget.isEdit ? 'updateInstruction' : 'addInstruction')
            .translate(context: context),
        showBorder: false,
        widthPercentage: 1,
        backgroundColor: context.colors.backgroundBrand,
        radius: UiUtils.borderRadiusOf12,
        textSize: 16,
        fontWeight: FontWeight.w500,
        onTap: () {
          final String instruction = _controller.text.trim();
          Navigator.pop(context, instruction);
        },
      ),
    ),
  );

  @override
  Widget build(final BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: CustomContainer(
      color: context.colors.surfacePrimary,
      borderRadiusStyle: const BorderRadius.vertical(top: Radius.circular(16)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildHeader(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: _buildInputField(),
            ),
            _buildFooter(),
          ],
        ),
      ),
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
