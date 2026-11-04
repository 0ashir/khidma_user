import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class ServiceBookmarkIcon extends StatefulWidget {
  const ServiceBookmarkIcon({
    required this.serviceId,
    required this.isBookmarked,
    super.key,
    this.onChanged,
  });

  final String serviceId;
  final bool isBookmarked;
  final ValueChanged<bool>? onChanged;

  @override
  State<ServiceBookmarkIcon> createState() => _ServiceBookmarkIconState();
}

class _ServiceBookmarkIconState extends State<ServiceBookmarkIcon>
    with SingleTickerProviderStateMixin {
  late bool _isBookmarked = widget.isBookmarked;
  bool _isLoading = false;

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

  @override
  void didUpdateWidget(final ServiceBookmarkIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isBookmarked != widget.isBookmarked) {
      _isBookmarked = widget.isBookmarked;
    }
  }

  Future<void> _toggle() async {
    final authStatus = context.read<AuthenticationCubit>().state;
    if (authStatus is UnAuthenticatedState) {
      await UiUtils.showBottomSheet(
        context: context,
        enableDrag: true,
        isScrollControlled: true,
        useSafeArea: true,
        child: const LoginRequiredBottomSheet(),
      );
      return;
    }
    final bool wasBookmarked = _isBookmarked;
    setState(() {
      _isBookmarked = !wasBookmarked;
      _isLoading = true;
    });
    _startPulse();
    try {
      final BookmarkRepository repository = BookmarkRepository();
      if (wasBookmarked) {
        await repository.removeBookmark(
          isAuthTokenRequired: true,
          serviceId: widget.serviceId,
          context: context,
        );
      } else {
        await repository.addBookmark(
          isAuthTokenRequired: true,
          serviceId: widget.serviceId,
          context: context,
        );
      }
      if (!mounted) return;
      _stopPulse();
      setState(() => _isLoading = false);
      widget.onChanged?.call(_isBookmarked);
      UiUtils.showMessage(
        context,
        wasBookmarked
            ? 'serviceUnbookmarkedSuccessfully'.translate(context: context)
            : 'serviceBookmarkedSuccessfully'.translate(context: context),
        wasBookmarked ? ToastificationType.warning : ToastificationType.success,
      );
    } catch (e) {
      if (!mounted) return;
      _stopPulse();
      setState(() {
        _isBookmarked = wasBookmarked;
        _isLoading = false;
      });
      UiUtils.showMessage(context, e.toString(), ToastificationType.error);
    }
  }

  Widget _buildIcon() => CustomSvgPicture(
    svgImage: _isBookmarked ? AppAssets.bookmarked : AppAssets.drFavorite,
    height: 24,
    width: 24,
    color: _isBookmarked
        ? context.colors.iconBrand
        : context.colors.iconPrimary,
    avoideResponsive: true,
  );

  @override
  Widget build(final BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 200),
    switchInCurve: Curves.easeOut,
    switchOutCurve: Curves.easeIn,
    transitionBuilder: (child, animation) => ScaleTransition(
      scale: animation,
      child: FadeTransition(opacity: animation, child: child),
    ),
    child: _isLoading
        ? AnimatedBuilder(
            key: const ValueKey('loading'),
            animation: _pulseController,
            builder: (context, _) => Transform.scale(
              scale: _scaleAnim.value,
              child: Opacity(opacity: _opacityAnim.value, child: _buildIcon()),
            ),
          )
        : CustomInkWellContainer(
            key: const ValueKey('idle'),
            onTap: _toggle,
            child: _buildIcon(),
          ),
  );
}
