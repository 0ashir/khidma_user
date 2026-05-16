import 'dart:convert';
import 'dart:developer';
import 'package:collection/collection.dart';
import 'package:fixit_user/models/step2model.dart';
import 'package:fixit_user/screens/app_pages_screens/slot_booking_screen/layouts/date_range_picker_layout.dart';
import 'package:fixit_user/screens/app_pages_screens/slot_booking_screen/layouts/week_bottom_sheet.dart';
import 'package:fixit_user/screens/app_pages_screens/slot_booking_screen/layouts/custom_date_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../config.dart';
import '../../models/time_slot_model.dart';
import '../../screens/app_pages_screens/slot_booking_screen/layouts/provider_time_slot_layout.dart';
import '../../screens/app_pages_screens/slot_booking_screen/layouts/year_dialog.dart';
import '../../utils/date_time_picker.dart';

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

class SlotBookingProvider with ChangeNotifier {
  Services? servicesCart;
  int selectIndex = 1;
  bool isStep2 = false, isPackage = false, isBottom = true;
  PrimaryAddress? address;
  int selectProviderIndex = 0;
  List timeSlot = [];
  List newTimeSlot = [];
  int demoInt = 0;
  dynamic chosenValue;
  DateTime? selectedDay;
  DateTime selectedYear = DateTime.now();
  DateTime currentDate = DateTime.now();
  List<String> newWeekDayList = [];
//ServicesDetailsProvider
  TextEditingController startDateCtrl = TextEditingController();
  TextEditingController endDateCtrl = TextEditingController();
  ScrollController scrollController = ScrollController();
  final ValueNotifier<DateTime> focusedDay = ValueNotifier(DateTime.now());
  dynamic slotChosenValue, slotTime;
  DateTime? slotSelectedDay;
  DateTime slotSelectedYear = DateTime.now();
  RangeSelectionMode rangeSelectionMode = RangeSelectionMode
      .toggledOn; // Can be toggled on/off by longpressing a date
  DateTime? rangeStart;
  DateTime? rangeEnd;
  List<DateTime> selectedDateList = [];
  List<DateTime> customSelectedDates = []; // For custom frequency

  int selectedIndex = 0;
  int scrollDayIndex = 0;
  int scrollMinIndex = 0;
  int scrollHourIndex = 0;
  String? bookingFrequency;
  String showYear = 'Select Year';
  TimeSlotModel? timeSlotModel;
  PageController pageController = PageController();
  CalendarFormat calendarFormat = CalendarFormat.week;
  CalendarFormat calendarFormatMonth = CalendarFormat.month;
  CarouselSliderController carouselController = CarouselSliderController();
  CarouselSliderController carouselController1 = CarouselSliderController();
  CarouselSliderController carouselController2 = CarouselSliderController();
  final ValueNotifier<DateTime> focuseDay = ValueNotifier(DateTime.now());
  final FocusNode noteFocus = FocusNode();
  final FocusNode startDateFocus = FocusNode();
  final FocusNode endDateFocus = FocusNode();
  bool visible = true;
  int val = 1;
  double loginWidth = 100.0;
  TextEditingController txtNote = TextEditingController();
  int? amIndex;

  int? timeIndex;
  bool isVisible = false;

  bool isPositionedRight = false;
  bool isAnimateOver = false;
  AnimationController? controller;
  Animation<Offset>? offsetAnimation;

  @override
  void dispose() {
    scrollController.dispose();
    pageController.dispose();
    noteFocus.dispose();
    txtNote.clear();
    controller?.dispose();
    super.dispose();
  }

  onChangeWeekDay(String day) {
    if (!newWeekDayList.contains(day)) {
      newWeekDayList.add(day);
    } else {
      newWeekDayList.remove(day);
    }
    calculateSelectedDays();
    notifyListeners();
  }

  // Custom date selection methods
  onCustomDateToggle(DateTime date) {
    // Normalize date to remove time component
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final index = customSelectedDates.indexWhere((d) =>
        d.year == normalizedDate.year &&
        d.month == normalizedDate.month &&
        d.day == normalizedDate.day);

    if (index >= 0) {
      customSelectedDates.removeAt(index);
    } else {
      customSelectedDates.add(normalizedDate);
    }

    // Sort dates chronologically
    customSelectedDates.sort((a, b) => a.compareTo(b));

    // Update selectedDateList for custom frequency
    if (bookingFrequency == 'custom') {
      selectedDateList = List.from(customSelectedDates);
    }

    notifyListeners();
  }

