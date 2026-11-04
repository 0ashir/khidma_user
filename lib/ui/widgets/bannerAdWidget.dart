import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class BannerAdWidget extends StatefulWidget {
  /// Pads the ad by the bottom system inset (only while an ad is visible).
  final bool applyBottomInset;

  const BannerAdWidget({super.key, this.applyBottomInset = false});

  @override
  _BannerAdContainer createState() => _BannerAdContainer();
}

class _BannerAdContainer extends State<BannerAdWidget> {
  BannerAd? _googleBannerAd;

  @override
  void initState() {
    super.initState();
    _initBannerAd();
  }

  @override
  void dispose() {
    _googleBannerAd?.dispose();

    super.dispose();
  }

  void _initBannerAd() {
    Future.delayed(Duration.zero, () {
      final systemConfigCubit = context.read<SystemSettingCubit>();
      if (systemConfigCubit.isAdEnabled) {
        _createGoogleBannerAd();
      }
    });
  }

  Future<void> _createGoogleBannerAd() async {
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getLargeAnchoredAdaptiveBannerAdSize(
          MediaQuery.sizeOf(context).width.truncate(),
        );

    if (size == null) {
      return;
    }

    final BannerAd banner = BannerAd(
      request: const AdRequest(),
      adUnitId: context.read<SystemSettingCubit>().BannerAdId,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _googleBannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {},
      ),
      size: size,
    );
    banner.load();
  }

  @override
  Widget build(BuildContext context) {
    final sysConfig = context.read<SystemSettingCubit>();
    if (sysConfig.isAdEnabled) {
      if (_googleBannerAd == null) return const SizedBox.shrink();
      final Widget ad = CustomSizedBox(
        width: context.screenWidth,
        height: _googleBannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _googleBannerAd!),
      );
      return widget.applyBottomInset
          ? Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewPaddingOf(context).bottom,
              ),
              child: ad,
            )
          : ad;
    }
    return const SizedBox.shrink();
  }
}
