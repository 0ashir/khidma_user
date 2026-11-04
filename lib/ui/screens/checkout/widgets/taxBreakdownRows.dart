import 'package:flutter/material.dart';

import '../../../../app/generalImports.dart';

class TaxBreakdownRows extends StatelessWidget {
  const TaxBreakdownRows({
    required this.cart,
    required this.atStore,
    super.key,
  });

  final Cart cart;
  final bool atStore;

  @override
  Widget build(final BuildContext context) {
    final TaxBreakdown breakdown = cart.taxBreakdown!;

    String money(final double amount) =>
        amount.toStringAsFixed(2).countryPriceFormat(context);
    String percent(final double p) =>
        p == p.roundToDouble() ? p.toInt().toString() : p.toString();

    Widget plainRow(final String title, final String amount) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ChargesTile(
        title: title,
        value: amount,
        fontSize: 14,
        fontweight: FontWeight.w400,
        titleColor: context.colors.textPrimary,
      ),
    );

    // A charge row; when it has taxes its arrow opens base price + each tax.
    Widget chargeRow({
      required final String key,
      required final String title,
      required final String amount,
      required final double baseAmount,
      required final List<TaxComponent> components,
    }) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ExpandableChargeRow(
        key: ValueKey(key),
        title: title,
        amount: amount,
        details: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: ChargesTile(
              title: 'basePrice'.translate(context: context),
              value: money(baseAmount),
              fontSize: 12,
              fontweight: FontWeight.w400,
              titleColor: context.colors.textTertiary,
              valueColor: context.colors.textSecondary,
            ),
          ),
          for (final TaxComponent c in components)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: ChargesTile(
                title:
                    '${c.name.isEmpty ? 'tax'.translate(context: context) : c.name}'
                    '${c.percentage > 0 ? ' (${percent(c.percentage)}%)' : ''}',
                value: '+ ${money(c.amount)}',
                fontSize: 12,
                fontweight: FontWeight.w400,
                titleColor: context.colors.textTertiary,
                valueColor: context.colors.textSecondary,
              ),
            ),
        ],
      ),
    );

    String titleOf(final String key, final TaxGroup g) {
      if (g.title.isNotEmpty) return g.title;
      if (key == 'visiting_charges') {
        return 'visitingCharge'.translate(context: context);
      }
      if (key == 'services') return 'services'.translate(context: context);
      return cart.fees
              ?.where((final f) => 'fee_${f.id}' == key)
              .firstOrNull
              ?.title ??
          '';
    }

    Widget rowFor(final String key, final TaxGroup g) {
      final String amount =
          '${key == 'services' ? '' : '+ '}${money(g.totalWithTax)}';
      final List<TaxComponent> taxes = g.components
          .where((final c) => c.amount > 0)
          .toList();
      final String title = titleOf(key, g);
      return taxes.isEmpty
          ? plainRow(title, amount)
          : chargeRow(
              key: key,
              title: title,
              amount: amount,
              baseAmount: g.baseAmount,
              components: taxes,
            );
    }

    final List<Widget> rows = [];
    final Set<String> shown = {};
    void addGroup(final String key) {
      final TaxGroup? g = breakdown.groups[key];
      if (g == null || !shown.add(key)) return;
      rows.add(rowFor(key, g));
    }

    addGroup('services');
    if (!atStore) {
      if (breakdown.groups.containsKey('visiting_charges')) {
        addGroup('visiting_charges');
      } else if ((double.tryParse(cart.visitingCharges ?? '') ?? 0) > 0) {
        rows.add(
          plainRow(
            'visitingCharge'.translate(context: context),
            '+ ${(cart.visitingCharges ?? '0').countryPriceFormat(context)}',
          ),
        );
      }
    }
    for (final Fees fee in cart.fees ?? const <Fees>[]) {
      if (breakdown.groups.containsKey('fee_${fee.id}')) {
        addGroup('fee_${fee.id}');
      } else {
        rows.add(
          plainRow(
            fee.title ?? '',
            '+ ${(fee.amount ?? '0').countryPriceFormat(context)}',
          ),
        );
      }
    }
    for (final String key in breakdown.groups.keys) {
      if (atStore && key == 'visiting_charges') continue;
      addGroup(key);
    }
    return Column(children: rows);
  }
}
