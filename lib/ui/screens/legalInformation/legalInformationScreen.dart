import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LegalInformationScreen extends StatefulWidget {
  const LegalInformationScreen({final Key? key}) : super(key: key);

  static Route route(final RouteSettings routeSettings) => CupertinoPageRoute(
    builder: (final _) => BlocProvider(
      create: (final context) =>
          FetchCustomPagesCubit(CustomPageRepository())..fetchCustomPages(),
      child: const LegalInformationScreen(),
    ),
  );

  @override
  State<LegalInformationScreen> createState() => _LegalInformationScreenState();
}

class _LegalInformationScreenState extends State<LegalInformationScreen> {
  Widget _buildRow(
    final BuildContext context, {
    required final String icon,
    required final String title,
    required final VoidCallback onTap,
  }) => CustomContainer(
    width: double.infinity,
    color: context.colors.surfacePrimary,
    borderRadius: UiUtils.borderRadiusOf12,
    padding: const EdgeInsets.all(12),
    child: CustomInkWellContainer(
      onTap: onTap,
      child: Row(
        children: [
          CustomContainer(
            color: context.colors.backgroundSecondary,
            borderRadius: 24,
            padding: const EdgeInsets.all(8),
            child: CustomSvgPicture(
              avoideResponsive: true,
              svgImage: icon,
              color: context.colors.iconPrimary,
              height: 20,
              width: 20,
            ),
          ),
          const CustomSizedBox(width: 12),
          Expanded(
            child: CustomText(
              title,
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
          CustomSvgPicture(
            svgImage: Directionality.of(context) == TextDirection.rtl
                ? AppAssets.backArrow
                : AppAssets.backArrowLtr,
            color: context.colors.iconPrimary,
            height: 24,
            width: 24,
            avoideResponsive: true,
          ),
        ],
      ),
    ),
  );

  void _openCustomPage(final CustomPageModel page) {
    Navigator.pushNamed(
      context,
      customPageDetailsRoute,
      arguments: {"title": page.translatedTitle, "pageKey": page.slug},
    );
  }

  Widget _buildCustomPagesSection() =>
      BlocBuilder<FetchCustomPagesCubit, FetchCustomPagesState>(
        builder: (final context, final state) {
          if (state is FetchCustomPagesInProgress) {
            return Column(
              children: List.generate(
                2,
                (final index) => const Padding(
                  padding: EdgeInsetsDirectional.only(bottom: 16),
                  child: CustomShimmerLoadingContainer(
                    height: 52,
                    width: double.infinity,
                    borderRadius: UiUtils.borderRadiusOf12,
                  ),
                ),
              ),
            );
          }
          if (state is FetchCustomPagesSuccess) {
            if (state.customPages.isEmpty) return const CustomSizedBox();
            return Column(
              children: List.generate(state.customPages.length, (final index) {
                final CustomPageModel page = state.customPages[index];
                return Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 16),
                  child: _buildRow(
                    context,
                    icon: AppAssets.fileText,
                    title: page.translatedTitle,
                    onTap: () => _openCustomPage(page),
                  ),
                );
              }),
            );
          }
          //a failed custom-pages fetch shouldn't block the static
          //about/privacy/terms rows above from being usable
          return const CustomSizedBox();
        },
      );

  @override
  Widget build(final BuildContext context) => AnnotatedSafeArea(
    isAnnotated: true,
    applyBottomInset: false,
    child: Scaffold(
      backgroundColor: context.colors.backgroundSecondary,
      appBar: UiUtils.getSimpleAppBar(
        context: context,
        title: 'legalAndInformation'.translate(context: context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          16,
        ).copyWith(bottom: 16 + MediaQuery.viewPaddingOf(context).bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildRow(
              context,
              icon: AppAssets.drAboutUs,
              title: 'aboutUs'.translate(context: context),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  customPageDetailsRoute,
                  arguments: {
                    "title": "aboutUs".translate(context: context),
                    "pageKey": "about_us",
                  },
                );
              },
            ),
            const CustomSizedBox(height: 16),
            _buildRow(
              context,
              icon: AppAssets.drPolicy,
              title: 'privacyAndPolicy'.translate(context: context),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  customPageDetailsRoute,
                  arguments: {
                    "title": "privacyAndPolicy".translate(context: context),
                    "pageKey": "customer_privacy_policy",
                  },
                );
              },
            ),
            const CustomSizedBox(height: 16),
            _buildRow(
              context,
              icon: AppAssets.fileText,
              title: 'termsofservice'.translate(context: context),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  customPageDetailsRoute,
                  arguments: {
                    "title": "termsofservice".translate(context: context),
                    "pageKey": "customer_terms_conditions",
                  },
                );
              },
            ),
            const CustomSizedBox(height: 16),
            _buildCustomPagesSection(),
          ],
        ),
      ),
    ),
  );
}
