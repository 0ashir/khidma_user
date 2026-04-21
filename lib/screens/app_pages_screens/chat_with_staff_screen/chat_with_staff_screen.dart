import 'dart:developer';
import '../../../config.dart';
import '../../../../providers/app_pages_providers/chat_with_staff_provider.dart';

class ChatWithStaffScreen extends StatefulWidget {
  const ChatWithStaffScreen({super.key});

  @override
  State<ChatWithStaffScreen> createState() => _ChatWithStaffScreenState();
}

class _ChatWithStaffScreenState extends State<ChatWithStaffScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatWithStaffProvider>(builder: (context1, value, child) {
      // log("value.booking!.bookingStatus::${value.booking?.bookingStatus?.slug}");
      return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            log("didPopL$didPop");
            value.onBack(context, false);
          },
          child: StatefulWrapper(
              onInit: () {
                Future.delayed(const Duration(milliseconds: 150), () {
                  value.onReady(context);
                });
              },
              child: Scaffold(
                  appBar: const AppBarCommon(title: "Administrator"),
                  body: LoadingComponent(
                    child: Column(children: [
                      // AppBar(),
                      value.isLoading
                          ? Expanded(
                              child: Center(
                                  child: Image.asset(
                              eGifAssets.loader,
                              height: Sizes.s100,
                              width: Sizes.s100,
                            )))
                          : Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                      child: value.message.isEmpty
                                          ? const CommonEmpty()
                                          : ListView(
                                              reverse: true,
                                              children: [
                                                value
                                                    .timeLayout(context)
                                                    .marginOnly(
                                                        bottom: Insets.i18)
                                              ],
                                            )),
                                  // Input area is always visible for chat with staff/admin
                                  /* if (value.booking != null)
                                if (value.booking!.bookingStatus?.slug !=
                                    appFonts.completed) */
                                  Row(children: [
                                    // Text Field
                                    Expanded(
                                        child: TextFormField(
                                            controller: value.controller,
                                            maxLines: 4,
                                            minLines: 1,
                                            style: appCss.dmDenseMedium14
                                                .textColor(
                                                    appColor(context).darkText),
                                            cursorColor:
                                                appColor(context).darkText,
                                            decoration: InputDecoration(
                                                fillColor:
                                                    appColor(context).whiteBg,
                                                filled: true,
                                                isDense: true,
                                                disabledBorder: const OutlineInputBorder(
                                                    borderRadius: BorderRadius.all(
                                                        Radius.circular(
                                                            AppRadius.r8)),
                                                    borderSide: BorderSide.none),
                                                focusedBorder: const OutlineInputBorder(
                                                    borderRadius: BorderRadius.all(
                                                        Radius.circular(AppRadius.r8)),
                                                    borderSide: BorderSide.none),
                                                enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(AppRadius.r8)), borderSide: BorderSide.none),
                                                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(AppRadius.r8)), borderSide: BorderSide.none),
                                                contentPadding: const EdgeInsets.symmetric(horizontal: Insets.i15, vertical: Insets.i15),
                                                prefixIcon: SvgPicture.asset(eSvgAssets.gallery, colorFilter: ColorFilter.mode(appColor(context).lightText, BlendMode.srcIn)).paddingSymmetric(horizontal: Insets.i20).inkWell(onTap: () => value.showLayout(context)),
                                                hintStyle: appCss.dmDenseMedium14.textColor(appColor(context).lightText),
                                                hintText: language(context, translations!.writeHere),
                                                errorMaxLines: 2))),
                                    const HSpace(Sizes.s8),
                                    // Send button
                                    SizedBox(
                                            child:
                                                SvgPicture.asset(eSvgAssets.send)
                                                    .paddingAll(Insets.i8))
                                        .decorated(
                                            color: appColor(context).primary,
                                            borderRadius: const BorderRadius.all(
                                                Radius.circular(AppRadius.r6)))
                                        .inkWell(
                                            onTap: () => value.setMessage(
                                                value.controller.text,
                                                MessageType.text,
                                                context))
                                  ])
                                      .paddingOnly(
                                          bottom: Sizes.s10,
                                          right: rtl(context) ? 0 : Insets.i20,
                                          left: rtl(context) ? Insets.i20 : 0)
                                      .boxBorderExtension(context,
                                          isShadow: true, radius: 0)
                                ],
                              ),
                            ),
                    ]),
                  ))));
    });
  }
}
