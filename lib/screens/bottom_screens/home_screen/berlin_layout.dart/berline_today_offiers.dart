
import 'package:fixit_user/config.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class BerlineTodayOffers extends StatelessWidget {
  const BerlineTodayOffers({super.key});

  @override
  Widget build(BuildContext context) {
    final commonApi = Provider.of<CommonApiProvider>(context, listen: false);

    // Initialize controllers only once
    if (commonApi.videoControllers.isEmpty) {
      commonApi.initializeVideoControllers(commonApi.videoUrls);
    }

    return Consumer<CommonApiProvider>(builder: (context, commonApi, child) {
      return commonApi.dashboardModel2?.homeBannerAdvertisements?.isEmpty ??
              true
          ? const SizedBox()
          : Column(
              children: [
                HeadingRowCommon(
                  title: language(context, translations!.specialOffers),
                  isTextSize: true,
                  isViewAll: false,
                  onTap: () {},
                ).padding(bottom: Sizes.s16),
                SizedBox(
                  height: Sizes.s140,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: commonApi.mediaUrls.length +
                          commonApi.videoUrls.length,
                      itemBuilder: (context, index) {
                        if (index < commonApi.mediaUrls.length) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(Sizes.s9),
                            child: CachedNetworkImage(
                              width: 320,
                              imageUrl: commonApi.mediaUrls[index],
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) =>
                                  Image.asset(eImageAssets.noImageFound2),
                              errorWidget: (context, url, error) =>
                                  Image.asset(eImageAssets.noImageFound2),
                            ),
                          ).padding(right: Sizes.s10);
                        } else {
                          int videoIndex = index - commonApi.mediaUrls.length;
                          YoutubePlayerController videoController =
                              commonApi.videoControllers[videoIndex];

                          return SizedBox(
                            width: 290,
                            child: GestureDetector(
                              onTap: () {
                                if (!videoController.value.isPlaying) {
                                  videoController.play();
                                } else {
                                  videoController.pause();
                                }
                              },
                              child: AbsorbPointer(
                                absorbing: !videoController.value
                                    .isPlaying, // ✅ Allows scrolling when video is not playing
                                child: YoutubePlayerBuilder(
                                  player: YoutubePlayer(
                                    controller: videoController,
                                    showVideoProgressIndicator: true,
                                  ),
                                  builder: (context, player) {
                                    return player;
                                  },
                                ),
                              ),
                            ),
                          ).padding(right: Sizes.s10);
                        }
                      }),
                )
              ],
            ).paddingSymmetric(horizontal: Insets.i20);
    });
  }
}
