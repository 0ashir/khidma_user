// import '../../../config.dart';

// class ChangeLanguageScreen extends StatelessWidget {
//   const ChangeLanguageScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<LanguageProvider>(builder: (context1, languageCtrl, child) {
//       return LoadingComponent(
//         child: Scaffold(
//             appBar: AppBar(
//               elevation: 0,
//               centerTitle: true,
//               leadingWidth: 80,
//               leading: SvgPicture.asset(
//                 languageCtrl.getLocal() == "ar"
//                     ? eSvgAssets.arrowRight
//                     : eSvgAssets.arrowLeft1,
//                 colorFilter: ColorFilter.mode(
//                     appColor(context).darkText, BlendMode.srcIn),
//               )
//                   .paddingAll(Insets.i10)
//                   .decorated(
//                       shape: BoxShape.circle,
//                       color: appColor(context).fieldCardBg)
//                   .inkWell(onTap: () => route.pop(context))
//                   .paddingAll(Insets.i8),
//               title: Text(
//                 language(context, translations!.changeLanguage),
//                 style:
//                     appCss.dmDenseBold18.textColor(appColor(context).darkText),
//               ),
//             ),
//             body: Container(
//                 margin: const EdgeInsets.symmetric(
//                     horizontal: Insets.i15, vertical: Insets.i25),
//                 decoration: BoxDecoration(
//                     color: appColor(context).whiteBg,
//                     border: Border.all(color: appColor(context).fieldCardBg),
//                     borderRadius: BorderRadius.circular(AppRadius.r12),
//                     boxShadow: [
//                       BoxShadow(
//                           color: appColor(context).fieldCardBg,
//                           spreadRadius: 2,
//                           blurRadius: 4)
//                     ]),
//                 child: SafeArea(
//                     child: SingleChildScrollView(
//                         child: Column(children: [
//                   ...languageCtrl.languageList.asMap().entries.map((e) {
//                     return Column(children: [
//                       Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(children: [
//                               Container(
//                                 height: Sizes.s40,
//                                 width: Sizes.s40,
//                                 decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     image: DecorationImage(
//                                         image: NetworkImage(
//                                             e.value.flag.toString()))),
//                               ),
//                               const HSpace(Sizes.s12),
//                               Text(language(context, e.value.name.toString()),
//                                   style: appCss.dmDenseRegular14
//                                       .textColor(appColor(context).darkText))
//                             ]),
//                             languageCtrl.getLocal() == e.value.locale
//                                 ? Container(
//                                     width: 22,
//                                     height: 22,
//                                     decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: const Color(0xff5465FF)
//                                             .withOpacity(0.18)),
//                                     child: const Icon(Icons.circle,
//                                         color: Color(0xff5465FF), size: 13))
//                                 : Container(
//                                     width: 22,
//                                     height: 22,
//                                     decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         border: Border.all(
//                                             color: const Color(0xffE5E8EA))))
//                           ]).paddingSymmetric(vertical: Insets.i12),
//                       Divider(color: appColor(context).fieldCardBg, height: 0)
//                     ])
//                         .paddingSymmetric(horizontal: Insets.i15)
//                         .width(MediaQuery.of(context).size.width)
//                         .inkWell(
//                             onTap: () => languageCtrl.changeLocale(e.value));
//                   })
//                 ]))))),
//       );
//     });
//   }
// }
