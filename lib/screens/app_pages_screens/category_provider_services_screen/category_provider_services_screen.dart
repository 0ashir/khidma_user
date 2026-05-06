// ignore_for_file: use_build_context_synchronously

import 'package:fixit_user/common_tap.dart';
import '../../../config.dart';

class CategoryProviderServicesScreen extends StatelessWidget {
  final ProviderModel provider;
  final List<Services> services;
  final String categoryName;

  const CategoryProviderServicesScreen({
    super.key,
    required this.provider,
    required this.services,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<ServicesDetailsProvider, CategoriesDetailsProvider>(
        builder: (context, serviceCtrl, catCtrl, child) {
      return Scaffold(
        appBar: AppBarCommon(
          title: provider.name ?? categoryName,
          onTap: () => route.pop(context),
        ),
        body: services.isEmpty
            ? Center(
                child: EmptyLayout(
                  title: translations!.noDataFound,
                  subtitle: translations!.noDataFoundDesc,
                  buttonText: translations!.refresh,
                  isButtonShow: false,
                  widget: Image.asset(
                    eImageAssets.emptyCart,
                    height: Sizes.s230,
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.symmetric(vertical: Insets.i15),
                children: services.asMap().entries.map((e) {
                  final service = e.value;
                  return FeaturedServicesLayout(
                    isShowAdd: false,
                    data: service,
                    isProvider: false,
                    addTap: () => onBook(context, service, provider: provider),
                    onTap: catCtrl.isAlert
                        ? () {}
                        : () {
                            serviceCtrl.getServiceById(context, service.id);
                            final chat = Provider.of<ChatHistoryProvider>(
                                context,
                                listen: false);
                            chat.onReady(context);
                            route.pushNamed(
                              context,
                              routeName.servicesDetailsScreen,
                              arg: {'serviceId': service.id},
                            );
                          },
                  ).paddingSymmetric(horizontal: Insets.i20);
                }).toList(),
              ),
      );
    });
  }
}
