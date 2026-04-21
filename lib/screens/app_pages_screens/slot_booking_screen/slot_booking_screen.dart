import 'package:fixit_user/screens/app_pages_screens/slot_booking_screen/layouts/step_one_layout.dart';
import 'package:fixit_user/screens/app_pages_screens/slot_booking_screen/layouts/step_two_layout.dart';

import '../../../config.dart';

class SlotBookingScreen extends StatefulWidget {
  const SlotBookingScreen({super.key});

  @override
  State<SlotBookingScreen> createState() => _SlotBookingScreenState();
}

class _SlotBookingScreenState extends State<SlotBookingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Map? argData =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      Provider.of<SlotBookingProvider>(context, listen: false)
          .onReady(context, argData: argData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(builder: (context1, locationCtrl, child) {
      return Consumer<SlotBookingProvider>(builder: (context2, value, child) {
        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            value.onBack(context);
          },
          child: Scaffold(
              appBar: AppBarCommon(
                title:
                    "${language(context, translations!.step)} ${value.isStep2 == false ? "1" : "2"}",
                onTap: () => value.onBack(context),
              ),
              body: value.isStep2 == false
                  ? const StepOneLayout()
                  : const StepTwoLayout()),
        );
      });
    });
  }
}
