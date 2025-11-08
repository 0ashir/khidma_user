import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class ReviewDetails extends StatelessWidget {
  const ReviewDetails({required this.reviews, final Key? key})
      : super(key: key);
  final Reviews reviews;

  @override
  Widget build(final BuildContext context) {
    final time1 = DateTime.parse(reviews.ratedOn!);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomText(
            reviews.serviceName!,
            color: context.colorScheme.blackColor,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.normal,
            fontSize: 14,
            textAlign: TextAlign.left,
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 5),
            child: Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf50),
                  child: CustomCachedNetworkImage(
                    networkImageUrl: reviews.profileImage!,
                    fit: BoxFit.fill,
                    width: 50,
                    height: 50,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CustomText(
                        reviews.userName!,
                        color: context.colorScheme.blackColor,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        fontSize: 14,
                        textAlign: TextAlign.left,
                      ),
                      if (reviews.comment!.isNotEmpty) ...[
                        CustomReadMoreTextContainer(
                          text: reviews.comment!,
                          textStyle: TextStyle(
                            color: context.colorScheme.lightGreyColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          const CustomSvgPicture(
                            svgImage: AppAssets.icStar,
                            height: 16,
                            width: 16,
                            color: AppColors.ratingStarColor,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: CustomText(
                              double.parse(reviews.rating!).toStringAsFixed(1),
                              fontWeight: FontWeight.w700,
                              color: context.colorScheme.blackColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      CustomText(
                        time1.toString().convertToAgo(context: context),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: context.colorScheme.lightGreyColor,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (reviews.images!.isNotEmpty) ...[
            const SizedBox(
              height: 10,
            ),
            SingleChildScrollView(
              // padding: const EdgeInsets.symmetric(horizontal: 15),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  reviews.images!.length,
                  (final index) => CustomInkWellContainer(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        imagePreview,
                        arguments: {
                          "startFrom": index,
                          "reviewDetails": reviews,
                          "isReviewType": true,
                          "dataURL": reviews.images
                        },
                      );
                    },
                    child: CustomContainer(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(UiUtils.borderRadiusOf10),
                        child: CustomCachedNetworkImage(
                          networkImageUrl: reviews.images![index],
                          width: 60,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