  onCustomDateBottomSheet(BuildContext context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return const CustomDateBottomSheet();
        });
  }

  clearCustomDates() {
    customSelectedDates.clear();
    if (bookingFrequency == 'custom') {
      selectedDateList.clear();
    }
    notifyListeners();
  }

  bool? isTap = false;
  onWeekBottomSheet(context) async {
    isTap = true;
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return const WeekBottomSheet();
      },
    ).then((value) {
      isTap = false;
      notifyListeners();
    });
  }

  addNewLoc(context) {
    final loc = Provider.of<LocationProvider>(context, listen: false);
    route.pushNamed(context, routeName.currentLocation).then((e) async {
      await loc.getLocationList(context);
      if (loc.addressList.length == 1) {
        address = loc.addressList[0];
        notifyListeners();
      }
    });
  }

  onChangeBookingFrequency(val) {
    bookingFrequency = val;
    calculateSelectedDays();
    notifyListeners();
  }

  void initBookingFrequency() {
    if (bookingFrequency == null && appArray.bookingFrequencyList.isNotEmpty) {
      bookingFrequency = appArray.bookingFrequencyList.first;
      notifyListeners();
    }
  }

  onDateSelect(context, date, {isStart = true}) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => StatefulBuilder(builder: (context, setState) {
              return Consumer<SlotBookingProvider>(
                  builder: (context, value, child) {
                return const DateRangePickerLayout();
              });
            }));
  }

  // date selection button and go to back
  onSelect(context) {
    route.pop(context);
    if (rangeEnd != null) {
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(milliseconds: 500),
          content: Text("opps!! you have not select date yet.",
              style: appCss.dmDenseMedium12
                  .textColor(appColor(context).whiteColor)),
          backgroundColor: appColor(context).red));
    }
    notifyListeners();
  }

  //select year
  selectYear(context) async {
    showDialog(
        context: context,
        builder: (BuildContext context3) {
          return const YearAlertDialog();
        });
  }

  onRangeSelect(start, end, focusedDay) {
    selectedDay = null;
    currentDate = focusedDay;
    rangeStart = start;
    rangeEnd = end;
    log("STTT :$start");
    log("STTT :$rangeStart");
    log("STTT :$rangeEnd");
    rangeSelectionMode = RangeSelectionMode.toggledOn;
    startDateCtrl.text = DateFormat("dd-MM-yyyy").format(rangeStart!);
    endDateCtrl.text =
        rangeEnd != null ? DateFormat("dd-MM-yyyy").format(rangeEnd!) : "";
    calculateSelectedDays();
    notifyListeners();
  }

  void calculateSelectedDays() {
    selectedDateList.clear();
    if (rangeStart != null && rangeEnd != null) {
      DateTime tempDate = rangeStart!;
      if (bookingFrequency == 'daily') {
        while (tempDate.isBefore(rangeEnd!) ||
            tempDate.isAtSameMomentAs(rangeEnd!)) {
          String weekdayName = DateFormat('EEEE').format(tempDate);
          if (newWeekDayList.contains(weekdayName)) {
            selectedDateList.add(tempDate);
          }
          tempDate = tempDate.add(const Duration(days: 1));
        }
      } else if (bookingFrequency == 'weekly') {
        while (tempDate.isBefore(rangeEnd!) ||
            tempDate.isAtSameMomentAs(rangeEnd!)) {
          selectedDateList.add(tempDate);
          tempDate = tempDate.add(const Duration(days: 7));
        }
      } else if (bookingFrequency == 'monthly') {
        while (tempDate.isBefore(rangeEnd!) ||
            tempDate.isAtSameMomentAs(rangeEnd!)) {
          selectedDateList.add(tempDate);
          tempDate = DateTime(tempDate.year, tempDate.month + 1, tempDate.day);
        }
      } else if (bookingFrequency == 'yearly') {
        while (tempDate.isBefore(rangeEnd!) ||
            tempDate.isAtSameMomentAs(rangeEnd!)) {
          selectedDateList.add(tempDate);
          tempDate = DateTime(tempDate.year + 1, tempDate.month, tempDate.day);
        }
      } else {
        selectedDateList.add(rangeStart!);
        if (rangeEnd != null && !isSameDay(rangeStart, rangeEnd)) {}
      }
    }
    log("Selected dates count: ${selectedDateList.length}");
  }

  Future<void> fetchTimeSlots() async {
    try {
      log("servicesCart provider id::${servicesCart?.user?.id ?? servicesCart?.userId}");
      // isLoading = true;
      notifyListeners();
      final response = await apiServices.getApi(
        "${api.providerTimeSlot}/${servicesCart?.userId ?? 3}",
        [],
        isToken: true,
      );
      log("GET API Response: ${response.toString()}");

      if (response.isSuccess!) {
        final timeSlots = response.data['time_slots'] as List<dynamic>;
        for (var slot in timeSlots) {
          final day = slot['day'].toString().toUpperCase();
          final slots = List<String>.from(slot['slots'] ?? []);
          final isActive = slot['is_active'] == 1 ? 1 : 0;
        }
      } else {
        log("GET API failed: ${response.message}");
      }
    } catch (e, s) {
      log("Fetch time slots error: $e\n$s");
    } finally {
      // isLoading = false;
      notifyListeners();
    }
  }

  deleteJobRequestConfirmation(context, sync, index) {
    animateDesign(sync);
    showDialog(
        context: context,
        builder: (context1) {
          return StatefulBuilder(builder: (context2, setState) {
            return Consumer<SlotBookingProvider>(
                builder: (context3, value, child) {
              return AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  insetPadding:
                      const EdgeInsets.symmetric(horizontal: Insets.i20),
                  shape: const SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius.all(SmoothRadius(
                          cornerRadius: AppRadius.r14, cornerSmoothing: 1))),
                  backgroundColor: appColor(context).whiteBg,
                  content: Stack(alignment: Alignment.topRight, children: [
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      // Gif
                      Stack(alignment: Alignment.topCenter, children: [
                        Stack(alignment: Alignment.topCenter, children: [
                          SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        SizedBox(
                                            height: Sizes.s208,
                                            width: Sizes.s150,
                                            child: AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                curve: isPositionedRight
                                                    ? Curves.bounceIn
                                                    : Curves.bounceOut,
                                                alignment: isPositionedRight
                                                    ? Alignment.center
                                                    : Alignment.topCenter,
                                                child: AnimatedContainer(
                                                    duration: const Duration(
                                                        milliseconds: 200),
                                                    height: 40,
                                                    child: Image.asset(
                                                        eImageAssets
                                                            .removeAddOn)))),
                                        Image.asset(eImageAssets.dustbin,
                                                height: Sizes.s88,
                                                width: Sizes.s88)
                                            .paddingOnly(bottom: Insets.i24)
                                      ]))
                              .decorated(
                                  color: appColor(context).fieldCardBg,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.r10)),
                        ]),
                        if (offsetAnimation != null)
                          SlideTransition(
                              position: offsetAnimation!,
                              child: (offsetAnimation != null &&
                                      isAnimateOver == true)
                                  ? Image.asset(eImageAssets.dustbinCover,
                                      height: 38)
                                  : const SizedBox())
                      ]),
                      // Sub text
                      const VSpace(Sizes.s15),
                      Text(language(context, translations!.removeAddOnsDes),
                              textAlign: TextAlign.center,
                              style: appCss.dmDenseRegular14
                                  .textColor(appColor(context).lightText)
                                  .textHeight(1.6))
                          .paddingSymmetric(horizontal: Sizes.s56),
                      const VSpace(Sizes.s25),
                      Row(children: [
                        Expanded(
                            child: ButtonCommon(
                                onTap: () => route.pop(context),
                                title: translations?.no ??
                                    language(context, appFonts.no),
                                borderColor: appColor(context).primary,
                                color: appColor(context).whiteBg,
                                style: appCss.dmDenseSemiBold16
                                    .textColor(appColor(context).primary))),
                        const HSpace(Sizes.s15),
                        Expanded(
                            child: ButtonCommon(
                                color: appColor(context).primary,
                                onTap: () {
                                  servicesCart!.selectedAdditionalServices!
                                      .removeAt(index);
                                  notifyListeners();
                                  route.pop(context);
                                },
                                style: appCss.dmDenseSemiBold16
                                    .textColor(appColor(context).whiteColor),
                                title: translations?.yes ??
                                    language(context, appFonts.yes)))
                      ])
                    ]).padding(
                        horizontal: Insets.i20,
                        top: Insets.i60,
                        bottom: Insets.i20),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Title
                          Text(language(context, translations!.removeAddOns),
                              style: appCss.dmDenseExtraBold18
                                  .textColor(appColor(context).darkText)),
                          Icon(CupertinoIcons.multiply,
                                  size: Sizes.s20,
                                  color: appColor(context).darkText)
                              .inkWell(onTap: () => route.pop(context))
                        ]).paddingAll(Insets.i20)
                  ]));
            });
          });
        }).then((value) {
      isPositionedRight = false;
      isAnimateOver = false;
      notifyListeners();
    });
  }

  animateDesign(TickerProvider sync) {
    Future.delayed(DurationClass.s1).then((value) {
      isPositionedRight = true;
      notifyListeners();
    }).then((value) {
      Future.delayed(DurationClass.ms150).then((value) {
        isAnimateOver = true;
        notifyListeners();
      }).then((value) {
        controller = AnimationController(
            vsync: sync, duration: const Duration(seconds: 2))
          ..forward();
        offsetAnimation = Tween<Offset>(
                begin: const Offset(0, 0.5), end: const Offset(0, 1.6))
            .animate(
                CurvedAnimation(parent: controller!, curve: Curves.elasticOut));
        notifyListeners();
      });
    });

    notifyListeners();
  }

  bool isNextLoading = false;
  List? selectedAddons;
  Future<void> onTapNext(BuildContext context) async {
    isNextLoading = true;
    notifyListeners();

    servicesCart!.selectedServiceMan = null;

    if (isPackage) {
      log("selectProviderIndex :$selectProviderIndex");
      servicePackageList[selectProviderIndex] = servicesCart!;
      servicePackageList[selectProviderIndex].selectedServiceNote =
          txtNote.text;

      if (servicePackageList[selectProviderIndex].serviceDate != null) {
        servicesCart!.serviceDate = focusedDay.value;
        servicesCart!.selectedDateTimeFormat =
            DateFormat("aa").format(focusedDay.value);
        servicePackageList[selectProviderIndex].serviceDate = focusedDay.value;
        servicePackageList[selectProviderIndex].selectServiceManType =
            "app_choose";
        log("packageCtrl.servicePackageList[selectProviderIndex].selectServiceManType : ${servicesCart!.media}");

        isStep2 = false;
        isNextLoading = false;
        notifyListeners();
        route.pop(context);
      } else {
        isNextLoading = false;
        notifyListeners();
        final serviceCtrl =
            Provider.of<ServicesDetailsProvider>(context, listen: false);
        log("service type ${serviceCtrl.service?.type}");
        if (serviceCtrl.service?.type != "schedule") {
          Fluttertoast.showToast(
            msg: "Please Select the Date & Time Slot",
            backgroundColor: Colors.red,
          );
        }
      }
    } else {
      await callBookingApi(
          servicesCart?.id,
          servicesCart?.selectedRequiredServiceMan ?? servicesCart?.requiredServicemen,
          servicesCart?.selectedAdditionalServices
              ?.map((service) => {
                    "id": service.id,
                    "qty": service.qty,
                  })
              .toList() /* servicesCart?.selectedAdditionalServices?.map((e) => e.id).toList() */);

      notifyListeners();
      //log("message -=-=-=-=-=-=-=-=-= ${servicesCart?.id}-=-=-=-=-=${servicesCart?.requiredServicemen}======== ${servicesCart?.selectedAdditionalServices?.map((e) => e.id).join(',')}");
      servicesCart!.selectedServiceNote = txtNote.text;
      servicesCart!.selectServiceManType = "app_choose";

      if (servicesCart!.serviceDate != null) {
        if (address != null) {
          log("servicesCart!.selectServiceManType : ${servicesCart!.id}");
          isStep2 = true;
          isNextLoading = false;
          notifyListeners();
        } else {
          txtNote.text = "";
          isNextLoading = false;
          notifyListeners();

          final serviceCtrl =
              Provider.of<ServicesDetailsProvider>(context, listen: false);
          log("service type 12${serviceCtrl.service?.type}");
          if (serviceCtrl.service?.type != "schedule") {
            Fluttertoast.showToast(
              msg: "Please Select the Date & Time Slot",
              backgroundColor: Colors.red,
            );
          }
        }
      } else {
        if (servicesCart?.type == 'scheduled') {
          isNextLoading = false;
          isStep2 = true;
          notifyListeners();
        } else {
          isNextLoading = false;
          isStep2 = false;
          Fluttertoast.showToast(
              msg: "Please Select Date & Time Slot", backgroundColor: Colors.red);
          notifyListeners();
        }
      }
    }
  }

  onChangeSlot(index) {
    timeIndex = index;
    notifyListeners();
    checkSlotAvailable();
  }

  void onAmPmChange(BuildContext context, int index) {
    scrollDayIndex = index;
    amIndex = index;
    notifyListeners();
    filterSlotByAmPm(context);
  }

  Future<void> filterSlotByAmPm(BuildContext context) async {
    showLoading(context);
    // timeSlot.clear();
    notifyListeners();

    if (timeSlotModel?.timeSlots == null) {
      hideLoading(context);
      return;
    }

    String day = DateFormat('EEEE').format(focusedDay.value).toUpperCase();
    List<TimeSlots> dayWeek = timeSlotModel!.timeSlots;
    int index = dayWeek.indexWhere(
        (element) => element.day.toLowerCase() == day.toLowerCase());

    if (index >= 0 && dayWeek[index].isActive == true) {
      List<String> newTimeSlot = dayWeek[index].slots;
      bool isToday = isSameDay(focusedDay.value, DateTime.now());
      for (String slot in newTimeSlot) {
        int hour = int.parse(slot.split(":")[0]);
        // Filter for AM/PM
        if (scrollDayIndex == 0 && hour < 12) {
          // AM: Include slots before 12:00 PM
          timeSlot.add(slot);
          log("timeSlot:::$timeSlot");
        } else if (scrollDayIndex == 1 && hour >= 12) {
          // PM: Include slots from 12:00 PM onwards
          timeSlot.add(slot);
        }
        // Restrict past times for today
        if (isToday) {
          int slotHour = hour;
          int slotMinute = int.parse(slot.split(":")[1]);
          DateTime now = DateTime.now();
          if (scrollDayIndex == 0 && now.hour >= 12) {
            timeSlot.remove(slot); // Remove AM slots if past noon
          } else if (slotHour < now.hour ||
              (slotHour == now.hour && slotMinute < now.minute)) {
            timeSlot.remove(slot); // Remove past times
          }
        }
      }
    }

    timeIndex = null;
    hideLoading(context);
    notifyListeners();
  }

  onChangeLocation(context, PrimaryAddress primaryAddress) async {
    final loc = Provider.of<LocationProvider>(context, listen: false);
    await loc.getLocationList(context);
    address = primaryAddress;
    if (isPackage) {
      final packageCtrl =
          Provider.of<SelectServicemanProvider>(context, listen: false);
      servicePackageList[selectProviderIndex].primaryAddress = address;
      packageCtrl.notifyListeners();
    } else {
      servicesCart!.primaryAddress = address;
    }

    notifyListeners();
  }

  void onDaySelected(DateTime selectDay, DateTime fDay, BuildContext context) {
    if (!isSameDay(selectedDay, selectDay)) {
      selectedDay = selectDay;
      focusedDay.value = fDay;
      scrollDayIndex =
          isSameDay(selectDay, DateTime.now()) && DateTime.now().hour >= 12
              ? 1
              : 0;
      amIndex = scrollDayIndex;
      timeIndex = null;
      log(">>> onDaySelected: $selectDay");
      log(">>> Weekday: ${DateFormat('EEEE').format(selectDay)}");

      // Refresh time slot list (if applicable)
      updateTimeSlotsForSelectedDay(context: context);

      // 🔥 Add this line
      notifyListeners();
    }
  }

  void onProviderDaySelected(
      DateTime selectDay, DateTime fDay, BuildContext context) {
    if (!isSameDay(selectedDay, selectDay)) {
      selectedDay = selectDay;
      focusedDay.value = fDay;
      scrollDayIndex =
          isSameDay(selectDay, DateTime.now()) && DateTime.now().hour >= 12
              ? 1
              : 0;
      amIndex = scrollDayIndex;
      timeIndex = null;
      // carouselController2.jumpToPage(scrollDayIndex);
      updateTimeSlotsForSelectedDay(context: context);
    }
  }

  int count = 0;
  void onInit(
    BuildContext context, {
    bool? isPackage,
    int? index,
    Services? service,
    bool isProviderTimeSlot = false,
  }) async {
    this.isPackage = isPackage ?? false;
    selectProviderIndex = index ?? 0;
    servicesCart = service;

    // Initialize date and time
    DateTime now = DateTime.now();
    DateTime twoHoursLater = now.add(const Duration(hours: 1, minutes: 2));
    onDaySelect(focusedDay.value, focusedDay.value);
    if (servicesCart?.serviceDate != null) {
      // Use service date if provided
      focusedDay.value = servicesCart!.serviceDate!;
      selectedDay = servicesCart!.serviceDate;

      // Convert hour to 12-hour format
      int hour = servicesCart!.serviceDate!.hour;
      int displayHour = hour % 12 == 0 ? 12 : hour % 12;
      scrollHourIndex = appArray.hourList
          .indexWhere((element) => element == displayHour.toString());

      // Set minute
      scrollMinIndex = appArray.minList.indexWhere((element) =>
          element ==
          servicesCart!.serviceDate!.minute.toString().padLeft(2, '0'));

      // Set AM/PM
      amIndex = servicesCart!.selectedDateTimeFormat == "AM" ? 0 : 1;
    } else {
      fetchSlotTime(context);
      // Set to current time + 2 hours
      focusedDay.value = twoHoursLater;
      selectedDay = twoHoursLater;
      // Convert hour to 12-hour format
      int hour = twoHoursLater.hour;
      int displayHour = hour % 12 == 0 ? 12 : hour % 12;
      scrollHourIndex = appArray.hourList
          .indexWhere((element) => element == displayHour.toString());

      // Set minute
      scrollMinIndex = appArray.minList.indexWhere((element) =>
          element == twoHoursLater.minute.toString().padLeft(2, '0'));
      scrollDayIndex = twoHoursLater.hour >= 12 ? 0 : 1;
      // Set AM/PM
      amIndex = twoHoursLater.hour >= 12 ? 0 : 1;
    }
    // Clamp indices before jumping — jumpToPage(-1) crashes the carousel
    if (scrollHourIndex == -1) scrollHourIndex = 0;
    if (scrollMinIndex == -1) scrollMinIndex = 0;
    // Guard against LateInitializationError when onInit is called from a layout
    // that does not mount CarouselSlider widgets (e.g. ProviderTimeSlotLayout)
    try {
      carouselController.jumpToPage(scrollHourIndex);
      carouselController1.jumpToPage(scrollMinIndex);
      carouselController2.jumpToPage(scrollDayIndex);
    } catch (e) {
      log('Carousel not yet mounted, skipping jumpToPage: $e');
    }

    // Initialize month dropdown
    int monthIndex = appArray.monthList
        .indexWhere((element) => element['index'] == focusedDay.value.month);
    chosenValue = appArray.monthList[monthIndex];

    // Set calendar format based on service type
    // Week view for normal bookings (compact), month view for scheduled bookings
    calendarFormat = servicesCart?.type == 'scheduled'
        ? CalendarFormat.month
        : CalendarFormat.week;

    await fetchSlotTime(context);
    notifyListeners();
  }

  void onDaySelect(DateTime selectDay, DateTime fDay) {
    notifyListeners();
    focusedDay.value = selectDay;
  }

  Future<void> fetchSlotTime(BuildContext context) async {
    // timeSlot = [];
    showLoading(context);
    notifyListeners();
    try {
      final response = await apiServices.getApi(
        "${api.providerTimeSlot}/${servicesCart?.userId ?? 3}",
        [],
        isData: true,
        isToken: true,
      );
      log("CALLA :${response.data}");
      if (response.isSuccess == true) {
        timeSlotModel = TimeSlotModel.fromJson(response.data);
        updateTimeSlotsForSelectedDay();
      } else {
        log("GET API failed: ${response.message}");
        // Fluttertoast.showToast(
        //     msg: response.message, backgroundColor: Colors.red);
      }
    } catch (e) {
      log("EEEE fetchSlotTime: $e");
      // Fluttertoast.showToast(
      //     msg: "Failed to fetch time slots", backgroundColor: Colors.red);
    } finally {
      hideLoading(context);
      notifyListeners();
    }
  }

  void updateTimeSlotsForSelectedDay({BuildContext? context}) {
    if (timeSlotModel?.timeSlots == null) {
      timeSlot = [];
      timeIndex = null;
      notifyListeners();
      return;
    }
    final day = DateFormat('EEEE').format(focusedDay.value).toUpperCase();
    final slot = timeSlotModel!.timeSlots.firstWhereOrNull(
      (element) => element.day.toUpperCase() == day,
    );
    timeSlot = (slot != null && slot.isActive == true) ? slot.slots : [];
    timeIndex = null; // Reset selected slot
    notifyListeners();
    // Trigger AM/PM filtering if amIndex is set and context is provided
    if (amIndex != null && context != null) {
      filterSlotByAmPm(context);
    }
  }

  Future<void> checkSlotAvailable(
      {bool isEdit = false, BuildContext? context}) async {
    final providerId = servicesCart?.user?.id ?? servicesCart?.userId;
    if (context == null ||
        providerId == null ||
        timeIndex == null ||
        timeSlot.isEmpty) {
      timeIndex = null;
      if (context != null) {
        Fluttertoast.showToast(
            msg: "Please select a time slot", backgroundColor: Colors.red);
      }
      notifyListeners();
      return;
    }
    try {
      showLoading(context);
      final selectedTime = timeSlot[timeIndex!];
      focusedDay.value = DateTime.utc(
        focusedDay.value.year,
        focusedDay.value.month,
        focusedDay.value.day,
        int.parse(selectedTime.split(":")[0]),
        int.parse(selectedTime.split(":")[1]),
      );
      final utcDay = focusedDay.value.toUtc();
      final data = {
        "provider_id": servicesCart!.user?.id ?? servicesCart!.userId,
        "dateTime": DateFormat("dd-MMM-yyyy,hh:mm aa").format(utcDay),
      };
      final response = await apiServices.getApi(
        api.isValidTimeSlot,
        data,
        isData: true,
        isToken: true,
      );
      if (response.isSuccess == true &&
          response.data['isValidTimeSlot'] == true) {
        // Slot is valid
      } else {
        timeIndex = null;
        Fluttertoast.showToast(
            msg: response.message.isNotEmpty
                ? response.message
                : "Slot not available",
            backgroundColor: Colors.red);
      }
    } catch (e) {
      log("Error checking slot: $e");
      timeIndex = null;
      Fluttertoast.showToast(
          msg: "Error validating slot", backgroundColor: Colors.red);
    } finally {
      hideLoading(context);
      notifyListeners();
    }
  }

  bool isLoading = false;

  Future<void> checkSlotAvailableForAppChoose({
    required BuildContext context,
    bool isEdit = false,
    bool isService = false,
  }) async {
    isLoading = true;
    showLoading(context);
    notifyListeners();

    try {
      // Ensure amIndex is valid
      if (amIndex == null || amIndex! < 0 || amIndex! > 1) {
        isLoading = false;
        hideLoading(context);
        Fluttertoast.showToast(
            msg: "Invalid AM/PM selection. Please try again.",
            backgroundColor: Colors.red);
        notifyListeners();
        return;
      }

      // Adjust hour for 12-hour format with AM/PM
      int hour = int.parse(appArray.hourList[scrollHourIndex]);
      String amPm = appArray.amPmList[amIndex!]; // "AM" or "PM"
      if (amPm == "PM" && hour != 12) {
        hour += 12; // Convert PM hours to 24-hour format (e.g., 1 PM -> 13)
      } else if (amPm == "AM" && hour == 12) {
        hour = 0; // Convert 12 AM to midnight
      } else if (amPm == "PM" && hour == 12) {
        hour = 12; // Convert 12 PM to noon
      }

// Construct selected DateTime in local time
      final selectedDateTime = DateTime(
        focusedDay.value.year,
        focusedDay.value.month,
        focusedDay.value.day,
        hour,
        int.parse(appArray.minList[scrollMinIndex]),
      );

// Debugging log
      log("Selected DateTime: $selectedDateTime, AM/PM: $amPm, Hour: $hour, Minute: ${appArray.minList[scrollMinIndex]}");

// Update focusedDay.value with validated time
      focusedDay.value = selectedDateTime;

// Prepare API data — convert to UTC so server comparison is timezone-agnostic
      final utcSelected = focusedDay.value.toUtc();
      var data = {
        "provider_id": servicesCart!.userId,
        "dateTime":
            "${DateFormat("dd-MMM-yyy,hh:mm").format(utcSelected)} ${DateFormat("aa").format(utcSelected).toLowerCase()}",
      };

// Debugging log
      log("API Data: $data");

// Make API call to check time slot availability
      await apiServices
          .getApi(api.isValidTimeSlot, data, isData: true, isToken: true)
          .then((value) async {
        hideLoading(context);
        if (value.isSuccess!) {
          if (value.data['isValidTimeSlot'] == true) {
            dateTimeSelect(context, isService, isEdit: isEdit);
          } else {
            timeIndex = null;
            timeSlot = [];
            Fluttertoast.showToast(
                msg: value.message, backgroundColor: Colors.red);
          }
        }
      });
    } catch (e) {
      log("Error: $e");
      hideLoading(context);
      Fluttertoast.showToast(
          msg: "An error occurred. Please try again.",
          backgroundColor: Colors.red);
    }

    isLoading = false;
    notifyListeners();
  }

  onMinDecrement() {
    if (scrollMinIndex > 0) {
      scrollMinIndex--;
    }
    carouselController1.jumpToPage(scrollMinIndex);
    notifyListeners();
  }

  onMinIncrement() {
    if (scrollMinIndex < appArray.minList.length - 1) {
      scrollMinIndex++;
    }
    notifyListeners();
    carouselController1.jumpToPage(scrollMinIndex);
    notifyListeners();
  }

  onDayDecrement() {
    if (scrollDayIndex > 0) {
      scrollDayIndex--;
    }
    notifyListeners();
    carouselController2.jumpToPage(scrollDayIndex);
    notifyListeners();
  }

  onDayIncrement() {
    if (scrollDayIndex < appArray.dayList.length) {
      scrollDayIndex++;
    }
    notifyListeners();
    carouselController2.jumpToPage(scrollDayIndex);
    notifyListeners();
  }

  onDropDownChange(choseVal, context) async {
    notifyListeners();

    int index = choseVal['index'];
    log("chosenValue : $index");

    DateTime now =
        DateTime.utc(focusedDay.value.year, index, focusedDay.value.day);
    log("HHHHHHH :$now ${focusedDay.value}");
    log("HHHHHHH :$now ${now.isAfter(focusedDay.value) || DateFormat('MMMM-yyyy').format(now) == DateFormat('MMMM-yyyy').format(focusedDay.value)}");
    if (now.isAfter(DateTime.now()) ||
        DateFormat('MMMM-yyyy').format(now) ==
            DateFormat('MMMM-yyyy').format(focusedDay.value)) {
      chosenValue = choseVal;

      notifyListeners();
      focusedDay.value =
          DateTime.utc(focusedDay.value.year, index, focusedDay.value.day + 0);
      onDaySelected(focusedDay.value, focusedDay.value, context);
      log("choseVal : $choseVal");
      String day = DateFormat('EEEE').format(focusedDay.value);

      if (timeSlotModel != null) {
        List<TimeSlots> dayWeek = timeSlotModel!.timeSlots;
        int listIndex = dayWeek.indexWhere(
            (element) => element.day.toLowerCase() == day.toLowerCase());

        if (listIndex >= 0) {
          if (dayWeek[listIndex].isActive == true) {
            [];
          } else {
            timeSlot = [];
            notifyListeners();
          }
        } else {
          timeSlot = [];
          notifyListeners();
        }
      }
    } else {
      if (DateFormat('MMMM-yyyy').format(now) ==
          DateFormat('MMMM-yyyy').format(DateTime.now())) {
        focusedDay.value = DateTime.utc(
            focusedDay.value.year, index, focusedDay.value.day + 0);
        onDaySelected(focusedDay.value, focusedDay.value, context);
        log("choseVal : $choseVal");
        String day = DateFormat('EEEE').format(focusedDay.value);
        if (timeSlotModel != null) {
          List<TimeSlots> dayWeek = timeSlotModel!.timeSlots;
          int listIndex = dayWeek.indexWhere(
              (element) => element.day.toLowerCase() == day.toLowerCase());

          if (listIndex >= 0) {
            if (dayWeek[listIndex].isActive == true) {
            } else {
              timeSlot = [];
              notifyListeners();
            }
          } else {
            timeSlot = [];
            notifyListeners();
          }
        }
      } else {
        log("ERROR");
        isVisible = true;
        notifyListeners();
        await Future.delayed(DurationClass.s3);

        isVisible = false;
        notifyListeners();
      }
    }
  }

  onPageCtrl(dayFocused) {
    focusedDay.value = dayFocused;
    demoInt = dayFocused.year;
    log("dayFocused :: $demoInt");
    notifyListeners();
  }

  onHourScroll(index) {
    scrollHourIndex = index;
    notifyListeners();
  }

