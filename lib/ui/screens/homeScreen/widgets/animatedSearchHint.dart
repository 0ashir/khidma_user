import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

/// Rotating search placeholder text with slide-in / slide-out animation.
class AnimatedSearchHint extends StatefulWidget {
  const AnimatedSearchHint({super.key});

  @override
  State<AnimatedSearchHint> createState() => _AnimatedSearchHintState();
}

class _AnimatedSearchHintState extends State<AnimatedSearchHint>
    with SingleTickerProviderStateMixin {
  static const List<String> _searchValues = [
    "searchProviders",
    "searchServices",
    "searchElectronics",
    "searchHairCutting",
    "searchFanRepair",
  ];

  final ValueNotifier<int> _currentIndex = ValueNotifier(0);

  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2500),
  );

  late final Animation<double> _bottomToCenterTextAnimation =
      Tween<double>(begin: 1, end: 0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.25),
        ),
      );

  late final Animation<double> _centerToTopTextAnimation =
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.75, 1.0),
        ),
      );

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (_currentIndex.value != _searchValues.length - 1) {
        _currentIndex.value += 1;
      } else {
        _currentIndex.value = 0;
      }
      _animationController.forward(from: 0.0);
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _currentIndex.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => ValueListenableBuilder(
    valueListenable: _currentIndex,
    builder: (context, int searchValueIndex, _) {
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final dy =
              _bottomToCenterTextAnimation.value -
              _centerToTopTextAnimation.value;

          final opacity =
              1 -
              _bottomToCenterTextAnimation.value -
              _centerToTopTextAnimation.value;

          return CustomContainer(
            height: 48,
            alignment: Alignment(-1, dy),
            child: Opacity(
              opacity: opacity,
              child: CustomText(
                _searchValues[searchValueIndex].translate(context: context),
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
                fontSize: 14,
                maxLines: 1,
              ),
            ),
          );
        },
      );
    },
  );
}
