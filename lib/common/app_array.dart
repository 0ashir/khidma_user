
import 'package:fixit_user/config.dart';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../models/array_model.dart';

class AppArray {
  List<Map<String, String>> get onBoardingList => [
        {
          "title": translations?.welcomeToJust ?? "",
          "subtext": translations?.simplyTouch ?? "",
        },
        {
          "title": translations?.findYour ?? "",
          "subtext": translations?.selectServiceFrom ?? "",
        },
        {
          "title": translations?.bookYourDate ?? "",
          "subtext": translations?.chooseAnAppropriate ?? "",
        },
        {
          "title": translations?.goOnPayment ?? "",
          "subtext": translations?.pickYourPayment ?? "",
        },
      ];

  List<String> get chatHistoryOptionList =>
      [translations?.refresh ?? "", translations?.clearChat ?? ""];

  List<DashboardList> dashboardList(context) => [
        DashboardList(
            title: translations?.home ?? "Home", // Provide a fallback
            icon: eSvgAssets.homeOut,
            icon2: eSvgAssets.homeFill),
        DashboardList(
            title: translations?.booking ?? "Booking", // Provide a fallback
            icon: eSvgAssets.bookingOut,
            icon2: eSvgAssets.bookingFill),
        DashboardList(
            title: translations?.offer ?? "Offer", // Provide a fallback
            icon: eSvgAssets.offerOut,
            icon2: eSvgAssets.offerFill),
        DashboardList(
            title: translations?.profile ?? "Profile", // Provide a fallback
            icon: eSvgAssets.profileOut,
            icon2: eSvgAssets.profileFill),
      ];

  List<Map<String, Object>> get guestProfileList => [
        {
          "title": translations?.aboutApp ?? "",
          "data": [
            {
              "icon": eSvgAssets.mobile,
              "title": translations!.appDetails,
              "description": translations!.aboutUs,
              "isArrow": true
            },
            /*{"icon": eSvgAssets.rate, "title": translations!.rateUs, "isArrow": false},*/
            {
              "icon": eSvgAssets.share,
              "title": translations!.shareApp,
              "isArrow": false
            },
            /*  {
              "icon": eSvgAssets.chat,
              "title": translations!.supportTickets,
              "isArrow": false
            }, */
          ]
        },
        {
          "title": translations!.becomeProvider ?? "",
        }
      ];

  List<Map<String, dynamic>> get profileList => [
        {
          "title": translations!.general,
          "data": [
            {
              "icon": eSvgAssets.like,
              "title": translations!.favouriteList,
              "isArrow": true
            },
            {
              "icon": eSvgAssets.locationOut1,
              "title": translations!.manageLocations,
              "isArrow": true
            },
            {
              "icon": eSvgAssets.coupon,
              "title": translations!.myReviews,
              "isArrow": true
            },
            {
              "icon": eSvgAssets.chat,
              "title": translations!.chatHistory,
              "isArrow": true
            },
          ]
        },
        {
          "title": translations!.aboutApp,
          "data": [
            {
              "icon": eSvgAssets.mobile,
              "title": translations!.appDetails,
              "description": translations!.aboutUs,
              "isArrow": true
            },
            {
              "icon": eSvgAssets.rate,
              "title": translations!.rateUs,
              "isArrow": true
            },
            {
              "icon": eSvgAssets.share,
              "title": translations!.shareApp,
              "isArrow": true
            },
            {
              "icon": eSvgAssets.chat,
              "title": translations!.staffChat,
              "isArrow": true
            },
            if (appSettingModel!.activation!.referralEnable == "1")
              {
                "icon": eSvgAssets.discount,
                "title": appFonts.referralId,
                "isArrow": true
              },
          ]
        },
        {
          "title": "",
        },
        {
          "title": translations!.alertZone,
          "data": [
            {
              "icon": eSvgAssets.delete,
              "title": translations!.deleteAccount,
              "isArrow": false
            },
            {
              "icon": eSvgAssets.logout,
              "title": translations!.logOut,
              "isArrow": false
            }
          ]
        },
      ];

/*
  List<ProfileModel> profileList(context) => [
        ProfileModel(title: translations!.general, data: [
          Data(
              icon: eSvgAssets.like,
              title: translations?.favouriteList ?? appFonts.favouriteList,
              isArrow: true),
          Data(
              icon: eSvgAssets.locationOut1,
              title: translations?.manageLocations ?? '',
              isArrow: true),
          Data(
              icon: eSvgAssets.coupon,
              title: translations?.myReviews ?? '',
              isArrow: true),
          Data(
              icon: eSvgAssets.chat,
              title: translations?.chatHistory ?? '',
              isArrow: true),
        ]),
        ProfileModel(title: translations?.aboutApp ?? '', data: [
          Data(
              icon: eSvgAssets.mobile,
              title: translations?.appDetails ?? '',
              isArrow: true),
          Data(
              icon: eSvgAssets.rate,
              title: translations?.rateUs ?? '',
              isArrow: true),
          Data(
              icon: eSvgAssets.share,
              title: translations?.shareApp ?? '',
              isArrow: false),
        ]),
        ProfileModel(title: translations?.becomeProvider ?? ''),
        ProfileModel(title: translations?.alertZone ?? '', data: [
          Data(
              icon: eSvgAssets.delete,
              title: translations?.deleteAccount ?? '',
              isArrow: false),
          Data(
              icon: eSvgAssets.logout,
              title: translations?.logOut ?? '',
              isArrow: false),
        ])
      ];
*/

