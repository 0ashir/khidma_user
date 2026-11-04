import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class ServiceSectionTitle extends StatelessWidget {
  const ServiceSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: CustomText(
      title,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: context.colors.textPrimary,
    ),
  );
}
