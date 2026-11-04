import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class MyRequestSectionCard extends StatelessWidget {
  const MyRequestSectionCard({
    required this.title,
    required this.child,
    super.key,
  });

  final String title;
  final Widget child;

  static Widget divider(final BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const CustomSizedBox(height: 12),
      Divider(height: 1, color: context.colors.borderDefault),
      const CustomSizedBox(height: 12),
    ],
  );

  @override
  Widget build(final BuildContext context) => CustomContainer(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    color: context.colors.surfacePrimary,
    borderRadius: 8,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          title,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: context.colors.textPrimary,
        ),
        divider(context),
        child,
      ],
    ),
  );
}
