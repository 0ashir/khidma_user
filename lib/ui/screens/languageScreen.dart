import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/utils/shimmerEffect/languageListShimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({final Key? key}) : super(key: key);

  static Route route(final RouteSettings routeSettings) =>
      CupertinoPageRoute(builder: (final _) => const LanguageScreen());

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  bool _isProcessingLanguageData = false;

  @override
  void initState() {
    super.initState();
    getLanguageList();
  }

  void getLanguageList() {
    context.read<LanguageListCubit>().getLanguageList();
  }

  Widget _buildLanguageTile({required final AppLanguage appLanguage}) {
    final bool isSelected =
        appLanguage.languageCode ==
        HiveRepository.getCurrentLanguage()?.languageCode;

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 12),
      child: CustomInkWellContainer(
        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf12),
        onTap: () {
          setState(() {
            _isProcessingLanguageData = true;
          });
          context.read<LanguageDataCubit>().getLanguageData(
            languageData: appLanguage,
          );
        },
        child: CustomContainer(
          color: context.colors.surfacePrimary,
          borderRadius: UiUtils.borderRadiusOf12,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipOval(
                child: CustomCachedNetworkImage(
                  networkImageUrl: appLanguage.imageURL,
                  height: 32,
                  width: 32,
                  fit: BoxFit.cover,
                ),
              ),
              const CustomSizedBox(width: 12),
              Expanded(
                child: CustomText(
                  appLanguage.languageName,
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected
                    ? context.colors.iconBrand
                    : context.colors.iconTertiary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) =>
      BlocListener<LanguageDataCubit, LanguageDataState>(
        listener: (context, state) async {
          if (state is GetLanguageDataSuccess) {
            await HiveRepository.storeLanguage(
              data: state.jsonData,
              lang: state.currentLanguage,
            );
            if (!context.mounted) return;
            await context.read<SystemSettingCubit>().getSystemSettings();
            if (!context.mounted) return;
            final futures = <Future>[
              context.read<HomeScreenCubit>().fetchHomeScreenData(),
              if (HiveRepository.getUserToken != '') ...[
                context.read<BookingCubit>().fetchAllBookings(status: ''),
                context.read<CategoryCubit>().getCategory(),
                context.read<CartCubit>().getCartDetails(isReorderCart: false),
                context.read<BookmarkCubit>().fetchBookmark(type: 'list'),
              ],
            ];

            await Future.wait(futures);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _isProcessingLanguageData = false;
                });
                Navigator.pop(context);
              }
            });
          }
        },
        child: Directionality(
          textDirection: Directionality.of(context),
          child: AnnotatedSafeArea(
            isAnnotated: true,
            applyBottomInset: false,
            child: Scaffold(
              backgroundColor: context.colors.backgroundSecondary,
              appBar: UiUtils.getSimpleAppBar(
                context: context,
                title: 'language'.translate(context: context),
              ),
              body: Stack(
                children: [
                  BlocBuilder<LanguageListCubit, LanguageListState>(
                    builder: (context, state) {
                      if (state is GetLanguageListInProgress) {
                        return const LanguageListShimmerEffect();
                      }

                      if (state is GetLanguageListError) {
                        return ErrorContainer(
                          errorMessage: state.error.toString().translate(
                            context: context,
                          ),
                          onTapRetry: getLanguageList,
                          showRetryButton: true,
                        );
                      }

                      if (state is GetLanguageListSuccess) {
                        if (state.languages.isEmpty) {
                          return Center(
                            child: CustomText(
                              'noLanguagesAvailable'.translate(
                                context: context,
                              ),
                              color: context.colors.textPrimary,
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            24,
                            16,
                            24 + MediaQuery.viewPaddingOf(context).bottom,
                          ),
                          itemCount: state.languages.length,
                          itemBuilder: (context, index) => _buildLanguageTile(
                            appLanguage: state.languages[index],
                          ),
                        );
                      }

                      return const LanguageListShimmerEffect();
                    },
                  ),
                  if (_isProcessingLanguageData)
                    Positioned.fill(
                      child: ColoredBox(
                        color: context.colors.overlayDefault,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: context.colors.iconBrand,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
}
