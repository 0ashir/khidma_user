import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class PriceBreakdownCard extends StatefulWidget {
  const PriceBreakdownCard({super.key, required this.bookingDetails});

  final BookingDetailModel bookingDetails;

  @override
  State<PriceBreakdownCard> createState() => _PriceBreakdownCardState();
}

class _PriceBreakdownCardState extends State<PriceBreakdownCard> {
  bool _expanded = false;

  bool _isPositive(final String? value) {
    if (value == null || value.isEmpty) return false;
    return (double.tryParse(value.replaceAll(',', '')) ?? 0) > 0;
  }

  String _paymentIcon(final String method) {
    switch (method.toLowerCase()) {
      case 'stripe':
        return AppAssets.stripe;
      case 'razorpay':
        return AppAssets.razorpay;
      case 'paystack':
        return AppAssets.paystack;
      case 'paypal':
        return AppAssets.paypal;
      case 'flutterwave':
        return AppAssets.flutterwave;
      case 'cashfree':
        return AppAssets.cashfree;
      case 'cod':
      default:
        return AppAssets.cod;
    }
  }

  ({Color background, Color text}) _statusColors(
    final BuildContext context,
    final String status,
  ) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case '1':
        return (
          background: context.colors.backgroundSuccessSubtle,
          text: context.colors.textSuccess,
        );
      case 'failed':
      case '2':
        return (
          background: context.colors.backgroundErrorSubtle,
          text: context.colors.textError,
        );
      default:
        return (
          background: context.colors.backgroundWarningSubtle,
          text: context.colors.textWarning,
        );
    }
  }

  double _sumAmounts(final Iterable<String?> values) => values.fold(
    0.0,
    (final total, final value) =>
        total + (double.tryParse((value ?? '0').replaceAll(',', '')) ?? 0.0),
  );

  Widget _buildLineItem(
    final BuildContext context, {
    required final String label,
    required final String amount,
    final bool emphasize = false,
    final Color? labelColor,
    final Color? amountColor,
    final FontWeight? amountFontWeight,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: CustomText(
            label,
            fontSize: emphasize ? 14 : 12,
            fontWeight: emphasize ? FontWeight.w500 : FontWeight.w400,
            color:
                labelColor ??
                (emphasize
                    ? context.colors.textPrimary
                    : context.colors.textSecondary),
          ),
        ),
        CustomText(
          amount,
          fontSize: emphasize ? 14 : 12,
          fontWeight:
              amountFontWeight ??
              (emphasize ? FontWeight.w500 : FontWeight.w400),
          color: amountColor ?? context.colors.textPrimary,
        ),
      ],
    ),
  );

  String _money(final double amount) => amount
      .toString()
      .priceFormat(
        context,
        currencySymbol: widget.bookingDetails.currencySymbol,
        decimalPlaces: widget.bookingDetails.currencyDecimalPlaces,
      );

  // A charge row; when it carries tax its arrow opens base price + each tax.
  Widget _buildTaxGroupRow(
    final BuildContext context, {
    required final String key,
    required final String title,
    required final TaxGroup group,
    required final String prefix,
  }) {
    final taxes = group.components.where((final c) => c.amount > 0).toList();
    final amount = '$prefix${_money(group.totalWithTax)}';
    if (taxes.isEmpty) {
      return _buildLineItem(
        context,
        label: title,
        amount: amount,
        labelColor: context.colors.textPrimary,
      );
    }

    String percent(final double p) =>
        p == p.roundToDouble() ? p.toInt().toString() : p.toString();

    return ExpandableChargeRow(
      key: ValueKey(key),
      title: title,
      amount: amount,
      fontSize: 12,
      padding: const EdgeInsets.symmetric(vertical: 4),
      detailsGap: 4,
      details: [
        _buildLineItem(
          context,
          label: 'basePrice'.translate(context: context),
          amount: _money(group.baseAmount),
          labelColor: context.colors.textTertiary,
          amountColor: context.colors.textSecondary,
        ),
        for (final c in taxes)
          _buildLineItem(
            context,
            label:
                '${c.name.isEmpty ? 'tax'.translate(context: context) : c.name}'
                '${c.percentage > 0 ? ' (${percent(c.percentage)}%)' : ''}',
            amount: '+ ${_money(c.amount)}',
            labelColor: context.colors.textTertiary,
            amountColor: context.colors.textSecondary,
          ),
      ],
    );
  }

  // Services, visiting charge, fees (each with its own tax) and the promo, so
  // the visible rows add up to `final_total`.
  List<Widget> _buildTaxBreakdownRows(
    final BuildContext context,
    final BookingDetailModel booking,
  ) {
    final groups = booking.tax!.breakdown!.groups;
    final atStore = booking.bookingType == 'at_store';
    final rows = <Widget>[];
    final shown = <String>{};

    String titleOf(final String key, final TaxGroup group) {
      if (group.title.isNotEmpty) return group.title;
      if (key == 'visiting_charges') {
        return 'visitingCharge'.translate(context: context);
      }
      if (key == 'services') return 'services'.translate(context: context);
      return booking.fees
              ?.where((final f) => 'fee_${f.id}' == key)
              .firstOrNull
              ?.title ??
          '';
    }

    void addGroup(final String key) {
      final group = groups[key];
      if (group == null || !shown.add(key)) return;
      rows.add(
        _buildTaxGroupRow(
          context,
          key: key,
          title: titleOf(key, group),
          group: group,
          prefix: key == 'services' ? '' : '+ ',
        ),
      );
    }

    addGroup('services');
    if (!atStore) {
      if (groups.containsKey('visiting_charges')) {
        addGroup('visiting_charges');
      } else if (_isPositive(booking.visitingCharges)) {
        rows.add(
          _buildLineItem(
            context,
            label: 'visitingCharge'.translate(context: context),
            amount:
                '+ ${(booking.visitingCharges ?? '0').priceFormat(context, currencySymbol: booking.currencySymbol, decimalPlaces: booking.currencyDecimalPlaces)}',
          ),
        );
      }
    }
    for (final fee in booking.fees ?? const <BookingFee>[]) {
      if (groups.containsKey('fee_${fee.id}')) {
        addGroup('fee_${fee.id}');
      } else {
        rows.add(
          _buildLineItem(
            context,
            label: fee.title ?? '',
            amount:
                '+ ${(fee.calculatedAmount ?? '0').priceFormat(context, currencySymbol: booking.currencySymbol, decimalPlaces: booking.currencyDecimalPlaces)}',
          ),
        );
      }
    }
    for (final key in groups.keys) {
      if (atStore && key == 'visiting_charges') continue;
      addGroup(key);
    }

    final promoDiscount = double.tryParse(booking.promoDiscount ?? '') ?? 0;
    if ((booking.promoCode ?? '').isNotEmpty && promoDiscount > 0) {
      final promoTax = double.tryParse(booking.promoTaxReduction ?? '') ?? 0;
      final promoLabel =
          '${'promoCode'.translate(context: context)} (${booking.promoCode})';
      // The discount comes off the price before tax, so the tax drops too: one
      // row for the total saving, its arrow explains the split.
      rows.add(
        promoTax > 0
            ? ExpandableChargeRow(
                key: const ValueKey('promo'),
                title: promoLabel,
                amount: '- ${_money(promoDiscount + promoTax)}',
                fontSize: 12,
                padding: const EdgeInsets.symmetric(vertical: 4),
                detailsGap: 4,
                details: [
                  _buildLineItem(
                    context,
                    label: 'discount'.translate(context: context),
                    amount: '- ${_money(promoDiscount)}',
                    labelColor: context.colors.textTertiary,
                    amountColor: context.colors.textSecondary,
                  ),
                  _buildLineItem(
                    context,
                    label: 'promoTaxReduction'.translate(context: context),
                    amount: '- ${_money(promoTax)}',
                    labelColor: context.colors.textTertiary,
                    amountColor: context.colors.textSecondary,
                  ),
                ],
              )
            : _buildLineItem(
                context,
                label: promoLabel,
                amount: '- ${_money(promoDiscount)}',
              ),
      );
    }
    return rows;
  }

  @override
  Widget build(final BuildContext context) {
    final booking = widget.bookingDetails;
    final paymentStatus = booking.paymentStatus ?? '';
    final statusColors = _statusColors(context, paymentStatus);

    return CustomContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: context.colors.surfacePrimary,
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomInkWellContainer(
            showRippleEffect: false,
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _expanded
                      ? CustomText(
                          'billDetails'.translate(context: context),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: context.colors.textPrimary,
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomText(
                              '${'totalAmount'.translate(context: context)} : ${(booking.finalTotal ?? '0').priceFormat(context, currencySymbol: booking.currencySymbol, decimalPlaces: booking.currencyDecimalPlaces)}',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: context.colors.textPrimary,
                            ),
                            const CustomSizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: CustomText(
                                    '${'paymentMode'.translate(context: context)} : ${booking.paymentMethod ?? ''}',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: context.colors.textSecondary,
                                    maxLines: 1,
                                  ),
                                ),
                                const CustomSizedBox(width: 8),
                                CustomContainer(
                                  padding: const EdgeInsets.all(4),
                                  color: statusColors.background,
                                  borderRadius: 4,
                                  child: CustomText(
                                    paymentStatus.isEmpty
                                        ? 'pending'.translate(context: context)
                                        : paymentStatus.translate(
                                            context: context,
                                          ),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: statusColors.text,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
                CustomContainer(
                  padding: const EdgeInsets.all(8),
                  color: context.colors.backgroundSecondary,
                  borderRadius: 24,
                  child: Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: context.colors.iconPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (_expanded) ...[
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
            if ((booking.additionalCharges ?? []).isNotEmpty) ...[
              ...booking.additionalCharges!.map(
                (charge) => _buildLineItem(
                  context,
                  label: charge.name ?? '',
                  amount:
                      "+ ${(charge.charge ?? '0').priceFormat(context, currencySymbol: booking.currencySymbol, decimalPlaces: booking.currencyDecimalPlaces)}",
                ),
              ),
              // for (final charge in booking.additionalCharges ?? [])
              //   _buildLineItem(
              //     context,
              //     label: charge.name ?? '',
              //     amount: '+ ${(charge.charge ?? '0').priceFormat(context, currencySymbol: booking.currencySymbol, decimalPlaces: booking.currencyDecimalPlaces)}',
              //   ),
              _buildLineItem(
                context,
                label: 'totalAdditionalCharges'.translate(context: context),
                amount:
                    _sumAmounts(
                      booking.additionalCharges!.map((final c) => c.charge),
                    ).toString().priceFormat(
                      context,
                      currencySymbol: booking.currencySymbol,
                      decimalPlaces: booking.currencyDecimalPlaces,
                    ),
                emphasize: true,
              ),
              const CustomSizedBox(height: 8),
              CustomSizedBox(
                height: 1,
                width: double.infinity,
                child: DashedRect(
                  color: context.colors.borderDefault,
                  strokeWidth: 1,
                  gap: 4,
                ),
              ),
              const CustomSizedBox(height: 8),
            ],
            if (booking.tax?.breakdown?.groups.isNotEmpty ?? false)
              ..._buildTaxBreakdownRows(context, booking)
            else ...[
              _buildLineItem(
                context,
                label: 'subTotal'.translate(context: context),
                amount: (booking.baseTotal ?? '0').priceFormat(
                  context,
                  currencySymbol: booking.currencySymbol,
                  decimalPlaces: booking.currencyDecimalPlaces,
                ),
              ),
              if (_isPositive(booking.tax?.taxAmount))
                _buildLineItem(
                  context,
                  label: 'tax'.translate(context: context),
                  // Tax already folded into base_total when included — showing
                  // it with a "+" would make the visible lines double-count it.
                  amount: booking.tax!.isIncluded
                      ? (booking.tax?.taxAmount ?? '0').priceFormat(
                          context,
                          currencySymbol: booking.currencySymbol,
                          decimalPlaces: booking.currencyDecimalPlaces,
                        )
                      : '+ ${(booking.tax?.taxAmount ?? '0').priceFormat(context, currencySymbol: booking.currencySymbol, decimalPlaces: booking.currencyDecimalPlaces)}',
                ),
              if (booking.bookingType != 'at_store' &&
                  _isPositive(booking.visitingCharges))
                _buildLineItem(
                  context,
                  label: 'visitingCharge'.translate(context: context),
                  amount:
                      '+ ${(booking.visitingCharges ?? '0').priceFormat(context, currencySymbol: booking.currencySymbol, decimalPlaces: booking.currencyDecimalPlaces)}',
                ),
              if ((booking.promoCode ?? '').isNotEmpty &&
                  _isPositive(booking.promoDiscount))
                _buildLineItem(
                  context,
                  label:
                      '${'promoCode'.translate(context: context)} (${booking.promoCode})',
                  amount:
                      '- ${(booking.promoDiscount ?? '0').priceFormat(context, currencySymbol: booking.currencySymbol, decimalPlaces: booking.currencyDecimalPlaces)}',
                ),
              if (booking.fees != null && booking.fees!.isNotEmpty)
                ...booking.fees!.map(
                  (fee) => _buildLineItem(
                    context,
                    label: fee.title ?? '',
                    amount:
                        "+ ${(fee.calculatedAmount ?? '0').priceFormat(context, currencySymbol: booking.currencySymbol, decimalPlaces: booking.currencyDecimalPlaces)}",
                  ),
                ),
            ],
            const CustomSizedBox(height: 8),
            CustomSizedBox(
              height: 1,
              width: double.infinity,
              child: DashedRect(
                color: context.colors.borderDefault,
                strokeWidth: 1,
                gap: 4,
              ),
            ),
            const CustomSizedBox(height: 8),
            _buildLineItem(
              context,
              label: 'totalPaid'.translate(context: context),
              amount: (booking.finalTotal ?? '0').priceFormat(
                context,
                currencySymbol: booking.currencySymbol,
                decimalPlaces: booking.currencyDecimalPlaces,
              ),
              emphasize: true,
              amountColor: context.colors.textBrand,
              amountFontWeight: FontWeight.w600,
            ),
            const CustomSizedBox(height: 12),
            CustomContainer(
              padding: const EdgeInsets.all(8),
              color: context.colors.backgroundSecondary,
              borderRadius: 8,
              child: Row(
                children: [
                  CustomSvgPicture(
                    svgImage: _paymentIcon(booking.paymentMethod ?? ''),
                    height: 36,
                    width: 36,
                    avoideResponsive: true,
                  ),
                  const CustomSizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomText(
                          'paymentWith'.translate(context: context),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: context.colors.textTertiary,
                        ),
                        const CustomSizedBox(height: 4),
                        CustomText(
                          booking.paymentMethod ?? '',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: context.colors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                  CustomContainer(
                    padding: const EdgeInsets.all(8),
                    color: statusColors.background,
                    borderRadius: 8,
                    child: CustomText(
                      paymentStatus.isEmpty
                          ? 'pending'.translate(context: context)
                          : paymentStatus.translate(context: context),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: statusColors.text,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
