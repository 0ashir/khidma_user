import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class NotesWidget extends StatelessWidget {
  final String notes;
  final String title;

  const NotesWidget({super.key, required this.notes, this.title = "notesLbl"});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: context.colors.backgroundPrimary,
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            title.translate(context: context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.colors.textPrimary,
          ),
          const CustomSizedBox(height: 12),
          CustomContainer(height: 1, color: context.colors.borderDefault),
          const CustomSizedBox(height: 12),
          CustomText(
            notes,
            color: context.colors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
    );
  }
}