// Updated onHourTap method
  void onHourTap(BuildContext context) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            primaryColor: appColor(context).primary,
            timePickerTheme: TimePickerThemeData(
              backgroundColor: appColor(context).whiteBg,
              hourMinuteColor: appColor(context).stroke,
              dialTextStyle: TextStyle(color: appColor(context).primary),
              dayPeriodColor: appColor(context).primary.withOpacity(.6),
              hourMinuteTextColor: appColor(context).primary,
              dayPeriodTextColor: appColor(context).primary,
              dayPeriodBorderSide: BorderSide(color: appColor(context).primary),
              dialHandColor: appColor(context).primary,
              dialTextColor: appColor(context).darkText,
              dialBackgroundColor: appColor(context).fieldCardBg,
              entryModeIconColor: appColor(context).primary,
              helpTextStyle: TextStyle(color: appColor(context).whiteBg),
              cancelButtonStyle: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(appColor(context).primary),
                foregroundColor:
                    MaterialStateProperty.all<Color>(appColor(context).whiteBg),
              ),
              confirmButtonStyle: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(appColor(context).primary),
                foregroundColor:
                    MaterialStateProperty.all<Color>(appColor(context).whiteBg),
              ),
              hourMinuteTextStyle: const TextStyle(fontSize: 30),
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      // Convert to 12-hour format
      int hour = time.hourOfPeriod;
      if (hour == 0) hour = 12; // Handle midnight/noon

      // Set scrollHourIndex
      scrollHourIndex =
          appArray.hourList.indexWhere((element) => element == hour.toString());
      if (scrollHourIndex == -1) scrollHourIndex = 0; // Fallback

      // Set minute
      String paddedMinute = time.minute.toString().padLeft(2, '0');
      scrollMinIndex =
          appArray.minList.indexWhere((element) => element == paddedMinute);
      if (scrollMinIndex == -1) scrollMinIndex = 0; // Fallback

      // Set AM/PM
      amIndex = time.period == DayPeriod.am ? 1 : 0;

      // Animate to selected positions
      carouselController.animateToPage(scrollHourIndex);
      carouselController1.animateToPage(scrollMinIndex);
      carouselController2.animateToPage(amIndex!);

      // Update focusedDay with selected time
      focusedDay.value = DateTime(
        focusedDay.value.year,
        focusedDay.value.month,
        focusedDay.value.day,
        time.hour, // Use 24-hour format for internal storage
        time.minute,
      );

      notifyListeners();
    }
  }

  onMinScroll(index) {
    scrollMinIndex = index;
    notifyListeners();
  }

  onDayScroll(index) {
    scrollDayIndex = index;
    notifyListeners();
  }

  onCalendarCreate(controller) {
    log("controller : $controller");
    pageController = controller;
  }

  onLeftArrow() async {
    DateTime now = DateTime.now();
    if (DateFormat('MM-yyyy').format(focusedDay.value) !=
        DateFormat('MM-yyyy').format(now)) {
      pageController.previousPage(
          duration: const Duration(microseconds: 200), curve: Curves.bounceIn);
      final newMonth = DateTime(
        focusedDay.value.year,
        focusedDay.value.month - 1,
        1, // First day of previous month
      );
      focusedDay.value = newMonth;
      int index = appArray.monthList
          .indexWhere((element) => element['index'] == focusedDay.value.month);
      chosenValue = appArray.monthList[index];
      selectedYear = DateTime.utc(focusedDay.value.year, focusedDay.value.month,
          focusedDay.value.day + 0);
      notifyListeners();
    } else {
      isVisible = true;
      notifyListeners();
      await Future.delayed(DurationClass.s3);

      isVisible = false;
      notifyListeners();
    }
    log("FFF : $focusedDay");
  }

  onRightArrow() {
    pageController.nextPage(
        duration: const Duration(microseconds: 200), curve: Curves.bounceIn);
    final newMonth = DateTime(
      focusedDay.value.year,
      focusedDay.value.month + 1,
      1, // First day of next month
    );
    focusedDay.value = newMonth;
    int index = appArray.monthList
        .indexWhere((element) => element['index'] == focusedDay.value.month);
    chosenValue = appArray.monthList[index];
    selectedYear = DateTime.utc(focusedDay.value.year, focusedDay.value.month,
        focusedDay.value.day + 0);
    notifyListeners();
    log("hbfbfdbf::::::$newMonth");
  }

  void listen() {
    if (scrollController.position.pixels >= 200) {
      hide();
    } else {
      show();
    }
    notifyListeners();
  }

  void show() {
    if (!isBottom) {
      isBottom = true;
      notifyListeners();
    }
  }

  void hide() {
    if (isBottom) {
      isBottom = false;
      notifyListeners();
    }
  }

  void onReady(BuildContext context, {Map? argData}) {
    isStep2 = false; // Always reset to step 1

    try {
      final Map<String, dynamic>? data = (argData ??
          ModalRoute.of(context)?.settings.arguments) as Map<String, dynamic>?;

      if (data == null) {
        log("Error: SlotBookingProvider.onReady received null arguments");
        // Ensure UI at least unlocks even on error
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
        return;
      }

      servicesCart = data['selectServicesCart'];
      if (servicesCart == null) {
        log("Error: servicesCart is null in onReady arguments");
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
        return;
      }

      // Populate core fields immediately
      servicesCart!.selectedRequiredServiceMan ??= 1;
      isPackage = data['isPackage'] ?? false;
      selectProviderIndex = data['selectProviderIndex'] ?? 0;

      // Initialize booking frequency for scheduled services
      initBookingFrequency();

      // Finish secondary initialization in the next frame to avoid build cycle conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          scrollController.addListener(listen);

          final locationCtrl =
              Provider.of<LocationProvider>(context, listen: false);

          if (locationCtrl.addressList.isNotEmpty) {
            address = locationCtrl.addressList.firstWhere(
              (e) => e.isPrimary == 1,
              orElse: () => locationCtrl.addressList.first,
            );
          }

          if (isPackage) {
            if (servicePackageList.length > selectProviderIndex) {
              servicePackageList[selectProviderIndex].primaryAddress = address;
            }
            Provider.of<SelectServicemanProvider>(context, listen: false)
                .notifyListeners();
          } else {
            servicesCart!.primaryAddress = address;
          }

          final dateTime = DateTime.now();
          if (appArray.monthList.isNotEmpty) {
            final index = appArray.monthList
                .indexWhere((e) => e['index'] == dateTime.month);
            chosenValue = index >= 0
                ? appArray.monthList[index]
                : appArray.monthList.first;
          }
        } catch (e, s) {
          log("Error in onReady post-frame logic: $e\n$s");
        } finally {
          notifyListeners(); // Final UI update
        }
      });
    } catch (e, s) {
      log("Error in SlotBookingProvider.onReady core: $e\n$s");
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }

  setAddress(context) {
    if (isPackage) {
      final packageCtrl =
          Provider.of<SelectServicemanProvider>(context, listen: false);
      servicePackageList[selectProviderIndex].primaryAddress = address;
      packageCtrl.notifyListeners();
      notifyListeners();
    }
  }

  onRemoveService(context) {
    if ((servicesCart!.selectedRequiredServiceMan!) <= 1) {
      Fluttertoast.showToast(
          msg: "Minimum 1 serviceman required",
          backgroundColor: Colors.red);
      return;
    }
    servicesCart!.selectedRequiredServiceMan =
        (servicesCart!.selectedRequiredServiceMan!) - 1;
    notifyListeners();
  }

  onAdd() {
    int count = (servicesCart!.selectedRequiredServiceMan!);
    count++;
    log("count::$count");
    servicesCart!.selectedRequiredServiceMan = count;

    notifyListeners();
  }

  onDateTimeSelect(context, index) {
    selectIndex = index;
    notifyListeners();
  }

  onProviderDateTimeSelect(context) async {
    log("SSS : $selectProviderIndex ");

    if (selectIndex == 0) {
      showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (BuildContext context3) {
            return DateTimePicker(
              isWeek: false,
              isService: isPackage,
              selectProviderIndex: selectProviderIndex,
              service: servicesCart,
            );
          }).then((value) {
        log("VVVS :#$value");
        if (isPackage) {
          final packageCtrl =
              Provider.of<SelectServicemanProvider>(context, listen: false);
          servicePackageList[selectProviderIndex].serviceDate =
              servicesCart!.serviceDate;
          servicePackageList[selectProviderIndex].selectDateTimeOption =
              selectIndex == 0 ? "custom" : "timeSlot";
          servicePackageList[selectProviderIndex].selectedDateTimeFormat =
              servicesCart!.selectedDateTimeFormat;
          notifyListeners();
          packageCtrl.notifyListeners();
        }
      });
      notifyListeners();
    } else {
      await fetchSlotTime(context);

      final hasProviderSlots = timeSlotModel != null &&
          timeSlotModel!.timeSlots
              .any((slot) => slot.isActive == true && slot.slots.isNotEmpty);

      if (hasProviderSlots) {
        showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (BuildContext context3) {
              return Consumer<SlotBookingProvider>(
                  builder: (context1, value, child) {
                return StatefulBuilder(builder: (context2, setState) {
                  return ProviderTimeSlotLayout(
                      isService: isPackage,
                      selectProviderIndex: selectProviderIndex,
                      service: servicesCart);
                });
              });
            }).then((value) {
          log("VVVS : $value");
          if (value == null) {
            focusedDay.value = DateTime.now();
            notifyListeners();
          }
          amIndex = null;
          timeSlot = [];
          notifyListeners();
          if (isPackage) {
            final packageCtrl =
                Provider.of<SelectServicemanProvider>(context, listen: false);
            servicePackageList[selectProviderIndex] = servicesCart!;
            servicePackageList[selectProviderIndex].serviceDate =
                servicesCart!.serviceDate;
            servicePackageList[selectProviderIndex].selectDateTimeOption =
                "timeSlot";
            servicePackageList[selectProviderIndex].selectedDateTimeFormat =
                servicesCart!.selectedDateTimeFormat;
            notifyListeners();
            packageCtrl.notifyListeners();
          }
        });
      } else {
        // Provider has no time slots — fall back to custom date/time picker
        showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (BuildContext context3) {
              return DateTimePicker(
                isWeek: false,
                isService: isPackage,
                selectProviderIndex: selectProviderIndex,
                service: servicesCart,
              );
            }).then((value) {
          log("VVVS custom fallback: $value");
          if (isPackage) {
            final packageCtrl =
                Provider.of<SelectServicemanProvider>(context, listen: false);
            servicePackageList[selectProviderIndex].serviceDate =
                servicesCart!.serviceDate;
            servicePackageList[selectProviderIndex].selectDateTimeOption =
                "custom";
            servicePackageList[selectProviderIndex].selectedDateTimeFormat =
                servicesCart!.selectedDateTimeFormat;
            notifyListeners();
            packageCtrl.notifyListeners();
          }
        });
      }
    }
    notifyListeners();
  }

  String getWeekday(String rawDate) {
    try {
      final parsedDate =
          DateTime.parse(rawDate); // Make sure date is "yyyy-MM-dd"
      return DateFormat('E').format(parsedDate); // Output: Mon, Tue, etc.
    } catch (e) {
      return rawDate; // fallback if format fails
    }
  }

  dateTimeSelect(context, isService, {isEdit = false}) {
    log("isService: $servicesCart");
    final amPm = appArray.amPmList[scrollDayIndex];
    int hour = int.parse(appArray.hourList[scrollHourIndex]);
    if (amPm == "PM" && hour != 12) hour += 12;
    if (amPm == "AM" && hour == 12) hour = 0;
    focusedDay.value = DateTime(
      focusedDay.value.year,
      focusedDay.value.month,
      focusedDay.value.day,
      hour,
      int.parse(appArray.minList[scrollMinIndex]),
    );
    notifyListeners();

    if (isEdit) {
      route.pop(context, arg: {
        "date": focusedDay.value,
        "time": appArray.amPmList[scrollDayIndex]
      });
    } else {
      servicesCart!.serviceDate = focusedDay.value;
      servicesCart!.selectedDateTimeFormat = appArray.amPmList[scrollDayIndex];
      notifyListeners();
      if (isService) {
        final packageCtrl =
            Provider.of<SelectServicemanProvider>(context, listen: false);
        packageCtrl.notifyListeners();
      }
      log("isService: ${servicesCart!.selectedDateTimeFormat}");
      route.pop(context, arg: isService ? servicesCart : focusedDay.value);
    }
  }

  void provideTimeSlotSelect(BuildContext context) async {
    log("timeIndex : $timeIndex");

    if (timeIndex != null) {
      final selectedDate = selectedDay ?? focusedDay.value;
      final selectedWeekday =
          DateFormat('EEEE').format(selectedDate).toUpperCase();

      // Match the day slot
      final matchedDaySlot = timeSlotModel!.timeSlots.firstWhere(
        (e) => e.day == selectedWeekday && e.isActive == true,
        orElse: () =>
            TimeSlots(day: selectedWeekday, slots: [], isActive: false),
      );

      // Get the selected slot time
      final selectedSlot = matchedDaySlot.slots[timeIndex!];

      log("Selected slot: $selectedSlot");

      // Now parse the selected slot time
      final hour = int.parse(selectedSlot.split(":")[0]);
      final minute = int.parse(selectedSlot.split(":")[1]);

      // Construct final DateTime
      focusedDay.value = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        hour,
        minute,
      );

      servicesCart!.serviceDate = focusedDay.value;
      servicesCart!.selectedDateTimeFormat =
          DateFormat("aa").format(focusedDay.value);

      notifyListeners();

      log("DOC: $isPackage ///${servicesCart!.serviceDate}");

      if (isPackage) {
        final packageCtrl =
            Provider.of<SelectServicemanProvider>(context, listen: false);

        servicePackageList[selectProviderIndex] = servicesCart!;
        servicePackageList[selectProviderIndex].serviceDate =
            servicesCart!.serviceDate;
        servicePackageList[selectProviderIndex].selectDateTimeOption =
            selectIndex == 0 ? "custom" : "timeSlot";
        servicePackageList[selectProviderIndex].selectedDateTimeFormat =
            servicesCart!.selectedDateTimeFormat;

        packageCtrl.notifyListeners();
        log("DOC:sss $isPackage ///${servicesCart!.serviceDate}");
      }

      route.pop(context, arg: isPackage ? servicesCart : focusedDay.value);
    } else {
      Fluttertoast.showToast(
          msg: "Please select time slot", backgroundColor: Colors.red);
    }
  }

  String buttonName(context) {
    String name = translations?.next ?? language(context, appFonts.next);
    log("isPackage ::$isPackage");
    if (isPackage) {
      final packageCtrl =
          Provider.of<SelectServicemanProvider>(context, listen: false);
      if (servicePackageList.length == 1) {
        name = translations?.submit ?? language(context, appFonts.submit);
        return name;
      } else {
        log("IMDD:${selectProviderIndex + 1} //$selectProviderIndex");
        if (selectProviderIndex + 1 < servicePackageList.length) {
          name = translations?.submit ?? language(context, appFonts.submit);
        } else {
          name = translations?.next ?? language(context, appFonts.next);
        }

        return name;
      }
    } else {
      return translations?.next ?? language(context, appFonts.next);
    }
  }

  onBack(context) {
    log("WOEK ");
    if (isStep2) {
      isStep2 = false;
    } else {
      isStep2 = false;
      route.pop(context);
      txtNote.text = "";
    }
    if (servicesCart != null) {
      servicesCart!.serviceDate = null;
      servicesCart!.selectDateTimeOption = null;
      if (isPackage) {
        final packageCtrl =
            Provider.of<SelectServicemanProvider>(context, listen: false);
        servicePackageList[selectProviderIndex].serviceDate = null;
        servicePackageList[selectProviderIndex].selectDateTimeOption = null;
      }
      amIndex = null;
    }
    notifyListeners();
  }

  addToCart(context) async {
    servicesCart!.primaryAddress = address;

    // Populate schedule booking data if it's a scheduled service
    if (servicesCart?.type == 'scheduled' && selectedDateList.isNotEmpty) {
      servicesCart?.isScheduledBooking = 1;
      servicesCart?.scheduleStartDate = rangeStart;
      servicesCart?.scheduleEndDate = rangeEnd;
      servicesCart?.scheduleTime =
          "${appArray.hourList[scrollHourIndex]}:${appArray.minList[scrollMinIndex]} ${appArray.amPmList[amIndex ?? 0]}";
      servicesCart?.bookingFrequency = bookingFrequency;
      servicesCart?.scheduledDatesJson = List.from(selectedDateList);
      servicesCart?.scheduledServicesCount = selectedDateList.length;
      if (bookingFrequency == 'daily') {
        servicesCart?.selectedWeekdays = List.from(newWeekDayList);
      }
    }

    notifyListeners();
    Provider.of<CommonApiProvider>(context, listen: false).selfApi(context);
    final cartCtrl = Provider.of<CartProvider>(context, listen: false);
    log("SERVI :${servicesCart?.selectedAdditionalServices}");
    int index = cartCtrl.cartList.indexWhere((element) =>
        element.isPackage == false &&
        element.serviceList != null &&
        element.serviceList?.id == servicesCart?.id);
    log("ADDD :${servicesCart?.primaryAddress}");

    if (index >= 0) {
      log("message is true");
      cartCtrl.cartList[index].serviceList = servicesCart;

      cartCtrl.notifyListeners();
    } else {
      log("message is false");
      CartModel cartModel =
          CartModel(isPackage: false, serviceList: servicesCart);
      cartCtrl.cartList.add(cartModel);
      cartCtrl.notifyListeners();
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove(session.cart);

    List<String> personsEncoded =
        cartCtrl.cartList.map((person) => jsonEncode(person.toJson())).toList();
    await preferences.setString(session.cart, json.encode(personsEncoded));

    cartCtrl.notifyListeners();
    cartCtrl.checkout(context);
    isStep2 = false;
    selectIndex = 1;
    txtNote.text = "";
    servicesCart = null;
    final selectOption =
        Provider.of<SelectServicemanProvider>(context, listen: false);
    final providerDetail =
        Provider.of<ProviderDetailsProvider>(context, listen: false);
    selectOption.servicePackageModel = null;
    providerDetail.selectProviderIndex = 0;
    providerDetail.selectIndex = 0;
    focusedDay.value = DateTime.now();
    notifyListeners();

    route.pushNamed(context, routeName.cartScreen);
  }

  Step2Model? step2Data;

  Future<void> callBookingApi(
      int? serviceId, int? requiredServicemen, additionalServices) async {
    log("Query Params: $additionalServices");
    Map<String, dynamic> queryParams = {
      "service_id": serviceId,
      "required_servicemen": requiredServicemen,
      "additional_services": additionalServices,
    };

    // if (servicesCart?.type == 'scheduled' || servicesCart?.type == 'schedule') {
    //     queryParams['type'] = servicesCart?.type;
    //     queryParams['booking_frequency'] = bookingFrequency;
    //     if(rangeStart != null) queryParams['start_date'] = DateFormat('yyyy-MM-dd').format(rangeStart!);
    //     if(rangeEnd != null) queryParams['end_date'] = DateFormat('yyyy-MM-dd').format(rangeEnd!);

    //     String time = "${appArray.hourList[scrollHourIndex]}:${appArray.minList[scrollMinIndex]} ${appArray.amPmList[amIndex ?? 0]}";
    //     queryParams['time'] = time;
    // }

    notifyListeners();
    log("Query Params: $queryParams");
    // log("Full URL: ${Uri.parse(api.step2Booking).replace(queryParameters: queryParams)}");

    try {
      await apiServices
          .getApi(api.step2Booking, queryParams, isToken: true, isData: true)
          .then(
        (value) {
          if (value.isSuccess!) {
            step2Data = Step2Model.fromJson(value.data);

            log("message-=-=-=-=-=-=-=-=-=-=-=-=-=258${value.data}");
          } else {
            log("message-=-=-=-=-=-=-=-=-=-=-=-=-=${value.message}");
          }

          notifyListeners();
        },
      );
    } catch (e, s) {
      print("API Error: $e\nStackTrace: $s");
    }
  }
}
