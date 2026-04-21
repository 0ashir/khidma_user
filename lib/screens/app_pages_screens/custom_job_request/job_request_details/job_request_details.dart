import 'package:fixit_user/providers/app_pages_providers/job_request_providers/job_request_details_provider.dart';
import 'package:fixit_user/screens/app_pages_screens/custom_job_request/job_request_details/layouts/bid_list_card.dart';
import 'package:fixit_user/screens/app_pages_screens/custom_job_request/job_request_details/layouts/job_request_service_description.dart';

import '../../../../config.dart';

import 'dart:developer';

import 'layouts/job_request_shimmer.dart';

class JobRequestDetails extends StatefulWidget {
  const JobRequestDetails({super.key});

  @override
  State<JobRequestDetails> createState() => _JobRequestDetailsState();
}

class _JobRequestDetailsState extends State<JobRequestDetails>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Consumer2<JobRequestDetailsProvider, JobRequestListProvider>(
        builder: (context1, serviceCtrl, jobList, child) {
      return Container(
        color: appColor(context).whiteBg,
        child: SafeArea(
          child: StatefulWrapper(
              onInit: () => Future.delayed(DurationClass.ms50)
                  .then((val) => serviceCtrl.onReady(context)),
              child: PopScope(
                  canPop: true,
                  onPopInvoked: (didPop) {
                    serviceCtrl.onBack(context, false);
                    if (didPop) return;
                  },
                  child: Scaffold(
                    body: RefreshIndicator(
                      onRefresh: () {
                        return serviceCtrl.onRefresh(context);
                      },
                      child: serviceCtrl.isLoader == true
                          ? const JobRequestShimmer()
                          : serviceCtrl.service == null &&
                                  serviceCtrl.isLoader == false
                              ? EmptyLayout(
                                  title: translations!.noDataFound,
                                  subtitle: translations!.noDataFoundDesc,
                                  buttonText: translations!.refresh,
                                  isButtonShow: false,
                                  widget: Image.asset(eImageAssets.emptyCart,
                                      height: Sizes.s230),
                                ).marginOnly(top: Sizes.s50)
                              : Scaffold(
                                  body: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 1200),
                                  opacity: serviceCtrl.widget1Opacity,
                                  child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        SingleChildScrollView(
                                            controller:
                                                serviceCtrl.scrollController,
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ServiceImageLayout(
                                                    isJobRequest: true,
                                                    editTap: () => route.pushNamed(
                                                        context,
                                                        routeName
                                                            .addJobRequestList,
                                                        arg: {
                                                          "service": serviceCtrl
                                                              .service,
                                                          "isEdit": true
                                                        }),
                                                    onBack: () => serviceCtrl
                                                        .onBack(context, true),
                                                    title: serviceCtrl
                                                        .service!.title!,
                                                    image: serviceCtrl.service!
                                                            .media!.isNotEmpty
                                                        ? serviceCtrl
                                                            .service!
                                                            .media![serviceCtrl
                                                                .selectedIndex]
                                                            .originalUrl!
                                                        : "",
                                                  ),
                                                  if (serviceCtrl.service!
                                                          .media!.length >
                                                      1)
                                                    const VSpace(Sizes.s12),
                                                  if (serviceCtrl.service!
                                                          .media!.length >
                                                      1)
                                                    Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: serviceCtrl
                                                            .service!.media!
                                                            .asMap()
                                                            .entries
                                                            .map((e) => ServicesImageLayout(
                                                                data: e.value,
                                                                index: e.key,
                                                                selectIndex:
                                                                    serviceCtrl
                                                                        .selectedIndex,
                                                                onTap: () =>
                                                                    serviceCtrl
                                                                        .onImageChange(
                                                                            e.key)))
                                                            .toList()),
                                                  Column(children: [
                                                    Stack(
                                                        alignment:
                                                            Alignment.center,
                                                        children: [
                                                          Image.asset(
                                                              eImageAssets
                                                                  .servicesBg,
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width),
                                                          Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                    language(
                                                                        context,
                                                                        translations!
                                                                            .amount),
                                                                    style: appCss
                                                                        .dmDenseMedium12
                                                                        .textColor(
                                                                            appColor(context).primary)),
                                                                Text(
                                                                    symbolPosition
                                                                        ? "${getSymbol(context)}${(currency(context).currencyVal * (serviceCtrl.service!.status != "accepted" ? serviceCtrl.service!.initialPrice! : serviceCtrl.service!.finalPrice!)).toStringAsFixed(2)}"
                                                                        : "${(currency(context).currencyVal * (serviceCtrl.service!.status != "accepted" ? serviceCtrl.service!.initialPrice! : serviceCtrl.service!.finalPrice!)).toStringAsFixed(2)}${getSymbol(context)}",
                                                                    style: appCss
                                                                        .dmDenseBold18
                                                                        .textColor(
                                                                            appColor(context).primary))
                                                              ]).paddingSymmetric(
                                                              horizontal:
                                                                  Insets.i20)
                                                        ]).paddingSymmetric(
                                                        vertical: Insets.i15),
                                                    JobRequestServiceDescription(
                                                        services: serviceCtrl
                                                            .service),
                                                  ]).paddingSymmetric(
                                                      horizontal: Insets.i20),
                                                  const VSpace(Sizes.s20),
                                                  if (serviceCtrl.service!
                                                          .providerId !=
                                                      null)
                                                    if (serviceCtrl.service!.bids ==
                                                            null &&
                                                        serviceCtrl.service!
                                                            .bids!.isNotEmpty)
                                                      Text(
                                                              language(
                                                                  context,
                                                                  translations!
                                                                      .bidderList),
                                                              overflow:
                                                                  TextOverflow
                                                                      .clip,
                                                              style: appCss
                                                                  .dmDenseBold16
                                                                  .textColor(
                                                                      appColor(context)
                                                                          .darkText))
                                                          .paddingSymmetric(
                                                              horizontal: Sizes.s20),
                                                  const VSpace(Sizes.s10),
                                                  if (serviceCtrl.service!
                                                          .providerId ==
                                                      null)
                                                    ...serviceCtrl
                                                        .service!.bids!
                                                        .asMap()
                                                        .entries
                                                        .map((e) => BidListCard(
                                                              provider: e.value
                                                                  .provider,
                                                              amount: e
                                                                  .value.amount,
                                                              acceptTap: () {
                                                                log("e.value.amount:::${e.value.amount}");
                                                                serviceCtrl
                                                                    .acceptProvider(
                                                                        context,
                                                                        e.value
                                                                            .provider!,
                                                                        e.value
                                                                            .id);
                                                              },
                                                              rejectTap: () => serviceCtrl
                                                                  .rejectJobRequestConfirmation(
                                                                      context,
                                                                      e.value
                                                                          .id),
                                                              /* serviceCtrl
                                                                .acceptRejectBid(
                                                                    context,
                                                                    e.value.id,
                                                                    isCancel:
                                                                        true) */
                                                            )),
                                                  if (serviceCtrl.service!
                                                              .providerId !=
                                                          null &&
                                                      serviceCtrl.service!.service !=
                                                          null)
                                                    BidListCard(
                                                        provider: serviceCtrl
                                                            .service!
                                                            .service!
                                                            .user,
                                                        amount: serviceCtrl
                                                            .service!
                                                            .finalPrice!,
                                                        isAction: false),
                                                  if (serviceCtrl.service!
                                                          .providerId !=
                                                      null)
                                                    ButtonCommon(
                                                            title: translations!
                                                                .bookYourService!,
                                                            margin: 20,
                                                            onTap: () =>
                                                                serviceCtrl
                                                                    .bookService(
                                                                        context))
                                                        .marginOnly(
                                                            top: Sizes.s20)
                                                ]).marginOnly(
                                                bottom: Insets.i100)),
                                      ]),
                                )),
                    ),
                  ))),
        ),
      );
    });
  }
}
