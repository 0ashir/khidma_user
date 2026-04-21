import 'dart:async';
import 'dart:developer';
import 'package:flutter/scheduler.dart';
import '../../../config.dart';
import 'booking_shimmer/booking_shimmer.dart';
import 'layouts/filter_dropdown.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with TickerProviderStateMixin {
  Timer? _debounce;

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<DashboardProvider, ProfileProvider>(
        builder: (context2, dash, profile, child) {
      return Consumer2<LoginProvider, BookingProvider>(
          builder: (context1, login, value, child) {
        log("isContinueAsGuest: ${login.pref?.getBool(session.isContinueAsGuest)}");
        return StatefulWrapper(
            onInit: () async {
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              if (preferences.getBool(session.isContinueAsGuest) == false) {
                Future.delayed(Duration.zero, () {
                  if (value.bookingList.isEmpty &&
                      !value.isLoadingForBookingHistory) {
                    dash.getBookingHistory(context);
                  }
                });
              }
            },
            child: Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  leadingWidth: 80,
                  title: Text(
                    language(context, translations!.bookings),
                    style: appCss.dmDenseBold18
                        .textColor(appColor(context).darkText),
                  ),
                  centerTitle: true,
                  leading: SizedBox(
                    width: 40,
                    height: 40,
                    child: CommonArrow(
                      arrow: rtl(context)
                          ? eSvgAssets.arrowRight
                          : eSvgAssets.arrowLeft,
                      onTap: () {
                        dash.selectIndex = 0;
                        dash.notifyListeners();
                      },
                    ),
                  ).paddingAll(Insets.i8),
                  actions: [
                    Consumer<NotificationProvider>(
                      builder: (context2, notify, child) {
                        return SizedBox(
                          height: Sizes.s40,
                          width: Sizes.s40,
                          child: InkWell(
                            onTap: () => route.pushNamed(
                                context, routeName.notifications),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: appColor(context).fieldCardBg,
                              ),
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  SvgPicture.asset(
                                    eSvgAssets.notification,
                                    alignment: Alignment.center,
                                    fit: BoxFit.scaleDown,
                                    colorFilter: ColorFilter.mode(
                                      appColor(context).darkText,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  if (notify.totalCount() != 0)
                                    Positioned(
                                      top: 2,
                                      right: 2,
                                      child: Icon(
                                        Icons.circle,
                                        size: Sizes.s7,
                                        color: appColor(context).red,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ).paddingOnly(
                          left: rtl(context) ? Insets.i20 : 0,
                          right: rtl(context) ? 0 : Insets.i20,
                        );
                      },
                    ),
                  ],
                ),
                body: SafeArea(child: Builder(builder: (context) {
                  try {
                    if (login.pref?.getBool(session.isContinueAsGuest) ==
                        true) {
                      return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            EmptyLayout(
                                title:
                                    "You must login/register to modify or view your profile information.",
                                subtitle: "",
                                buttonText: translations!.login,
                                isBooking: true,
                                isButtonShow: true,
                                bTap: () async {
                                  await route.pushNamed(
                                      context, routeName.login);
                                  if (mounted &&
                                      login.pref!.getBool(
                                              session.isContinueAsGuest) ==
                                          false) {
                                    SchedulerBinding.instance
                                        .addPostFrameCallback((_) {
                                      value.resetPagination();
                                      dash.getBookingHistory(context);
                                    });
                                  }
                                },
                                widget: SizedBox(
                                    height: Sizes.s230,
                                    width: double.infinity,
                                    child: Image.asset(eImageAssets.noList,
                                        height: Sizes.s230,
                                        fit: BoxFit.contain)))
                          ]);
                    } else {
                      return RefreshIndicator(
                          onRefresh: () async {
                            value.resetPagination();
                            value.selectedValue = value.options.first;
                            value.isLoadingForBookingHistory = true;
                            await dash.getBookingHistory(context);
                          },
                          child: NotificationListener(
                              onNotification: (ScrollNotification scrollInfo) {
                                if (scrollInfo.metrics.pixels ==
                                        scrollInfo.metrics.maxScrollExtent &&
                                    !dash.isLoadingForBookingHistory &&
                                    value.hasMoreData) {
                                  dash.getBookingHistory(context,
                                      isLoadMore: true);
                                }
                                return false;
                              },
                              child: SingleChildScrollView(
                                  controller: _scrollController,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SearchTextFieldCommon(
                                            suffixIcon: value
                                                    .searchText.text.isNotEmpty
                                                ? SizedBox(
                                                    width: Sizes.s40,
                                                    height: Sizes.s40,
                                                    child: GestureDetector(
                                                        onTap: () {
                                                          if (value
                                                              .searchText
                                                              .text
                                                              .isNotEmpty) {
                                                            value.searchFocus
                                                                .unfocus();
                                                            value.searchText
                                                                .clear();
                                                            value
                                                                .resetPagination();
                                                            dash.loadBookingsFromLocal(
                                                                context);
                                                          } else {
                                                            value.searchFocus
                                                                .unfocus();
                                                          }
                                                        },
                                                        child: const Icon(
                                                            Icons.close)))
                                                : const SizedBox.shrink(),
                                            focusNode: value.searchFocus,
                                            hinText: language(
                                                context,
                                                translations!
                                                    .searchWithBookingId),
                                            controller: value.searchText,
                                            onChanged: (v) {
                                              if (_debounce?.isActive ??
                                                  false) {
                                                _debounce!.cancel();
                                              }
                                              _debounce = Timer(
                                                  const Duration(
                                                      milliseconds: 500), () {
                                                log("Search triggered with query: $v");
                                                if (v.isEmpty || v.length > 2) {
                                                  value.resetPagination();
                                                  dash.getBookingHistory(
                                                      context,
                                                      search: v);
                                                }
                                              });
                                            },
                                            onFieldSubmitted: (v) {
                                              if (_debounce?.isActive ??
                                                  false) {
                                                _debounce!.cancel();
                                              }
                                              log("Search submitted with query: $v");
                                              value.resetPagination();
                                              dash.getBookingHistory(context,
                                                  search: v);
                                            }).padding(horizontal: Insets.i20),
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                            language(
                                                                context,
                                                                translations!
                                                                    .allBooking),
                                                            style: appCss
                                                                .dmDenseMedium18
                                                                .textColor(appColor(
                                                                        context)
                                                                    .darkText))
                                                        .padding(
                                                            top: Insets.i25,
                                                            bottom: Insets.i15,
                                                            horizontal:
                                                                Sizes.s20),
                                                    const FilterDropdown().padding(
                                                        horizontal: Sizes.s20)
                                                  ]),
                                              value.isLoadingForBookingHistory &&
                                                      value.bookingList.isEmpty
                                                  ? const BookingShimmer() // Show shimmer only when loading and list is empty
                                                  : value.bookingList
                                                              .isNotEmpty &&
                                                          dash.isLoadingForBookingHistory ==
                                                              false &&
                                                          value.isLoadingForBookingHistory ==
                                                              false
                                                      ? Column(children: [
                                                          ListView.builder(
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              shrinkWrap: true,
                                                              physics:
                                                                  const NeverScrollableScrollPhysics(),
                                                              itemCount: value
                                                                  .bookingList
                                                                  .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                return BookingLayout(
                                                                    data: value
                                                                            .bookingList[
                                                                        index],
                                                                    index:
                                                                        index,
                                                                    editLocationTap: () => value.editAddress(
                                                                        context,
                                                                        value.bookingList[
                                                                            index]),
                                                                    editDateTimeTap: () => value.editDateTimeTap(
                                                                        context,
                                                                        value.bookingList[
                                                                            index]),
                                                                    onTap: () {
                                                                      print(
                                                                          "object====> ${value.bookingList[index]}");
                                                                      value.onTapBookings(
                                                                          value.bookingList[
                                                                              index],
                                                                          context);
                                                                    });
                                                              }),
                                                          if (dash.isLoadingForBookingHistory &&
                                                              value.hasMoreData)
                                                            Image.asset(
                                                                    eGifAssets
                                                                        .loader,
                                                                    height: Sizes
                                                                        .s80,
                                                                    width: Sizes
                                                                        .s80)
                                                                .center()
                                                                .paddingOnly(
                                                                    bottom: Sizes
                                                                        .s120)
                                                        ])
                                                      : EmptyLayout(
                                                          isButtonShow: false,
                                                          title: translations!
                                                              .yourBookingList,
                                                          subtitle: '',
                                                          widget: SizedBox(
                                                              height:
                                                                  Sizes.s306,
                                                              width: double
                                                                  .infinity,
                                                              child: Image.asset(
                                                                  eImageAssets
                                                                      .noList,
                                                                  height: Sizes
                                                                      .s306,
                                                                  fit: BoxFit
                                                                      .contain))),
                                              if (value.bookingList.length == 1)
                                                const VSpace(Sizes.s200)
                                            ]).paddingDirectional(
                                            bottom: Sizes.s50)
                                      ]).padding(bottom: Sizes.s20))));
                    }
                  } catch (e, stackTrace) {
                    log("Layout error: $e\n$stackTrace");
                    return Center(child: Text('Error rendering UI: $e'));
                  }
                }))));
      });
    });
  }
}