  var categoriesList = [
    {"title": translations!.acRepair, "icon": eSvgAssets.ac},
    {"title": translations!.cleaning, "icon": eSvgAssets.cleaning},
    {"title": translations!.carpenter, "icon": eSvgAssets.carpenter},
    {"title": translations!.cooking, "icon": eSvgAssets.cooking},
    {"title": translations!.electrician, "icon": eSvgAssets.electrician},
    {"title": translations!.painter, "icon": eSvgAssets.painter},
    {"title": translations!.plumber, "icon": eSvgAssets.plumber},
    {"title": translations!.salon, "icon": eSvgAssets.salon}
  ];

  var servicesList = [
    {
      "title": translations!.cleaningPackage,
      "icon": eImageAssets.cleaning,
      "price": "\$20.05",
      "color": const Color(0XFFFD4868)
    },
    {
      "title": translations!.paintingPackage,
      "icon": eImageAssets.paint,
      "price": "\$15.52",
      "color": const Color(0XFF48BFFD)
    },
    {
      "title": translations!.cookingPackage,
      "icon": eImageAssets.fire,
      "price": "\$15.52",
      "color": const Color(0XFF808CFF)
    },
    {
      "title": translations!.acRepair,
      "icon": eImageAssets.ac,
      "price": "\$15.52",
      "color": const Color(0XFFFF7456)
    },
    {
      "title": translations!.salonPackage,
      "icon": eImageAssets.salon,
      "price": "\$15.52",
      "color": const Color(0XFFB75CFF)
    },
    {
      "title": translations!.plumberPackage,
      "icon": eImageAssets.plumber,
      "price": "\$15.52",
      "color": const Color(0XFF17D792)
    },
    {
      "title": translations!.electricianPackage,
      "icon": eImageAssets.electrician,
      "price": "\$15.52",
      "color": const Color(0XFF487AFD)
    },
    {
      "title": translations!.carpenterPackage,
      "icon": eImageAssets.carpenter,
      "price": "\$15.52",
      "color": const Color(0XFFFDB448)
    },
  ];

  var featuredList = [
    {
      "profile": eImageAssets.fsProfile1,
      "name": translations!.arleneMcCoy,
      "rating": "3.0",
      "discount": "10%",
      "image": eImageAssets.fs1,
      "work": translations!.cleaningBathroom,
      "offerPrice": "\$40.56",
      "price": "\$30",
      "time": translations!.min30,
      "description": translations!.foamJet,
      "serviceman": "Min 2 servicemen required"
    },
    {
      "profile": eImageAssets.fsProfile2,
      "name": translations!.darleneRobertson,
      "rating": "3.0",
      "discount": "",
      "image": eImageAssets.fs2,
      "work": translations!.furnishing,
      "offerPrice": "\$15.23",
      "price": "\$15.23",
      "time": translations!.min30,
      "description": translations!.foamJet,
      "serviceman": "Min 1 servicemen required"
    }
  ];

