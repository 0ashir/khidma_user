import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/ui/widgets/chatUnreadCountBadge.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUsersScreen extends StatefulWidget {
  const ChatUsersScreen({super.key});

  @override
  State<ChatUsersScreen> createState() => _ChatUsersScreenState();

  static Route route(RouteSettings routeSettings) {
    return CupertinoPageRoute(builder: (_) => const ChatUsersScreen());
  }
}

class _ChatUsersScreenState extends State<ChatUsersScreen>
    with SingleTickerProviderStateMixin {
  late final List<ChatUsersCubit> _chatUserCubitList = [
    context.read<EnquiryChatUserCubit>(),
    context.read<BookingChatUserCubit>(),
  ];
  late TabController _typetabController;

  late final ValueNotifier<ChatUsersCubit> selectedCubit = ValueNotifier(
    _chatUserCubitList.first,
  );

  @override
  void initState() {
    _typetabController = TabController(
      length: _chatUserCubitList.length,
      vsync: this,
    );
    _typetabController.addListener(() {
      if (!_typetabController.indexIsChanging) {
        selectedCubit.value = _chatUserCubitList[_typetabController.index];
      }
    });
    for (final cubit in _chatUserCubitList) {
      final state = cubit.state;
      if (state is! ChatUsersFetchSuccess || state.chatUsers.isEmpty) {
        cubit.fetchChatUsers();
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    _typetabController.dispose();
    selectedCubit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedSafeArea(
      isAnnotated: true,
      child: InterstitialAdWidget(
        child: Scaffold(
          backgroundColor: context.colors.backgroundSecondary,
          appBar: UiUtils.getSimpleAppBar(
            context: context,
            titleWidget: ValueListenableBuilder<ChatUsersCubit>(
              valueListenable: selectedCubit,
              builder: (context, cubit, _) {
                return BlocSelector<ChatUsersCubit, ChatUsersState, int>(
                  bloc: cubit,
                  selector: (state) =>
                      state is ChatUsersFetchSuccess ? state.totalOffset : 0,
                  builder: (context, count) {
                    return Column(
                      spacing: 4,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomText(
                          'chat'.translate(context: context),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: context.colors.textPrimary,
                        ),
                        CustomText(
                          '$count ${'chat'.translate(context: context)}',
                          fontSize: 12,
                          color: context.colors.textTertiary,
                          fontWeight: FontWeight.w400,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            isLeadingIconEnable: false,
            actions: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 15),
                child: CustomToolTip(
                  toolTipMessage: "blockedUsers".translate(context: context),
                  child: CustomInkWellContainer(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      Navigator.pushNamed(context, blockUserScreen);
                    },
                    child: CustomContainer(
                      padding: const EdgeInsets.all(8),
                      color: context.colors.backgroundPrimary,
                      borderRadius: 24,
                      child: CustomSvgPicture(
                        svgImage: AppAssets.blockUserScreen,
                        height: 24,
                        width: 24,
                        color: context.colors.iconPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(48.rh(context) + 1.5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(height: 1.5, color: context.colors.borderMuted),
                  TopRoundedUnderlineTabBar(
                    controller: _typetabController,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 16,
                        color: context.colors.overlayHeaderShadow,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    tabs: _chatUserCubitList.map((status) {
                      return BlocSelector<ChatUsersCubit, ChatUsersState, int>(
                        bloc: status,
                        selector: (state) => state is ChatUsersFetchSuccess
                            ? state.totalUnreadUsers
                            : 0,
                        builder: (context, unreadCount) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                status.filterType.translate(context: context),
                              ),
                              if (unreadCount > 0) ...[
                                const CustomSizedBox(width: 4),
                                ChatUnreadCountBadge(
                                  count: unreadCount,
                                  fontSize: 10.0,
                                  borderColor: context.colors.borderWhite,
                                ),
                              ],
                            ],
                          );
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const BannerAdWidget(),
          body: TabBarView(
            controller: _typetabController,
            children: _chatUserCubitList.map((e) {
              return _ChatUserListContainer(chatUsersCubit: e);
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _ChatUserListContainer extends StatefulWidget {
  final ChatUsersCubit chatUsersCubit;
  const _ChatUserListContainer({required this.chatUsersCubit});

  @override
  State<_ChatUserListContainer> createState() => __ChatUserListContainerState();
}

class __ChatUserListContainerState extends State<_ChatUserListContainer>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final ScrollController _scrollController = ScrollController()
    ..addListener(_chatUserScrollListener);

  void _chatUserScrollListener() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent - 200) {
      if (widget.chatUsersCubit.hasMore()) {
        widget.chatUsersCubit.fetchMoreChatUsers();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final state = widget.chatUsersCubit.state;
    if (state is! ChatUsersFetchSuccess || state.chatUsers.isEmpty) {
      widget.chatUsersCubit.fetchChatUsers();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_chatUserScrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildShimmerLoader() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: UiUtils.numberOfShimmerContainer,
      itemBuilder: (context, index) => _buildOneChatUserShimmerLoader(),
    );
  }

  Widget _buildOneChatUserShimmerLoader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: CustomShimmerLoadingContainer(
        height: 80,
        borderRadius: UiUtils.borderRadiusOf12,
      ),
    );
  }

  Widget _buildListFooter(ChatUsersFetchSuccess state) {
    if (state.moreChatUserFetchProgress) {
      return _buildOneChatUserShimmerLoader();
    }
    if (state.moreChatUserFetchError) {
      return CustomLoadingMoreContainer(
        isError: true,
        onErrorButtonPressed: widget.chatUsersCubit.fetchMoreChatUsers,
      );
    }
    return const SizedBox.shrink();
  }

  void fetchChatUsers() {
    widget.chatUsersCubit.fetchChatUsers();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<ChatUsersCubit, ChatUsersState>(
      bloc: widget.chatUsersCubit,
      builder: (context, state) {
        if (state is ChatUsersFetchSuccess) {
          return state.chatUsers.isEmpty
              ? Center(
                  child: NoDataFoundWidget(
                    titleKey: "noChatsFound".translate(context: context),
                    subtitleKey: "noChatsFoundSubTitle".translate(
                      context: context,
                    ),
                    imagePath: AppAssets.noChat,
                  ),
                )
              : CustomRefreshIndicator(
                  displacment: 12,
                  onRefreshCallback: () {
                    fetchChatUsers();
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 98),
                    itemCount: state.chatUsers.length + 1,
                    itemBuilder: (context, index) {
                      if (index == state.chatUsers.length) {
                        return _buildListFooter(state);
                      }
                      return ChatUserItemWidget(
                        chatUser: state.chatUsers[index],
                        chatUsersCubit: widget.chatUsersCubit,
                      );
                    },
                  ),
                );
        }
        if (state is ChatUsersFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessage: state.errorMessage,
              onTapRetry: () {
                fetchChatUsers();
              },
            ),
          );
        }
        return _buildShimmerLoader();
      },
    );
  }
}
