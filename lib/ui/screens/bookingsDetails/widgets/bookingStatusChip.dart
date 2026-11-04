import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

/// Figma has no semantic token for these three statuses — bg/text hex are
/// taken verbatim from the design (node 6365:30511), not guessed.
const Color _onTheWayBackground = Color(0xFFFEE7E1);
const Color _onTheWayText = Color(0xFFED3608);
const Color _arrivedBackground = Color(0xFFE7EAF8);
const Color _arrivedText = Color(0xFF374FBE);
const Color _rescheduledBackground = Color(0xFFEEE0FF);
const Color _rescheduledText = Color(0xFF9747FF);

class BookingStatusChip extends StatelessWidget {
  const BookingStatusChip({super.key, required this.status});

  final String status;

  static ({Color background, Color text}) colorsFor(
    final BuildContext context,
    final String status,
  ) {
    switch (status) {
      case 'started':
        return (
          background: context.colors.backgroundInfoSubtle,
          text: context.colors.textInfo,
        );
      case 'on_the_way':
        return (background: _onTheWayBackground, text: _onTheWayText);
      case 'arrived':
        return (background: _arrivedBackground, text: _arrivedText);
      case 'booking_ended':
        return (
          background: context.colors.backgroundSecondary,
          text: context.colors.textSecondary,
        );
      case 'cancelled':
        return (
          background: context.colors.backgroundErrorSubtle,
          text: context.colors.textError,
        );
      case 'completed':
        return (
          background: context.colors.backgroundSuccessSubtle,
          text: context.colors.textSuccess,
        );
      case 'confirmed':
        return (
          background: context.colors.backgroundBrandSubtle,
          text: context.colors.textBrand,
        );
      case 'rescheduled':
        return (background: _rescheduledBackground, text: _rescheduledText);
      case 'awaiting':
      default:
        return (
          background: context.colors.backgroundWarningSubtle,
          text: context.colors.textWarning,
        );
    }
  }

  /// Translated display label for a raw booking/service status string —
  /// shared with anything else that needs to show a status as text (e.g.
  /// the status-timeline row) without duplicating this mapping.
  static String labelFor(final BuildContext context, final String status) {
    switch (status) {
      case 'on_the_way':
        return 'onTheWay'.translate(context: context);
      case 'booking_ended':
        return 'booking_ended'.translate(context: context);
      default:
        return status.translate(context: context);
    }
  }

  @override
  Widget build(final BuildContext context) {
    final colors = colorsFor(context, status);
    return CustomContainer(
      padding: const EdgeInsets.all(8),
      color: colors.background,
      borderRadius: 8,
      child: CustomText(
        labelFor(context, status),
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colors.text,
      ),
    );
  }
}