  var expertServicesList = [
    {
      "name": translations!.leslie,
      "rating": "4.0",
      "image": eImageAssets.es1,
      "location": translations!.santaAna,
      "status": "online",
      "subtext": translations!.paintingService
    },
    {
      "name": translations!.estherHoward,
      "rating": "4.0",
      "image": eImageAssets.es2,
      "location": translations!.allentown,
      "status": "offline",
      "subtext": translations!.paintingCleaning
    },
    {
      "name": translations!.guyHawkins,
      "rating": "3.0",
      "image": eImageAssets.es3,
      "location": translations!.mesaNew,
      "status": "online",
      "subtext": translations!.salonService
    },
  ];

  var latestBlogList = [
    {
      "name": translations!.switchboard,
      "image": eImageAssets.lb1,
      "subtext": translations!.woodenPartition,
      "date": translations!.feb25,
      "message": "23",
      "by": translations!.byAdmin
    },
    {
      "name": translations!.manTrimming,
      "image": eImageAssets.lb2,
      "subtext": translations!.woodenPartition,
      "date": translations!.feb25,
      "message": "30",
      "by": translations!.byAdmin
    },
    {
      "name": translations!.bringJoy,
      "image": eImageAssets.lb3,
      "subtext": translations!.mar30,
      "date": translations!.feb25,
      "message": "10",
      "by": translations!.byAdmin
    },
  ];

/*
  var profileList = [
    {
      "title": translations!.general,
      "data": [
        {
          "icon": eSvgAssets.like,
          "title": translations!.favouriteList,
          "isArrow": true
        },
        {
          "icon": eSvgAssets.locationOut1,
          "title": translations!.manageLocations,
          "isArrow": true
        },
        {
          "icon": eSvgAssets.coupon,
          "title": translations!.myReviews,
          "isArrow": true
        },
        {
          "icon": eSvgAssets.chat,
          "title": translations!.chatHistory,
          "isArrow": true
        }
      ]
    },
    {
      "title": translations!.aboutApp,
      "data": [
        {
          "icon": eSvgAssets.mobile,
          "title": translations!.appDetails,
          "description": translations!.aboutUs,
          "isArrow": true
        },

 {"icon": eSvgAssets.rate, "title": translations!.rateUs, "isArrow": false},
        {
          "icon": eSvgAssets.share,
          "title": translations!.shareApp,
          "isArrow": false
        },
      ]
    },
    {
      "title": translations!.becomeProvider,
    },
    {
      "title": translations!.alertZone,
      "data": [
        {
          "icon": eSvgAssets.delete,
          "title": translations!.deleteAccount,
          "isArrow": false
        },
        {
          "icon": eSvgAssets.logout,
          "title": translations!.logOut,
          "isArrow": false
        }
      ]
    },
  ];
*/

  //app setting
  List appSetting(isTheme) => [
        {
          'title': isTheme ? translations!.lightTheme : translations!.darkTheme,
          'icon': eSvgAssets.dark
        },
        // {'title': translations!.changeCurrency, 'icon': eSvgAssets.currency},
        {'title': translations!.changeLanguage, 'icon': eSvgAssets.translate},
        {'title': translations!.changePassword, 'icon': eSvgAssets.lock}
      ];

  List appGuestSetting(isTheme) => [
        {
          'title': isTheme ? translations!.lightTheme : translations!.darkTheme,
          'icon': eSvgAssets.dark
        },
        // {'title': translations!.changeCurrency, 'icon': eSvgAssets.currency},
        {'title': translations!.changeLanguage, 'icon': eSvgAssets.translate},
      ];

//currency
  List<Map<String, dynamic>> get currencyList => [
        {
          'title': translations!.usDollar,
          'icon': eSvgAssets.usCurrency,
          "code": "USD",
          "symbol": "\$",
          'USD': 1,
          'INR': 83.24,
          'POU': 0.83,
          'EUR': 0.96,
        },
        {
          'title': translations!.euro,
          'icon': eSvgAssets.euroCurrency,
          "code": "EUR",
          "symbol": '€',
          'USD': 1.05,
          'INR': 87.10,
          'POU': 0.87,
          'EUR': 1,
        },
        {
          'title': translations!.inr,
          'icon': eSvgAssets.inCurrency,
          "code": "INR",
          "symbol": '₹',
          'USD': 0.012,
          'INR': 1,
          'POU': 0.010,
          'EUR': 0.011,
        },
        {
          'title': translations!.pound,
          'icon': eSvgAssets.ukCurrency,
          "code": "POU",
          "symbol": "£",
          'USD': 1.22,
          'INR': 101.74,
          'POU': 1,
          'EUR': 1.15,
        }
      ];

