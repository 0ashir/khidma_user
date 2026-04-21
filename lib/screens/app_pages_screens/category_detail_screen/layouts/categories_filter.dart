import 'dart:developer';

import 'package:flutter/cupertino.dart';
import '../../../../config.dart';

class CategoriesFilterLayout extends StatelessWidget {
  const CategoriesFilterLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final value = Provider.of<CategoriesDetailsProvider>(context, listen: true);
    return Consumer2<LanguageProvider, CategoriesDetailsProvider>(
      builder: (context, lang, value, child) {
        return SizedBox(
          height: MediaQuery.of(context).size.height / 1.2,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row with Title & Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${language(context, translations!.filterBy)} (${value.totalCountFilter()})",
                        style: appCss.dmDenseMedium18
                            .textColor(appColor(context).darkText),
                      ),
                      const Icon(CupertinoIcons.multiply).inkWell(
                        onTap: () => route.pop(context),
                      )
                    ],
                  ).paddingSymmetric(horizontal: Insets.i20),

                  // Filter Tabs
                  Container(
                    alignment: Alignment.center,
                    height: Sizes.s50,
                    decoration: BoxDecoration(
                      color: appColor(context).fieldCardBg,
                      borderRadius: const BorderRadius.all(
                          Radius.circular(AppRadius.r30)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: appArray.filterList1
                          .asMap()
                          .entries
                          .map(
                            (e) => FilterTapLayout(
                              data: e.value,
                              index: e.key,
                              selectedIndex: value.selectIndex,
                              onTap: () => value.onFilter(e.key),
                            ),
                          )
                          .toList(),
                    ).paddingAll(Insets.i5),
                  ).paddingOnly(
                    top: Insets.i25,
                    bottom: Insets.i10,
                    left: Insets.i20,
                    right: Insets.i20,
                  ),

                  // Dynamic Content Section
                  Consumer2<LanguageProvider, CategoriesDetailsProvider>(
                      builder: (context, lang, value, child) {
                    log("value.providerList:::${value.providerList}");
                    return StatefulWrapper(
                        onInit: () {
                          Future.delayed(const Duration(milliseconds: 150))
                              .then((valuee) {
                            value.getProvider();
                          });
                        },
                        child: Expanded(
                            child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                              value.selectIndex == 0
                                  ? Column(children: [
                                      // Dropdown + Count
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "${language(context, translations!.providerList)}(${value.providerList.length})",
                                              style: appCss.dmDenseMedium14
                                                  .textColor(appColor(context)
                                                      .lightText),
                                            ).alignment(Alignment.centerLeft),
                                          ),
                                          DropDownLayout(
                                            isIcon: false,
                                            val: value.exValue,
                                            categoryList:
                                                appArray.experienceList,
                                            onChanged: (val) =>
                                                value.onExperience(val),
                                          ).width(Sizes.s180),
                                        ],
                                      ).paddingSymmetric(
                                        vertical: Insets.i20,
                                        horizontal: Insets.i20,
                                      ),

                                      // Search Field
                                      SearchTextFieldCommon(
                                              controller: value.filterSearchCtrl,
                                              focusNode: value.filterSearchFocus,
                                              onChanged: (v) {
                                                if (v.isEmpty) {
                                                  value.fetchProviderByFilter();
                                                } else if (v.length > 3) {
                                                  value.fetchProviderByFilter();
                                                }
                                              },
                                              onFieldSubmitted: (v) =>
                                                  value.fetchProviderByFilter())
                                          .paddingSymmetric(
                                              horizontal: Insets.i20),

                                      const VSpace(Sizes.s10),

                                      Expanded(
                                          child: ListView.builder(
                                              itemCount:
                                                  value.providerList.length,
                                              itemBuilder: (context, index) {
                                                final item =
                                                    value.providerList[index];
                                                return ExperienceLayout(
                                                    data: item,
                                                    isContain: value
                                                        .selectedProvider
                                                        .contains(item.id),
                                                    onTap: () =>
                                                        value.onCategoryChange(
                                                            item.id)).inkWell(
                                                    onTap: () =>
                                                        value.onCategoryChange(
                                                            item.id));
                                              }))
                                    ])
                                  : value.selectIndex == 1
                                      ? SecondFilter(
                                          min: 0.0,
                                          max: value.maxPrice,
                                          lowerVal: value.lowerVal,
                                          upperVal: value.upperVal,
                                          selectIndex: value.ratingIndex,
                                          onDragging: (handlerIndex, lowerValue,
                                                  upperValue) =>
                                              value.onSliderChange(handlerIndex,
                                                  lowerValue, upperValue),
                                          isSearch: false)
                                      : const ThirdFilter(),
                            ])));
                  }),

                  const VSpace(Sizes.s80)
                ],
              ).paddingSymmetric(vertical: Insets.i20),

              // Bottom Buttons
              BottomSheetButtonCommon(
                textOne: translations!.clearAll,
                textTwo: translations!.apply,
                applyTap: () {
                  route.pop(context);
                  value.getServiceByCategoryId(context, id:value.subCategoryId);
                },
                clearTap: () => value.clearFilter(context, value.subCategoryId),
              )
                  .backgroundColor(appColor(context).whiteBg)
                  .alignment(Alignment.bottomCenter),
            ],
          ),
        ).bottomSheetExtension(context);
      },
    );
  }
}
