import 'dart:developer';

import '../../../../config.dart';

class FavouriteListBody extends StatelessWidget {
  final int? index;

  const FavouriteListBody({super.key, this.index});

  @override
  Widget build(BuildContext context) {
    return Consumer<FavouriteListProvider>(builder: (context1, value, child) {
      log("value.serviceFavList::${value.serviceFavList}//$index///${value.providerFavList}");
      return Column(
          children: index == 0
              ? [
                  if (value.providerFavList.isEmpty) const CommonEmpty(),
                  if (value.providerFavList.isNotEmpty)
                    ...value.providerFavList.asMap().entries.map((e) =>
                        FavouriteListLayout(
                            data: e.value,
                            onTap: () {
                              Provider.of<ProviderDetailsProvider>(context,
                                      listen: false)
                                  .getProviderById(
                                      context, e.value.provider!.id);

                              route.pushNamed(
                                  context, routeName.providerDetailsScreen,
                                  arg: {'providerId': e.value.provider!.id});
                            },
                            heartTap: () => value.onRemoveService(context,
                                id: e.value.provider!.id)))
                ]
              : [
                  if (value.serviceFavList.isEmpty) const CommonEmpty(),
                  if (value.serviceFavList.isNotEmpty)
                    GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: value.serviceFavList.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisExtent: Sizes.s240,
                                mainAxisSpacing: 15,
                                crossAxisSpacing: Sizes.s15),
                        itemBuilder: (context2, index) {
                          return ServiceListLayout(
                                  isFav: true,
                                  favTap: (isFav) {
                                    if (!isFav) {
                                      value.onRemoveService(context,
                                          id: value.serviceFavList[index]
                                              .service!.id);

                                      value.deleteFav(context,
                                          isFavId:
                                              value.favoriteList[index].id);
                                    }
                                  },
                                  onTap: () async {
                                    SharedPreferences pref =
                                        await SharedPreferences.getInstance();
                                    if (pref.getBool(
                                            session.isContinueAsGuest) ==
                                        true) {
                                      route.pushNamedAndRemoveUntil(
                                          context, routeName.login);
                                    } else {
                                      value.onFeatured(
                                          context,
                                          value.serviceFavList[index].service,
                                          index);
                                    }
                                  },
                                  data: value.serviceFavList[index].service)
                              .inkWell(onTap: () {
                            log("value.serviceFavList[index].service,${value.serviceFavList[index].id}");
                            Provider.of<ServicesDetailsProvider>(context,
                                    listen: false)
                                .getServiceById(context,
                                    value.serviceFavList[index].service?.id);
                            route.pushNamed(
                                context, routeName.servicesDetailsScreen, arg: {
                              'serviceId':
                                  value.serviceFavList[index].service!.id
                            });
                          });
                        })
                ]);
    });
  }
}
