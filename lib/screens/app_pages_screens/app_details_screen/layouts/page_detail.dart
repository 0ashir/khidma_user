import 'dart:developer';

import 'package:fixit_user/common_tap.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../../config.dart';

class PageDetail extends StatelessWidget {
  final PagesModel? page;

  const PageDetail({super.key, this.page});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leadingWidth: 80,
            title: Text(page!.title!,
                style:
                    appCss.dmDenseBold18.textColor(appColor(context).darkText)),
            centerTitle: true,
            leading: CommonArrow(
                    arrow: eSvgAssets.arrowLeft,
                    onTap: () => route.pop(context))
                .paddingDirectional(vertical: Insets.i8)),
        body: ListView(children: [
          Html(
            data: page!.content,
            onAnchorTap: (url, attributes, element) {
              if (url!.contains("mailto")) {
                mailTap(context, url.replaceAll("mailto:", ""));
              } else {
                commonUrlTap(context, url);
              }
            },
            onLinkTap: (url, attributes, element) {
              log("KKKK :$url");
            },
          )
        ]).paddingAll(Insets.i20));
  }
}
