import 'dart:developer';
import '../../../config.dart';
import '../../../providers/app_pages_providers/offer_chat_provider.dart';

class ProviderChatScreen extends StatefulWidget {
  const ProviderChatScreen({super.key});

  @override
  State<ProviderChatScreen> createState() => _ProviderChatScreenState();
}

class _ProviderChatScreenState extends State<ProviderChatScreen> {
  @override
  void initState() {
    Future.microtask(() {
      final args = ModalRoute.of(context)!.settings.arguments as Map?;

      // if (args != null) {
      //   final chatProvider =
      //       Provider.of<OfferChatProvider>(context, listen: false);

      //   log("🧩 Parsed args:");
      //   log("chatId: ${args['chatId']}");
      //   log("userId: ${args['userId']}");
      //   log("name: ${args['name']}");
      //   log("image: ${args['image']}");
      //   log("role: ${args['role']}");
      //   log("token: ${args['token']}");
      //   log("phone: ${args['phone']}");
      //   log("code: ${args['code']}");
      //   chatProvider.chatId = args['chatId']?.toString();
      //   chatProvider.userId = int.tryParse(args['userId'].toString()) ?? 0;
      //   chatProvider.name = args['name'];
      //   chatProvider.image = args['image'];
      //   chatProvider.role = args['role'];
      //   chatProvider.token = args['token'];
      //   chatProvider.phone = args['phone'].toString();
      //   chatProvider.code = args['code']?.toString();
      // }
      if (args != null && userModel != null) {
        final chatProvider =
            Provider.of<OfferChatProvider>(context, listen: false);

        final int currentUserId = userModel!.id;
        final int otherUserId =
            int.tryParse(args['userId']?.toString() ?? '') ?? 0;

        String chatId;

        if (args['chatId'] != null && args['chatId'].toString().isNotEmpty) {
          chatId = args['chatId'].toString();
        } else {
          final ids = [currentUserId, otherUserId]..sort();
          chatId = '${ids[0]}_${ids[1]}';
        }

        chatProvider.chatId = chatId;
        chatProvider.userId = otherUserId;
        chatProvider.name = args['name'];
        chatProvider.image = args['image'];
        chatProvider.role = args['role'];
        chatProvider.token = args['token'];
        chatProvider.phone = args['phone']?.toString() ?? '';
        chatProvider.code = args['code']?.toString();
      }

      Provider.of<OfferChatProvider>(context, listen: false).onReady(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    log("message 1233 ${userModel?.id}");
    return Consumer<OfferChatProvider>(builder: (context1, value, child) {
      return PopScope(
          canPop: true,
          onPopInvoked: (didPop) {
            value.onBack(context, false);
            if (didPop) return;
          },
          child: StatefulWrapper(
              onInit: () => Future.delayed(const Duration(milliseconds: 150),
                  () => value.onReady(context)),
              child: Scaffold(
                  body: LoadingComponent(
                      child: Column(children: [
                ChatAppBarLayout(
                    onSelected: (index) {
                      log("index");
                      /* if (index == 1) {
                        value.onClearChat(context, this);
                      } else { */
                      value.onTapPhone(context);
                      /* } */
                    },
                    isOffer: true),

                // display
                Expanded(
                    child: ListView(reverse: true, children: [
                  value.timeLayout(context).marginOnly(bottom: Insets.i18)
                ])),

                // keyboard
                Row(children: [
                  // Text Field
                  Expanded(
                      child: TextFormField(
                          controller: value.controller,
                          maxLines: 4,
                          minLines: 1,
                          style: appCss.dmDenseMedium14
                              .textColor(appColor(context).darkText),
                          cursorColor: appColor(context).darkText,
                          decoration: InputDecoration(
                              fillColor: appColor(context).whiteBg,
                              filled: true,
                              isDense: true,
                              disabledBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(AppRadius.r8)),
                                  borderSide: BorderSide.none),
                              focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(AppRadius.r8)),
                                  borderSide: BorderSide.none),
                              enabledBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(AppRadius.r8)),
                                  borderSide: BorderSide.none),
                              border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(AppRadius.r8)),
                                  borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: Insets.i15, vertical: Insets.i15),
                              prefixIcon: SvgPicture.asset(eSvgAssets.gallery, colorFilter: ColorFilter.mode(appColor(context).lightText, BlendMode.srcIn)).padding(right: Sizes.s15, left: Sizes.s8).inkWell(onTap: () => value.showLayout(context)),
                              hintStyle: appCss.dmDenseMedium14.textColor(appColor(context).lightText),
                              hintText: language(context, appFonts.writeHere),
                              errorMaxLines: 2))),
                  const HSpace(Sizes.s8),

                  // Send button
                  SizedBox(
                          child: SvgPicture.asset(eSvgAssets.send)
                              .paddingAll(Insets.i8))
                      .decorated(
                          color: appColor(context).primary,
                          borderRadius: const BorderRadius.all(
                              Radius.circular(AppRadius.r6)))
                      .inkWell(
                          onTap: () => value.setMessage(
                              value.controller.text, MessageType.text, context))
                ])
                    .padding(horizontal: Sizes.s6)
                    .boxBorderExtension(context, isShadow: true, radius: 8)
                    .padding(horizontal: Sizes.s20, bottom: Sizes.s20)
              ])))));
    });
  }
}
