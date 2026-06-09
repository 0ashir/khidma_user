import '../../../../config.dart';

class CarPlateLayout extends StatelessWidget {
  const CarPlateLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final value = Provider.of<SlotBookingProvider>(context);
    if (!value.isCarService || value.plateControllers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const VSpace(Sizes.s10),
        Text(
          language(context, value.plateControllers.length > 1
              ? translations!.carPlateNumbers!
              : translations!.carPlateNumber!),
          style: appCss.dmDenseMedium14.textColor(appColor(context).darkText),
        ).paddingSymmetric(horizontal: Insets.i20),
        const VSpace(Sizes.s10),
        ...value.plateControllers.asMap().entries.map((entry) {
          final i = entry.key;
          final ctrl = entry.value;
          return Padding(
            padding: const EdgeInsets.only(
                left: Insets.i20, right: Insets.i20, bottom: Insets.i10),
            child: TextFormField(
              controller: ctrl,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: language(context, translations!.carPlateHint!)
                    .replaceAll('{n}', '${i + 1}'),
                hintStyle:
                    appCss.dmDenseRegular14.textColor(appColor(context).lightText),
                prefixIcon: Icon(Icons.directions_car_outlined,
                    color: appColor(context).primary, size: 22),
                filled: true,
                fillColor: appColor(context).fieldCardBg,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: Insets.i15, vertical: Insets.i12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.r10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.r10),
                  borderSide: BorderSide(color: appColor(context).stroke),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.r10),
                  borderSide: BorderSide(color: appColor(context).primary),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
