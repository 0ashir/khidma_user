import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/ui/widgets/bottomsheets/layouts/promocodeDetailsBottomsheet.dart';
import 'package:flutter/material.dart';

class SliderPromocode extends StatefulWidget {
  final List<Promocode> promocode;
  final double calculatedWidth;
  final double height;

  const SliderPromocode({
    Key? key,
    required this.promocode,
    required this.calculatedWidth,
    required this.height,
  }) : super(key: key);

  @override
  State<SliderPromocode> createState() => _SliderPromocodeState();
}

class _SliderPromocodeState extends State<SliderPromocode> {
  int currentSliderImage = 0;

  Timer? timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.centerRight,
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: widget.height,
                viewportFraction: 1,
                initialPage: 0,
                enableInfiniteScroll: widget.promocode.length > 1,
                reverse: false,
                autoPlay: widget.promocode.length > 1,
                autoPlayInterval:
                    sliderAnimationDurationSettings.sliderAnimationDuration,
                autoPlayAnimationDuration: sliderAnimationDurationSettings
                    .changeSliderAnimationDuration,
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: false,
                pauseAutoPlayOnTouch: false,
                enlargeFactor: 1,
                aspectRatio: 1,
                scrollDirection: Axis.horizontal,
                onPageChanged: (index, reason) {
                  setState(() {
                    currentSliderImage = index;
                  });
                },
              ),
              items: List.generate(widget.promocode.length, (index) {
                final Promocode promocode = widget.promocode[index];
                return SingleSliderImageWidget(
                  height: widget.height,
                  promocode: promocode,
                  calculatedWidth: widget.calculatedWidth,
                );
              }),
            ),
            if (widget.promocode.length > 1)
              CustomContainer(
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: context.colors.backgroundSecondary,
                borderRadius: UiUtils.borderRadiusOf8,
                child: CustomText(
                  '${currentSliderImage + 1}/${widget.promocode.length}',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textPrimary,
                ),
              ),
          ],
        ),
        if (widget.promocode.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.promocode.length,
              (index) => getIndicator(index: index),
            ),
          ),
      ],
    );
  }

  Widget getIndicator({required int index}) {
    final bool isActive = currentSliderImage == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: isActive ? const EdgeInsets.all(1) : EdgeInsets.zero,
      decoration: isActive
          ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: context.colors.borderBrand, width: 0.5),
            )
          : null,
      child: Container(
        width: isActive ? 6 : 8,
        height: isActive ? 6 : 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? context.colors.backgroundBrand
              : context.colors.iconDisabled,
        ),
      ),
    );
  }
}

class SingleSliderImageWidget extends StatelessWidget {
  const SingleSliderImageWidget({
    required this.promocode,
    required this.calculatedWidth,
    super.key,
    required this.height,
  });

  final Promocode promocode;
  final double calculatedWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bool hasDiscount = (promocode.discount ?? '').isNotEmpty;
    final String discountSuffix = promocode.discountType == "percentage"
        ? '%'
        : promocode.discountType == "amount"
        ? context.read<SystemSettingCubit>().systemCurrency
        : (promocode.discountType ?? '');
    return CustomInkWellContainer(
      onTap: () {
        UiUtils.showBottomSheet(
          context: context,
          child: Wrap(
            children: [
              PromocodeDetailsBottomSheet(promocodeDetails: promocode),
            ],
          ),
        );
      },
      child: SizedBox(
        height: height,
        width: calculatedWidth,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5.5),
              child: CustomCachedNetworkImage(
                networkImageUrl: promocode.image ?? '',
                height: 36,
                width: 36,
                fit: BoxFit.cover,
              ),
            ),
            const CustomSizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasDiscount)
                    CustomText(
                      '${promocode.discount}$discountSuffix ${"off".translate(context: context)}',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      maxLines: 1,
                      color: context.colors.textPrimary,
                    )
                  else
                    CustomText(
                      promocode.message ?? '',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      maxLines: 1,
                      color: context.colors.textPrimary,
                    ),
                  if ((promocode.minimumOrderAmount ?? '').isNotEmpty)
                    CustomText(
                      '${"onMinimumServiceOf".translate(context: context)} ${promocode.minimumOrderAmount!.priceFormat(context)}',
                      fontSize: 12,
                      maxLines: 2,
                      color: context.colors.textTertiary,
                    ),
                ],
              ),
            ),
            const CustomSizedBox(width: 44),
          ],
        ),
      ),
    );
  }
}
