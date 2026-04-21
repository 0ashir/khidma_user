import 'dart:developer';

import '../../../config.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Consumer3<BookingProvider, ChatProvider, ChatHistoryProvider>(
        builder: (context1, booking, value, chatHis, child) {
      log("value.booking!.bookingStatus::${value.booking?.bookingStatus?.slug}");
      return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            log("didPopL$didPop");
            value.onBack(context, false);
          },
          child: StatefulWrapper(
              onInit: () {
                Future.delayed(const Duration(milliseconds: 150), () {
                  value.onReady(context);
                  chatHis.onReady(context);
                });
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) setState(() => isLoading = false);
                });
              },
              child: Scaffold(
                  body: Column(children: [
                const ChatAppBarLayout(
                    /*onSelected: (index) {
                  log("SE :$index");
                  */ /*  if (index == 2) {
                value.onClearChat(context, this);
              } else { */ /*
                  value.onCallTap(context, index);
                  */ /*     } */ /*
                }*/
                    ),
                isLoading
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
                              child: value.timeLayout(context),
                            ),
                            if (value.booking != null)
                              if (value.booking!.bookingStatus?.slug !=
                                  appFonts.completed)
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
                      )
              ]))));
    });
  }
}
