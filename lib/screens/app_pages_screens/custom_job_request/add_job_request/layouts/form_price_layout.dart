import 'package:fixit_user/providers/app_pages_providers/job_request_providers/add_job_request_provider.dart';

import '../../../../../config.dart';
import 'category_selection.dart';

class FormPriceLayout extends StatelessWidget {
  const FormPriceLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AddJobRequestProvider>(builder: (context1, value, child) {
      return Column(children: [
        ContainerWithTextLayout(title: language(context, translations!.price))
            .paddingOnly(top: Insets.i24, bottom: Insets.i12),
        TextFieldCommon(
                keyboardType: TextInputType.number,
                focusNode: value.amountFocus,
                controller: value.amount,
                hintText: translations!.enterAmt!,
                prefixIcon: eSvgAssets.dollar)
            .padding(horizontal: Insets.i20),
        ContainerWithTextLayout(
                title: language(context, translations!.categories))
            .paddingOnly(top: Insets.i24, bottom: Insets.i12),
        const CategorySelectionLayout(),
      ]);
    });
  }
}
