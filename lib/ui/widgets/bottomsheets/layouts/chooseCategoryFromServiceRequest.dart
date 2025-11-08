import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class BottomSheetCategoryScreen extends StatefulWidget {
  const BottomSheetCategoryScreen({
    required this.categoryId,
    required this.scrollController,
    final Key? key,
  }) : super(key: key);
  final ScrollController scrollController;
  final String categoryId;

  @override
  State<BottomSheetCategoryScreen> createState() =>
      _BottomSheetCategoryScreenState();
}

class _BottomSheetCategoryScreenState extends State<BottomSheetCategoryScreen> {
  bool isSelected = false;
  String? categoryID;
  String? categoryName;
  @override
  void initState() {
    categoryID = widget.categoryId;
    Future.delayed(Duration.zero).then((final value) {
      fetchCategory();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetchCategory() {
    context.read<AllCategoryCubit>().getAllCategory();
  }

  @override
  Widget build(final BuildContext context) =>
      BlocBuilder<AllCategoryCubit, AllCategoryState>(
        builder: (final BuildContext context,
            final AllCategoryState allcategoryState) {
          if (allcategoryState is AllCategoryFetchFailure) {
            return ErrorContainer(
              errorMessage:
                  allcategoryState.errorMessage.translate(context: context),
              onTapRetry: fetchCategory,
              showRetryButton: true,
            );
          } else if (allcategoryState is AllCategoryFetchSuccess) {
            return allcategoryState.allCategoryList.isEmpty
                ? NoDataFoundWidget(
                    titleKey: 'noServicesFound'.translate(context: context),
                    subtitleKey:
                        'noServicesFoundSubTitle'.translate(context: context),
                    showRetryButton: true,
                    onTapRetry: () {
                      fetchCategory();
                    },
                  )
                : _getCategoryList(
                    allCategoryList: allcategoryState.allCategoryList);
          }
          return _getCategoryShimmerEffect();
        },
      );

  Widget _getCategoryShimmerEffect() => SafeArea(
        child: BottomSheetLayout(
          title: 'services'.translate(context: context),
          child: SizedBox(
            height: context.screenHeight * 0.8,
            child: GridView.builder(
              padding:
                  const EdgeInsetsDirectional.only(start: 15, end: 15, top: 15),
              itemCount: UiUtils.numberOfShimmerContainer * 2,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 20,
              ),
              itemBuilder: (final context, final index) => const SizedBox(
                height: 50,
                width: 75,
                child: CustomShimmerLoadingContainer(
                  height: 50,
                  width: 75,
                  borderRadius: UiUtils.borderRadiusOf10,
                ),
              ),
            ),
          ),
        ),
      );

  Widget _getCategoryList(
          {required final List<AllCategoryModel> allCategoryList}) =>
      PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) {
            return;
          } else {
            Navigator.of(context).pop();
          }
        },
        child: SafeArea(
          child: StatefulBuilder(builder:
              (final BuildContext context, final StateSetter setState) {
            return BottomSheetLayout(
              title: 'services'.translate(context: context),
              child: SizedBox(
                height: context.screenHeight * 0.8,
                child: Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        controller: widget.scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                            15.rw(context),
                            15.rw(context),
                            15.rw(context),
                            kBottomNavigationBarHeight.rh(context)),
                        itemCount: allCategoryList.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemBuilder: (final BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                categoryID = allCategoryList[index].id;
                                categoryName = allCategoryList[index].translated_name;
                                isSelected = true;
                              });
                            },
                            child: CustomContainer(
                              border: isSelected &&
                                      categoryID == allCategoryList[index].id
                                  ? Border.all(
                                      width: 0.5,
                                      color: context.colorScheme.accentColor)
                                  : Border.all(
                                      width: 0.5,
                                      color: context.colorScheme.lightGreyColor,
                                    ),
                              borderRadius: UiUtils.borderRadiusOf6,
                              color: context.colorScheme.secondaryColor,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomImageContainer(
                                      borderRadius: UiUtils.borderRadiusOf5,
                                      imageURL: allCategoryList[index].image!,
                                      height: 52,
                                      width: 52,
                                      boxFit: BoxFit.fill,
                                      boxShadow: []),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: CustomText(
                                      allCategoryList[index].translated_name!,
                                      fontSize: 12,
                                      color: context.colorScheme.blackColor,
                                      fontWeight: FontWeight.w600,
                                      maxLines: 2,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    CloseAndConfirmButton(closeButtonPressed: () {
                      Navigator.of(context).pop();
                    }, confirmButtonPressed: () {
                      Navigator.of(context).pop({
                        'id': categoryID,
                        'name': categoryName,
                      });
                    }),
                  ],
                ),
              ),
            );
          }),
        ),
      );
}
