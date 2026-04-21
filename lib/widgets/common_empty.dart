import '../config.dart';

class CommonEmpty extends StatelessWidget {
  final bool isButtonShow;
  final GestureTapCallback? bTap;
  const CommonEmpty({super.key, this.isButtonShow = false, this.bTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: EmptyLayout(
          title: translations!.noDataFound,
          isButtonShow: isButtonShow,
          buttonText: translations!.refresh,
          bTap: bTap,
          subtitle: translations!.noDataFoundDesc,
          widget: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Image.asset(eImageAssets.empty,
                      height: Sizes.s300, width: Sizes.s88)
                  .paddingOnly(bottom: Insets.i15, top: Insets.i25))),
    );
  }
}
