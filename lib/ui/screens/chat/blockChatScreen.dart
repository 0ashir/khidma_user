import 'package:e_demand/cubits/chat/getBlockUserListCubit.dart';
import 'package:e_demand/cubits/chat/unblockUserCubit.dart';
import 'package:e_demand/ui/widgets/bottomsheets/layouts/confirmActionBottomSheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../app/generalImports.dart';

class BlockChatScreen extends StatefulWidget {
  const BlockChatScreen({super.key});

  static Route route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => GetBlockedUsersCubit(ChatRepository()),
          ),
          BlocProvider(create: (context) => UnblockUserCubit(ChatRepository())),
        ],
        child: const BlockChatScreen(),
      ),
    );
  }

  @override
  State<BlockChatScreen> createState() => _BlockChatScreenState();
}

class _BlockChatScreenState extends State<BlockChatScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GetBlockedUsersCubit>().getBlockedUsers();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedSafeArea(
      isAnnotated: true,
      applyBottomInset: false,
      child: Scaffold(
        appBar: UiUtils.getSimpleAppBar(
          context: context,
          title: 'blockedProviders'.translate(context: context),
        ),
        body: BlocBuilder<GetBlockedUsersCubit, GetBlockedUsersState>(
          builder: (context, state) {
            if (state is GetBlockedUsersInProgress) {
              return const Center(child: CustomCircularProgressIndicator());
            }
            if (state is GetBlockedUsersFailure) {
              return ErrorContainer(
                errorMessage: state.errorMessage,
                showRetryButton: true,
                onTapRetry: () {
                  context.read<GetBlockedUsersCubit>().getBlockedUsers();
                },
                showErrorImage: true,
              );
            }
            if (state is GetBlockedUsersSuccess) {
              if (state.blockedProviders.isEmpty) {
                return Center(
                  child: NoDataFoundWidget(
                    titleKey: "noBlockedProviders".translate(context: context),
                    subtitleKey: 'noBlockedProvidersSubTitle'.translate(
                      context: context,
                    ),
                    showRetryButton: true,
                    onTapRetry: () {
                      context.read<GetBlockedUsersCubit>().getBlockedUsers();
                    },
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<GetBlockedUsersCubit>().getBlockedUsers();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16).copyWith(
                    bottom: 16 + MediaQuery.viewPaddingOf(context).bottom,
                  ),
                  itemCount: state.blockedProviders.length,
                  itemBuilder: (context, index) {
                    final user = state.blockedProviders[index];
                    return CustomContainer(
                      margin: const EdgeInsetsDirectional.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      borderRadius: UiUtils.borderRadiusOf12,
                      color: context.colors.surfacePrimary,
                      child: Row(
                        spacing: 12,
                        children: [
                          CustomContainer(
                            height: 40,
                            width: 40,
                            borderRadius: UiUtils.borderRadiusOf50,
                            image: user.image != null && user.image!.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(user.image!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            child: user.image == null || user.image!.isEmpty
                                ? Icon(
                                    Icons.person,
                                    color: context.colors.iconBrand,
                                  )
                                : null,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 4,
                              children: [
                                CustomText(
                                  user.translatedProviderName ?? 'Unknown User',
                                  color: context.colors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                if (user.translatedReason != null &&
                                    user.translatedReason!.isNotEmpty)
                                  CustomText(
                                    user.translatedReason!,
                                    color: context.colors.textSecondary,
                                    fontSize: 12,
                                  ),
                                if (user.additionalInfo != null &&
                                    user.additionalInfo!.isNotEmpty)
                                  CustomText(
                                    user.additionalInfo!,
                                    color: context.colors.textSecondary,
                                    fontSize: 12,
                                  ),
                              ],
                            ),
                          ),
                          CustomInkWellContainer(
                            onTap: () {
                              UiUtils.showBottomSheet(
                                context: context,
                                child: MultiBlocProvider(
                                  providers: [
                                    BlocProvider.value(
                                      value: context
                                          .read<GetBlockedUsersCubit>(),
                                    ),
                                    BlocProvider<UnblockUserCubit>(
                                      create: (context) =>
                                          UnblockUserCubit(ChatRepository()),
                                    ),
                                  ],
                                  child:
                                      BlocConsumer<
                                        UnblockUserCubit,
                                        UnblockUserState
                                      >(
                                        listener: (context, state) {
                                          if (state is UnblockUserSuccess) {
                                            // Remove user from the list locally
                                            context
                                                .read<GetBlockedUsersCubit>()
                                                .unblockUser(state.providerId);
                                            UiUtils.showMessage(
                                              context,
                                              state.message,
                                              ToastificationType.success,
                                            );
                                            Navigator.pop(context);
                                          }
                                          if (state is UnblockUserFailure) {
                                            UiUtils.showMessage(
                                              context,
                                              state.errorMessage,
                                              ToastificationType.error,
                                            );
                                            Navigator.pop(context);
                                          }
                                        },
                                        builder: (context, state) {
                                          return ConfirmActionBottomSheet(
                                            titleText: 'unblockUserTitle'
                                                .translate(context: context),
                                            questionText: 'unblockUserQuestion'
                                                .translate(context: context),
                                            descriptionText:
                                                'unblockUserWarning'.translate(
                                                  context: context,
                                                ),
                                            confirmButtonText: 'unblock'
                                                .translate(context: context),
                                            closeButtonText: 'close'.translate(
                                              context: context,
                                            ),
                                            isInProgress:
                                                state is UnblockUserInProgress,
                                            onTapClose: () {
                                              Navigator.pop(context);
                                            },
                                            onTapConfirm: () async {
                                              if (state
                                                  is UnblockUserInProgress) {
                                                return;
                                              }
                                              await context
                                                  .read<UnblockUserCubit>()
                                                  .unblockUser(user.id!);
                                            },
                                          );
                                        },
                                      ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(
                              UiUtils.borderRadiusOf12,
                            ),
                            child: CustomContainer(
                              color: context.colors.backgroundBrand,
                              borderRadius: UiUtils.borderRadiusOf12,
                              padding: const EdgeInsets.all(8),
                              child: CustomText(
                                'unblock'.translate(context: context),
                                color: context.colors.textInverseLight,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }
            return const CustomSizedBox();
          },
        ),
      ),
    );
  }
}