  List<String> get favouriteTabList =>
      [translations?.provider ?? "", translations?.service ?? ""];

  var reviewList = [
    {
      "image": eImageAssets.profile,
      "name": "Kurt Bates",
      "service": "Cleaning service",
      "rate": "4.0",
      "review":
          "“I just love their service & the staff nature for work, I’d like to hire them again”",
      "time": "12 min ago",
    },
    {
      "image": eImageAssets.profile,
      "name": "Jane Cooper",
      "service": "Painting service",
      "rate": "4.0",
      "review":
          "This provider has the best staff who assist us until the service is complete. Thank you!",
      "time": "15 days ago",
    },
    {
      "image": eImageAssets.profile,
      "name": "Lorri Warf",
      "service": "Ac cleaning",
      "rate": "4.0",
      "review": "“I love their work with ease, Thank you !”",
      "time": "28 days ago",
    },
  ];

  List<Map<String, dynamic>> get editReviewList => [
        {
          "icon": eSvgAssets.bad,
          "title": translations!.bad,
          "gif": eGifAssets.bad
        },
        {
          "icon": eSvgAssets.okay,
          "title": translations!.okay,
          "gif": eGifAssets.okay
        },
        {
          "icon": eSvgAssets.good,
          "title": translations!.good,
          "gif": eGifAssets.good
        },
        {
          "icon": eSvgAssets.amazing,
          "title": translations!.amazing,
          "gif": eGifAssets.amazing
        },
        {
          "icon": eSvgAssets.excellent,
          "title": translations!.excellent,
          "gif": eGifAssets.excellent
        },
      ];

  List<String> get selectErrorList => [
        translations?.purchaseError ?? "",
        translations?.technicalError ?? "",
        translations?.appError ?? "",
        translations?.feedback ?? ""
      ];

  List<Map<String, dynamic>> get categoryList => [
        {
          "icon": eSvgAssets.cleaning,
          "isCheck": false,
          "title": translations!.cleaning,
        },
        {
          "icon": eSvgAssets.ac,
          "isCheck": false,
          "title": translations!.acRepair,
        },
        {
          "icon": eSvgAssets.carpenter,
          "isCheck": false,
          "title": translations!.carpenter,
        },
        {
          "icon": eSvgAssets.cooking,
          "isCheck": false,
          "title": translations!.cooking,
        },
        {
          "icon": eSvgAssets.electrician,
          "isCheck": false,
          "title": translations!.electrician,
        },
        {
          "icon": eSvgAssets.painter,
          "isCheck": false,
          "title": translations!.painter,
        },
        {
          "icon": eSvgAssets.plumber,
          "isCheck": false,
          "title": translations!.plumber,
        },
      ];

  var ratingList = [
    {"rate": "5", "icon": eSvgAssets.star5, "value": 5},
    {"rate": "4", "icon": eSvgAssets.star4, "value": 4},
    {"rate": "3", "icon": eSvgAssets.star3, "value": 3},
    {"rate": "2", "icon": eSvgAssets.star2, "value": 2},
    {"rate": "1", "icon": eSvgAssets.star1, "value": 1},
  ];

  List<String> get filterList => [
        translations?.category ?? "",
        translations?.priceRating ?? "",
        translations?.distance ?? "",
      ];

  List<String> get filterList1 => [
        translations?.provider ?? "",
        translations?.priceRating ?? "",
        translations?.distance ?? "",
      ];

  List<Map<String, dynamic>> get experienceList => [
        {
          "id": 0,
          "title": translations?.highestExperience ?? '',
        },
        {"id": 1, "title": translations?.lowestExperience ?? ''},
        {"id": 2, "title": translations?.highestServed ?? ''},
        {"id": 3, "title": translations?.lowestServed ?? ''},
      ];

  List<Map<String, dynamic>> get reviewLowHighList => [
        {"id": 0, "title": translations!.lowestRate},
        {"id": 1, "title": translations!.highestRate},
      ];

  List<String> get languagesList => [
        translations?.english ?? "",
        translations?.spanish ?? "",
        translations?.chines ?? ""
      ];

  List<String> get servicemanChooseList => [
        translations?.letAppChoose ?? "",
        translations?.selectServicemenAs ?? ""
      ];

