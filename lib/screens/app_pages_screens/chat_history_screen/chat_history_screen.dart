import '../../../config.dart';
import '../../../widgets/more_option_layout.dart';
import 'layouts/chat_history_layout.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

/* class _ChatHistoryScreenState extends State<ChatHistoryScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // Fetch data immediately
    Provider.of<ChatHistoryProvider>(context, listen: false)
        .onReady(context);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted) {
    //     Provider.of<ChatHistoryProvider>(context, listen: false)
    //         .onReady(context);
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatHistoryProvider>(
      builder: (context, value, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              language(context, translations!.chatHistory),
              style: appCss.dmDenseBold18.textColor(appColor(context).darkText),
            ),
            centerTitle: true,
            actions: [
              if (!value.isLoading && value.chatHistory.isNotEmpty)
                MoreOptionLayout(
                  onSelected: (index) =>
                      value.onTapOption(index, context, this),
                  list: appArray.chatHistoryOptionList,
                ).paddingSymmetric(horizontal: Insets.i20)
            ],
            leadingWidth: 80,
            leading: CommonArrow(
              arrow: eSvgAssets.arrowLeft,
              onTap: () => route.pop(context),
            ).paddingAll(Insets.i8),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await value.onReady(context);
            },
            child: value.isLoading&&value.chatHistory.isEmpty
                ? Image.asset(
              eGifAssets.loader,
              height: Sizes.s100,
            ).center()
                : value.chatHistory.isEmpty
                ? CommonEmpty(
              isButtonShow: true,
              bTap: () => value.onTapOption(0, context, this),
            )
                : SingleChildScrollView(
              child: Column(
                children: [
                  Column(
                    children: value.chatHistory
                        .asMap()
                        .entries
                        .map((e) => ChatHistoryLayout(
                      onTap: () => value.onChatClick(
                          context, e.value),
                      data: e.value.data(),
                      index: e.key,
                      list: value.chatHistory
                    ))
                        .toList(),
                  ).paddingAll(Insets.i15),
                ],
              ).paddingSymmetric(
                horizontal: Insets.i20,
                vertical: Sizes.s15,
              ),
            ),
          ),
        );
      },
    );
  }
} */

class _ChatHistoryScreenState extends State<ChatHistoryScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<ChatHistoryProvider>(context, listen: false)
            .onReady(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatHistoryProvider>(
      builder: (context, value, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              language(context, translations!.chatHistory),
              style: appCss.dmDenseBold18.textColor(appColor(context).darkText),
            ),
            centerTitle: true,
            actions: [
              if (value.chatHistory.isNotEmpty)
                MoreOptionLayout(
                  onSelected: (index) =>
                      value.onTapOption(index, context, this),
                  list: appArray.chatHistoryOptionList,
                ).paddingSymmetric(horizontal: Insets.i20),
            ],
            leadingWidth: 80,
            leading: CommonArrow(
              arrow: eSvgAssets.arrowLeft,
              onTap: () => route.pop(context),
            ).paddingAll(Insets.i8),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await value.onReady(context);
            },
            child: Builder(
              builder: (_) {
                if (value.isLoading && value.chatHistory.isEmpty) {
                  return Image.asset(
                    eGifAssets.loader,
                    height: Sizes.s100,
                  ).center();
                } else if (value.chatHistory.isEmpty) {
                  return CommonEmpty(
                    isButtonShow: true,
                    bTap: () => value.onTapOption(0, context, this),
                  );
                } else {
                  return ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Insets.i20, vertical: Sizes.s15),
                    children: [
                      Column(
                        children: value.chatHistory
                            .asMap()
                            .entries
                            .map((e) => ChatHistoryLayout(
                                  onTap: () =>
                                      value.onChatClick(context, e.value),
                                  data: e.value.data(),
                                  index: e.key,
                                  list: value.chatHistory,
                                ))
                            .toList(),
                      ).paddingAll(Insets.i15),
                    ],
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
