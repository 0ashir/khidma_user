import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class BookMarkIcon extends StatefulWidget {
  const BookMarkIcon({
    required this.providerData,
    final Key? key,
    this.bookmarkedColor,
    this.unbookmarkedColor,
  }) : super(key: key);
  final Providers providerData;
  final Color? bookmarkedColor;
  final Color? unbookmarkedColor;

  @override
  State<BookMarkIcon> createState() => _BookMarkIconState();
}

class _BookMarkIconState extends State<BookMarkIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _scaleAnim = Tween<double>(begin: 0.78, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _opacityAnim = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startPulse() {
    if (!_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
  }

  void _stopPulse() {
    _pulseController.stop();
    _pulseController.reset();
  }

  Widget _buildIcon({
    required String svgImage,
    required Color color,
    final double? height,
    final double? width,
    required BuildContext context,
  }) => CustomSvgPicture(
    svgImage: svgImage,
    color: color,
    height: height,
    width: width,
    avoideResponsive: true,
  );

  @override
  Widget build(final BuildContext context) => BlocProvider(
    create: (final BuildContext context) => UpdateProviderBookmarkStatusCubit(),
    child: BlocBuilder<BookmarkCubit, BookmarkState>(
      bloc: context.read<BookmarkCubit>(),
      builder: (final BuildContext context, BookmarkState bookmarkState) {
        if (bookmarkState is BookmarkFetchSuccess) {
          final isBookmark = context.read<BookmarkCubit>().isPartnerBookmark(
            widget.providerData.providerId!,
          );

          return BlocConsumer<
            UpdateProviderBookmarkStatusCubit,
            UpdateProviderBookmarkStatusState
          >(
            bloc: context.read<UpdateProviderBookmarkStatusCubit>(),
            listener:
                (
                  final BuildContext context,
                  final UpdateProviderBookmarkStatusState state,
                ) {
                  if (state is UpdateProviderBookmarkStatusInProgress) {
                    _startPulse();
                  } else {
                    _stopPulse();
                  }
                  if (state is UpdateProviderBookmarkStatusFailure) {
                    UiUtils.showMessage(
                      context,
                      state.errorMessage,
                      ToastificationType.error,
                    );
                  }
                  if (state is UpdateProviderBookmarkStatusSuccess) {
                    UiUtils.showMessage(
                      context,
                      state.wasBookmarkProviderProcess
                          ? 'serviceBookmarkedSuccessfully'.translate(
                              context: context,
                            )
                          : 'serviceUnbookmarkedSuccessfully'.translate(
                              context: context,
                            ),
                      state.wasBookmarkProviderProcess
                          ? ToastificationType.success
                          : ToastificationType.warning,
                    );
                    UiUtils.getVibrationEffect();
                    if (state.wasBookmarkProviderProcess) {
                      context.read<BookmarkCubit>().addBookmark(state.provider);
                    } else {
                      context.read<BookmarkCubit>().removeBookmark(
                        widget.providerData.providerId!,
                      );
                    }
                  }
                },
            builder:
                (
                  final BuildContext context,
                  final UpdateProviderBookmarkStatusState state,
                ) {
                  final isLoading =
                      state is UpdateProviderBookmarkStatusInProgress;

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: isLoading
                        ? AnimatedBuilder(
                            key: const ValueKey('loading'),
                            animation: _pulseController,
                            builder: (context, _) => Transform.scale(
                              scale: _scaleAnim.value,
                              child: Opacity(
                                opacity: _opacityAnim.value,
                                child: _buildIcon(
                                  svgImage: isBookmark
                                      ? AppAssets.bookmarked
                                      : AppAssets.drFavorite,
                                  color: isBookmark
                                      ? (widget.bookmarkedColor ??
                                            context.colors.iconBrand)
                                      : (widget.unbookmarkedColor ??
                                            context.colors.iconPrimary),
                                  height: 24,
                                  width: 24,
                                  context: context,
                                ),
                              ),
                            ),
                          )
                        : CustomInkWellContainer(
                            key: const ValueKey('idle'),
                            onTap: () {
                              final authStatus = context
                                  .read<AuthenticationCubit>()
                                  .state;
                              if (authStatus is UnAuthenticatedState) {
                                UiUtils.showBottomSheet(
                                  context: context,
                                  enableDrag: true,
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  child: const LoginRequiredBottomSheet(),
                                );
                                return;
                              }
                              if (isBookmark) {
                                context
                                    .read<UpdateProviderBookmarkStatusCubit>()
                                    .unBookmarkProvider(
                                      context: context,
                                      providerId:
                                          widget.providerData.providerId,
                                      provider: widget.providerData,
                                    );
                              } else {
                                context
                                    .read<UpdateProviderBookmarkStatusCubit>()
                                    .bookmarkPartner(
                                      providerData: widget.providerData,
                                      context: context,
                                      providerId:
                                          widget.providerData.providerId!,
                                    );
                              }
                            },
                            child: CustomToolTip(
                              toolTipMessage: "bookmark".translate(
                                context: context,
                              ),
                              child: _buildIcon(
                                svgImage: isBookmark
                                    ? AppAssets.bookmarked
                                    : AppAssets.drFavorite,
                                color: isBookmark
                                    ? context.colors.iconBrand
                                    : context.colors.iconPrimary,
                                context: context,
                                height: 24,
                                width: 24,
                              ),
                            ),
                          ),
                  );
                },
          );
        }
        return CustomInkWellContainer(
          onTap: () {
            final authStatus = context.read<AuthenticationCubit>().state;
            if (authStatus is UnAuthenticatedState) {
              UiUtils.showBottomSheet(
                context: context,
                enableDrag: true,
                isScrollControlled: true,
                useSafeArea: true,
                child: const LoginRequiredBottomSheet(),
              );
              return;
            }
            context.read<UpdateProviderBookmarkStatusCubit>().bookmarkPartner(
              providerData: widget.providerData,
              context: context,
              providerId: widget.providerData.providerId!,
            );
          },
          child: CustomToolTip(
            toolTipMessage: "bookmark".translate(context: context),
            child: _buildIcon(
              svgImage: AppAssets.drFavorite,
              color: context.colors.iconPrimary,
              context: context,
              height: 24,
              width: 24,
            ),
          ),
        );
      },
    ),
  );
}