  List<Map<String, dynamic>> get selectList => [
        {"image": eSvgAssets.gallery, "title": translations!.chooseFromGallery},
        {"image": eSvgAssets.camera, "title": translations!.openCamera}
      ];

  List<Map<String, dynamic>> get selectRepaymentOrCancel => [
        {"title": translations!.cancelBooking},
        {"title": translations!.cashOnDelivery},
        {"title": translations!.selectAnotherPayment}
      ];

  List monthList = [
    {"title": "January", "index": 1},
    {"title": "February", "index": 2},
    {"title": "March", "index": 3},
    {"title": "April", "index": 4},
    {"title": "May", "index": 5},
    {"title": "June", "index": 6},
    {"title": "July", "index": 7},
    {"title": "August", "index": 8},
    {"title": "September", "index": 9},
    {"title": "October", "index": 10},
    {"title": "November", "index": 11},
    {"title": "December", "index": 12}
  ];

  List<String> hourList = List.generate(12, (index) {
    DateTime time =
        DateTime.now().add(Duration(hours: index)); // +1 for 1 hour ahead
    String formattedTime = DateFormat('h').format(time);
    return formattedTime;
  });

  List<String> minList = List.generate(60, (index) {
    DateTime time = DateTime.now().add(Duration(minutes: index));
    String formattedTime = DateFormat('mm').format(time);
    return formattedTime;
  });

  List<String> dayList = List.generate(2, (index) {
    DateTime time = DateTime.now().add(Duration(days: index));
    String formattedTime = DateFormat('a').format(time);
    return formattedTime;
  });

  var amPmList = ["PM", "AM"];

  List<Map<String, dynamic>> get jobExperienceList => [
        {
          "id": 0,
          "title": translations!.highestExperience,
        },
        {"id": 1, "title": translations!.lowestExperience},
      ];

  List<String> get expertiseList => [
        translations?.acRepair ?? "",
        translations?.carpenter ?? "",
        translations?.cleaning ?? "",
      ];

  List<String> get bookingFilterList => [
        translations?.status ?? "",
        translations?.date ?? "",
        translations?.category ?? "",
      ];

  List<Map<String, dynamic>> get socialList => [
        {"image": eSvgAssets.phone1, "title": translations!.call},
        {"image": eSvgAssets.chat, "title": translations!.chat},
        {"image": eSvgAssets.wp, "title": translations!.wp},
      ];

  List<Map<String, dynamic>> get remotelySocialList => [
        {"image": eSvgAssets.phone1, "title": translations!.call},
        {"image": eSvgAssets.wp, "title": translations!.wp},
      ];

  var optionList = [
    translations!.audioCall,
    translations!.videoCall,
    /* translations!.clearChat */
  ];

  var packageBookingList = [
    {
      "title": "Cleaning service package",
      "price": "32.08",
      "Description":
          "As a service member, I believe I am capable of problem solving. I too face a variety of obstacles at work and must develop effective solutions to ensure client satisfaction.",
      "pImage": eImageAssets.es1,
      "pName": "Kurt Bates",
      "rate": "3.0",
      "includedService": [
        {
          "image": eImageAssets.fs2,
          "title": "House hold cook",
          "price": "15.23",
          "bookingId": "#15263",
          "status": translations!.accepted,
          "serviceman": "2"
        },
        {
          "image": eImageAssets.es1,
          "title": "Hair spa",
          "price": "10.15",
          "bookingId": "#15264",
          "status": translations!.ongoing,
          "serviceman": "0"
        },
      ]
    }
  ];

  List<String> get themeModeList => [
        translations?.lightTheme ?? "",
        translations?.darkTheme ?? "",
        translations!.systemDefault ?? ''
      ];

  var durationList = [
    "Hours",
    "Minutes",
  ];

  final List<String> weekdayList = [
    translations?.sunday ?? "Sunday",
    translations?.monday ?? "Monday",
    translations?.tuesday ?? "Tuesday",
    translations?.wednesday ?? "Wednesday",
    translations?.thursday ?? "Thursday",
    translations?.friday ?? "Friday",
    translations?.saturday ?? "Saturday",
  ];

  var bookingFrequencyList = ["daily", "weekly", "monthly", "yearly", "custom"];

  List<XFile> serviceImageList = [];
}
