
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../config.dart';

class ServiceImageLayout extends StatelessWidget {
  final String? image, rating, title;
  final GestureTapCallback? favTap, removeTap;

  // final bool? isFav;
  final bool isJobRequest;
  final GestureTapCallback? onBack, editTap;
  final data;

  const ServiceImageLayout(
      {super.key,
      this.rating,
      this.image,
      this.favTap,
      this.removeTap,
      this.title,
      // this.isFav,
      this.editTap,
      this.onBack,
      this.isJobRequest = false,
      this.data});

  @override
  Widget build(BuildContext context) {
    final sevrviceDetails =
        Provider.of<ServicesDetailsProvider>(context, listen: false);

    YoutubePlayerController? playerController = YoutubePlayerController(
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
        initialVideoId: YoutubePlayer.convertUrlToId(
                sevrviceDetails.service?.video ?? "") ??
            '');
    return Consumer<ServicesDetailsProvider>(builder: (context, value, child) {
      return Stack(children: [
        value.isVideo == true
            ? SizedBox(
                height: Sizes.s230,
                child: GestureDetector(
                  onTap: () {
                    print("object=-=-=-=-=-=-=-=-=-");
                    if (playerController.value.isPlaying) {
                      playerController.play();
                    } else {
                      playerController.pause();
                    }
                  },
                  child: AbsorbPointer(
                    absorbing: playerController.value.isPlaying,
                    child: YoutubePlayerBuilder(
                      player: YoutubePlayer(
                        controller:
                            playerController /* YoutubePlayerController(
                          flags: const YoutubePlayerFlags(
                            autoPlay: true,
                            mute: false,
                            disableDragSeek: true,
                          ),
                          initialVideoId: YoutubePlayer.convertUrlToId(
                                  value.services?.video ?? "") ??
                              '') */
                        ,
                        showVideoProgressIndicator: true,
                      ),
                      /*  YoutubePlayer(
                      controller: YoutubePlayerController(
                        initialVideoId: YoutubePlayer.convertUrlToId(
                                value.services?.video ?? "") ??
                            '',
                        flags: const YoutubePlayerFlags(
                          autoPlay: true,
                          mute: false,
                        ),
                      ),
                      // showVideoProgressIndicator: true,
                    ), */
                      builder: (context, player) {
                        return player;
                      },
                    ),
                  ),
                )).inkWell(onTap: () {
                print("object=-=-=-=-=-=-=-=-=-=-=-");
                if (playerController.value.isPlaying) {
                  playerController.play();
                } else {
                  playerController.pause();
                }
                /*  if (value.videoControllers!.value.isPlaying) {
                  value.videoControllers?.play();
                } else {
                  value.videoControllers?.pause();
                } */
              })
            : CachedNetworkImage(
                imageUrl: image!,
                imageBuilder: (context, imageProvider) => Container(
                    width: MediaQuery.of(context).size.width,
                    height: Sizes.s230,
                    decoration: ShapeDecoration(
                        image: DecorationImage(
                            image: NetworkImage(image!), fit: BoxFit.cover),
                        shadows: [
                          BoxShadow(
                              color:
                                  appColor(context).darkText.withOpacity(0.2),
                              blurRadius: 8,
                              spreadRadius: 3)
                        ],
                        shape: const SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius.only(
                                bottomRight: SmoothRadius(
                                    cornerRadius: AppRadius.r20,
                                    cornerSmoothing: 1),
                                bottomLeft: SmoothRadius(
                                    cornerRadius: AppRadius.r20,
                                    cornerSmoothing: 1))))),
                placeholder: (context, url) => Container(
                    width: MediaQuery.of(context).size.width,
                    height: Sizes.s230,
                    decoration: ShapeDecoration(
                        shadows: [
                          BoxShadow(
                              color:
                                  appColor(context).darkText.withOpacity(0.2),
                              blurRadius: 8,
                              spreadRadius: 3)
                        ],
                        image: DecorationImage(
                            image: AssetImage(eImageAssets.noImageFound2),
                            fit: BoxFit.cover),
                        shape: const SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius.only(
                                bottomRight: SmoothRadius(
                                    cornerRadius: AppRadius.r20,
                                    cornerSmoothing: 1),
                                bottomLeft: SmoothRadius(
                                    cornerRadius: AppRadius.r20,
                                    cornerSmoothing: 1))))),
                errorWidget: (context, url, error) => Container(
                    width: MediaQuery.of(context).size.width,
                    height: Sizes.s230,
                    decoration: ShapeDecoration(
                        shadows: [
                          BoxShadow(
                              color:
                                  appColor(context).darkText.withOpacity(0.2),
                              blurRadius: 8,
                              spreadRadius: 3)
                        ],
                        image: DecorationImage(
                            image: AssetImage(eImageAssets.noImageFound2),
                            fit: BoxFit.cover),
                        shape: const SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius.only(
                                bottomRight: SmoothRadius(
                                    cornerRadius: AppRadius.r20,
                                    cornerSmoothing: 1),
                                bottomLeft: SmoothRadius(
                                    cornerRadius: AppRadius.r20,
                                    cornerSmoothing: 1))))),
              ),
        if (value.isVideo != true)
          SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: Sizes.s230,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CommonArrow(
                                  arrow: eSvgAssets.arrowLeft, onTap: onBack),
                              isJobRequest
                                  ? const SizedBox() /* CommonArrow(
                                  arrow: eSvgAssets.edit, onTap: editTap) */
                                  : /*  value.provider != null
                                  ? value.provider?.isFavourite == 1
                                  ? SvgPicture.asset(eSvgAssets.heart)
                                  .inkWell(
                                  onTap: () => {
                                    value.provider?.isFavourite = 0,
                                    favCtrl.deleteFav(
                                        context,value:value,
                                        isFavId: value.provider!.isFavouriteId,id:value.provider?.id),
                                  })
                                  .paddingOnly(right: Insets.i20)
                                  : CommonArrow(
                                  arrow: eSvgAssets.like,
                                  svgColor: appColor(context).primary,
                                  color: appColor(context)
                                      .primary
                                      .withValues(alpha: 0.15),
                                  onTap: () =>
                                  {
                                    value.provider?.isFavourite = 1,
                                    favCtrl.addFav("provider", context, value.provider!.id)
                                  })
                                  .paddingOnly(right: Insets.i20)
                                  : Container()*/

                                  data.isFavourite == 1
                                      ? SvgPicture.asset(eSvgAssets.heart,
                                              height: Sizes.s40,
                                              width: Sizes.s40)
                                          .inkWell(onTap: removeTap)
                                      : CommonArrow(
                                          arrow: eSvgAssets.like, onTap: favTap)
                            ]),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(title!,
                                    style: appCss.dmDenseSemiBold18.textColor(
                                        appColor(context).whiteColor)),
                              ),
                              if (rating != null)
                                Row(children: [
                                  SvgPicture.asset(eSvgAssets.star),
                                  const HSpace(Sizes.s4),
                                  Text(rating!,
                                      style: appCss.dmDenseMedium13.textColor(
                                          appColor(context).whiteColor))
                                ])
                            ])
                      ]).padding(
                      horizontal: Insets.i20,
                      top: Insets.i20,
                      bottom: Insets.i20))
              .decorated(
                  borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(AppRadius.r20),
                      right: Radius.circular(AppRadius.r20)),
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        appColor(context).trans,
                        appColor(context).darkText.withOpacity(0.3)
                      ]))
      ]);
    });
  }
}
