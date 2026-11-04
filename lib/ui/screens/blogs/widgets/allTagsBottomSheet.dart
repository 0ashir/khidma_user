import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/data/model/blogs/blogModel.dart';
import 'package:flutter/material.dart';

class AllTagsBottomSheet extends StatefulWidget {
  const AllTagsBottomSheet({
    required this.tags,
    required this.selectedTagSlug,
    required this.onTagSelected,
    super.key,
  });

  final List<BlogTag> tags;
  final String? selectedTagSlug;
  final ValueChanged<String> onTagSelected;

  @override
  State<AllTagsBottomSheet> createState() => _AllTagsBottomSheetState();
}

class _AllTagsBottomSheetState extends State<AllTagsBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  late List<BlogTag> _filteredTags;

  @override
  void initState() {
    super.initState();
    _filteredTags = widget.tags;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredTags = query.isEmpty
          ? widget.tags
          : widget.tags
                .where(
                  (tag) => tag.translatedName.toLowerCase().contains(query),
                )
                .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: context.colors.backgroundPrimary,
      margin: EdgeInsetsDirectional.only(
        bottom: MediaQuery.viewPaddingOf(context).bottom,
      ),
      borderRadiusStyle: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
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
                      'tags'.translate(context: context),
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextFormField(
                      controller: _searchController,
                      hintText: 'searchTags'.translate(context: context),
                      fillColor: context.colors.backgroundSecondary,
                      bottomPadding: 0,
                      prefix: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 12),
                        child: CustomSvgPicture(
                          svgImage: AppAssets.search,
                          color: context.colors.iconPrimary,
                          boxFit: BoxFit.scaleDown,
                        ),
                      ),
                    ),
                    const CustomSizedBox(height: 16),
                    if (_filteredTags.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: CustomText(
                            'noDataFound'.translate(context: context),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: context.colors.textSecondary,
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _filteredTags.map((tag) {
                          final bool isSelected =
                              widget.selectedTagSlug == tag.slug;
                          return FlatOutlinedButton(
                            name: tag.translatedName,
                            isSelected: isSelected,
                            onTap: () {
                              widget.onTagSelected(tag.slug);
                              Navigator.pop(context);
                            },
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
