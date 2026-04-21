import 'dart:developer';

import 'package:fixit_user/config.dart';

class FilterDropdown extends StatefulWidget {
  const FilterDropdown({super.key});

  @override
  State<FilterDropdown> createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<FilterDropdown> {
  @override
  @override
  Widget build(BuildContext context) {
    final dash = Provider.of<DashboardProvider>(context, listen: false);
    return Consumer<BookingProvider>(builder: (context, value, child) {
      return Container(
          width: Sizes.s150,
          decoration: ShapeDecoration(
              color: appColor(context).fieldCardBg,
              shape: SmoothRectangleBorder(
                  borderRadius:
                      SmoothBorderRadius(cornerRadius: 8, cornerSmoothing: 1))),
          child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                  value: value.selectedValue,
                  isExpanded: false,
                  items: value.options.map((String value) {
                    return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value,
                                style: appCss.dmDenseMedium15
                                    .textColor(appColor(context).darkText))
                            .padding(horizontal: Insets.i12));
                  }).toList(),
                  onChanged: (String? newValue) {
                    log("message selected filter $newValue");
                    setState(() {
                      value.selectedValue = newValue!;
                      dash.isLoadingForBookingHistory = true;
                      value.isLoadingForBookingHistory = true;
                    });
                    value.isLoadingForBookingHistory = true;
                    dash.getBookingHistory(context,
                        timeFilter: value.selectedValue);
                  })));
    });
  }
}
