import 'package:fixit_user/providers/app_pages_providers/job_request_providers/add_job_request_provider.dart';
import 'package:fixit_user/screens/app_pages_screens/custom_job_request/add_job_request/layouts/service_image.dart';

import '../../../../../config.dart';
import 'add_new_box_layout.dart';
import 'add_service_image_layout.dart';

class FormServiceImageLayout extends StatelessWidget {
  const FormServiceImageLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final value = Provider.of<AddJobRequestProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ContainerWithTextLayout(
                title: language(context, translations!.chooseImages))
            .paddingOnly(top: Insets.i24, bottom: Insets.i12),
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              if (value.services != null &&
                  value.services!.media != null &&
                  value.services!.media!.isNotEmpty)
                ...value.services!.media!.asMap().entries.map((e) =>
                    AddServiceImageLayout(
                            networkImage: e.value.originalUrl!,
                            onDelete: () =>
                                value.onRemoveNetworkServiceImage(index: e.key))
                        .paddingOnly(right: Insets.i15)),
              if (appArray.serviceImageList.isNotEmpty)
                ...appArray.serviceImageList.asMap().entries.map((e) =>
                    AddServiceImageLayout(
                        image: e.value,
                        onDelete: () =>
                            value.onRemoveServiceImage(index: e.key))),
              if (appArray.serviceImageList.isNotEmpty)
                if (appArray.serviceImageList.length <= 4)
                  AddNewBoxLayout(
                      onAdd: () => value.onImagePick(context, false))
            ]).marginSymmetric(horizontal: Sizes.s20)),
        (appArray.serviceImageList.isEmpty)
            ? const ServiceImage(imageFile: null)
                .paddingSymmetric(horizontal: Insets.i20)
                .inkWell(onTap: () => value.onImagePick(context, false))
            : Container(),
        ContainerWithTextLayout(title: language(context, translations!.title))
            .paddingOnly(top: Insets.i24, bottom: Insets.i12),
        TextFieldCommon(
                focusNode: value.titleFocus,
                controller: value.title,
                hintText: translations!.enterTitle!,
                prefixIcon: eSvgAssets.jobTitle)
            .paddingSymmetric(horizontal: Insets.i20),
      ],
    );
  }
}
