import 'dart:developer';

import 'package:fixit_user/config.dart';
import 'package:fixit_user/providers/app_pages_providers/job_request_providers/add_job_request_provider.dart';

import 'layouts/form_category_layout.dart';
import 'layouts/form_price_layout.dart';
import 'layouts/form_service_image_layout.dart';

class AddJobRequest extends StatelessWidget {
  const AddJobRequest({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AddJobRequestProvider>(builder: (context1, value, child) {
      return StatefulWrapper(
        onInit: () => Future.delayed(
            const Duration(milliseconds: 20), () => value.onReady(context)),
        child: PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            log("DDDD :$didPop  || $result");
            value.onBack(false);
          },
          //onPopInvoked: (bool? didPop) => value.onBack(false),
          child: Scaffold(
              appBar: AppBarCommon(
                  title: translations!.postNewJobRequestTitle,
                  onTap: () => route.pop(context)),
              bottomNavigationBar: ButtonCommon(
                      isLoading: value.isAddJobRquest,
                      title: translations!.post!,
                      onTap: value.isAddJobRquest
                          ? () {}
                          : () => value.addData(context))
                  .paddingDirectional(
                      horizontal: Sizes.s20, vertical: Sizes.s20),
              body: SingleChildScrollView(
                  child: Column(children: [
                Stack(children: [
                  const FieldsBackground(),
                  Form(
                    key: value.addServiceFormKey,
                    child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FormServiceImageLayout(),
                          FormCategoryLayout(),
                          FormPriceLayout()
                        ]).paddingSymmetric(vertical: Insets.i20),
                  )
                ]).padding(bottom: Sizes.s20),
                // Container(
                //   width: MediaQuery.of(context).size.width,
                //   height: 50,
                //   decoration: ShapeDecoration(
                //       color: appColor(context).primary,
                //       shape: SmoothRectangleBorder(
                //           borderRadius: SmoothBorderRadius(
                //               cornerRadius: AppRadius.r8, cornerSmoothing: 1))),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       value.isAddJobRquest
                //           ? const CircularProgressIndicator(color: Colors.white)
                //               .center()
                //               .padding(vertical: Sizes.s5)
                //           : Text(language(context, translations!.post),
                //               textAlign: TextAlign.center,
                //               overflow: TextOverflow.ellipsis,
                //               style: appCss.dmDenseRegular16
                //                   .textColor(appColor(context).whiteColor)),
                //     ],
                //   ),
                // ).inkWell(
                //     onTap: value.isAddJobRquest
                //         ? () {}
                //         : () => value.addData(context))
                /*  ButtonCommon(
                        title: translations!.post,
                        onTap: () => value.addData(context))
                    .paddingOnly(top: Insets.i40, bottom: Insets.i30) */
              ]).paddingSymmetric(horizontal: Insets.i20))),
        ),
      );
    });
  }
}
