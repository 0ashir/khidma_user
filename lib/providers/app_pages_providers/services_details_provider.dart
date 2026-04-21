/* import 'dart:developer';

import 'package:fixit_user/common_tap.dart';
import 'package:fixit_user/config.dart';

import '../../models/service_details_model.dart';

class ServicesDetailsProvider with ChangeNotifier {
  int selectedIndex = 0, selected = -1;
  bool isBottom = true;
  int? serviceId;
  ScrollController scrollController = ScrollController();
  double widget1Opacity = 0.0;
  ServiceDetailsModel? service;
  List<ServiceFaqModel> serviceFaq = [];
  List<AdditionalService> additionalService = [];

  onImageChange(index) {
    selectedIndex = index;
    isVideo = false;
    notifyListeners();
  }

  bool isVideo = false;

  onVideo() {
    isVideo = true;
    notifyListeners();
  }

  bool isContain(id) =>
      additionalService.where((element) => element.id == id).isNotEmpty;

  addAdditionalService(data) {
    log("hdyfudgsdl");
    int index =
        additionalService.indexWhere((element) => element.id == data.id);
    if (index >= 0) {
      additionalService.removeAt(index);
    } else {
      additionalService.add(data);
    }
    notifyListeners();
  }

  void clearAdditionalServices() {
    additionalService.clear();
    log("Cleared additional services.");
    notifyListeners();
  }

  onReady(context) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.setString(session.booking, "booking");

      widget1Opacity = 1.0;
      scrollController.addListener(listen);
      notifyListeners();

      dynamic data = ModalRoute.of(context)!.settings.arguments;

      // int? serviceId;
      getServiceFaqId(context, data['serviceId']);
      // await pref.setInt("lastOpenedServiceId", data['serviceId']);

      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.onReady(context);

      /* if (data != null) {
        if (data['serviceId'] != null) {
          serviceId = data['serviceId'];
        } else if (data['services'] != null && data['services'] is Services) {
          service = data['services'];
          serviceId = service!.id;
        }
      }

      if (serviceId != null) {
        await Future.wait([
          getServiceById(context, serviceId),
          // getRelatedServices(context, serviceId), // Fetch related services
        ]);
      } else {
        log('Error: No service ID provided');
        widget1Opacity = 0.0; // Show shimmer or error state
        notifyListeners();
      }*/
    } catch (e) {
      log('Error in onReady: $e');
      widget1Opacity = 0.0;
      notifyListeners();
    }
  }

/*
  onReady(context) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString(session.booking, "booking");
    widget1Opacity = 1;
    scrollController.addListener(listen);

    notifyListeners();
    dynamic data = ModalRoute.of(context)!.settings.arguments;

    if (data['serviceId'] != null) {
      await Future.wait([
        getServiceById(context, service!.id),
        getServiceFaqId(context, service!.id)
      ]);
    } else {
      service = data['services'];
      notifyListeners();
      await Future.wait([
        Future(
          () {
            getServiceById(context, service!.id);
            getServiceFaqId(context, service!.id);
          },
        )
      ]);
    }
    notifyListeners();
    */
/*  Future.delayed(const Duration(milliseconds: 500), () {
      widget1Opacity = 1;
      notifyListeners();
    }); */ /*

    notifyListeners();
  }
*/

  onRefresh(context) async {
    showLoading(context);
    notifyListeners();
    await getServiceById(context, service!.id);
    await getServiceFaqId(context, service!.id);

    notifyListeners();
  }

  @override
  void dispose() {
    // Remove the listener before disposing the controller
    scrollController.removeListener(listen);
    scrollController.dispose();
    super.dispose();
  }

  onExpansionChange(newState, index) {
    log("dghfdkg:$newState");
    if (newState) {
      const Duration(seconds: 20000);
      selected = index;
      notifyListeners();
    } else {
      selected = -1;
      notifyListeners();
    }
  }

  void listen() {
    if (scrollController.position.pixels >= 200) {
      hide();
      notifyListeners();
    } else {
      show();
      notifyListeners();
    }
  }

  void show() {
    if (!isBottom) {
      isBottom = true;
      notifyListeners();
    }
    notifyListeners();
  }

  void hide() {
    if (isBottom) {
      isBottom = false;
      notifyListeners();
    }
    notifyListeners();
  }

  onBack(context, isBack) async {
    // service = null;

    serviceFaq = [];
    selectedIndex = 0;
    // serviceId = 0;
    widget1Opacity = 0.0;
    isVideo = false;

    notifyListeners();
    // log("djhfkf :$service");
    // SharedPreferences pref = await SharedPreferences.getInstance();
    /* if (pref.getString(session.booking) == 'booking') {
      route.pushReplacementNamed(context, routeName.dashboard);
    }*/
    if (isBack) {
      // route.pop(context);
      Navigator.pop(context);
    } else {
      log("back else");
      if (Navigator.of(context).canPop()) {
        Navigator.pop(context);
      }
    }
  }

  bool isLoading = false;

  Future<void> getServiceById(context, serviceId) async {
    isLoading = true;
    try {
      await apiServices
          .getApi("${api.service}/$serviceId", [], isToken: true)
          .then((value) {
        if (value.isSuccess!) {
          log("value.isSuccess service :::${value.data}");
          service = ServiceDetailsModel.fromJson(value.data);
          if (context.mounted) {
            hideLoading(context);
          }
          isLoading = false;
          notifyListeners();
        } else {
          hideLoading(context);
          isLoading = false;
          notifyListeners();
        }
      });
    } catch (e,s) {
      log("ERRROEEE SERVICE getServiceById : $e ----$s");
      isLoading = false;
      hideLoading(context);
      notifyListeners();
    }
  }

  Future<void> getServiceFaqId(context, serviceId) async {
    try {
      await apiServices
          .getApi("${api.serviceFaq}?service_id=$serviceId", [],
              isData: true, isMessage: false)
          .then((value) {
        if (value.isSuccess!) {
          serviceFaq.clear();
          for (var d in value.data) {
            if (!serviceFaq.contains(ServiceFaqModel.fromJson(d))) {
              serviceFaq.add(ServiceFaqModel.fromJson(d));
            }
          }
          log("serviceFaq :${serviceFaq.length}");
          hideLoading(context);
          notifyListeners();
        } else {
          hideLoading(context);
          notifyListeners();
        }
      });
    } catch (e, s) {
      log("ERRROEEE getServiceFaqId : $e===> $s");
      hideLoading(context);
      notifyListeners();
    }
  }

  onFeatured(context, services, id) async {
    final providerDetail =
        Provider.of<ProviderDetailsProvider>(context, listen: false);
    providerDetail.selectProviderIndex = 0;
    providerDetail.notifyListeners();
    onBook(context, services!,
        addTap: () => onAdd(id: id),
        minusTap: () => onRemoveService(context, id: id)).then((e) {
      service!.relatedServices![id]!.selectedRequiredServiceMan =
          service!.relatedServices![id].requiredServicemen!;
      notifyListeners();
    });
  }

  onRemoveService(context, {id}) async {
    if (id != null) {
      if ((service!.relatedServices![id].selectedRequiredServiceMan!) == 1) {
        route.pop(context);
        isAlert = false;
        notifyListeners();
      } else {
        if ((service!.relatedServices![id].requiredServicemen!) ==
            (service!.relatedServices![id].selectedRequiredServiceMan!)) {
          isAlert = true;
          notifyListeners();
          await Future.delayed(DurationClass.s3);
          isAlert = false;
          notifyListeners();
        } else {
          isAlert = false;
          notifyListeners();
          service!.relatedServices![id].selectedRequiredServiceMan =
              ((service!.relatedServices![id].selectedRequiredServiceMan!) - 1);
        }
      }
    } else {
      if ((service!.selectedRequiredServiceMan!) == 1) {
        route.pop(context);
        isAlert = false;
        notifyListeners();
      } else {
        if ((service!.requiredServicemen!) ==
            (service!.selectedRequiredServiceMan!)) {
          isAlert = true;
          notifyListeners();
          await Future.delayed(DurationClass.s3);
          isAlert = false;
          notifyListeners();
        } else {
          isAlert = false;
          notifyListeners();
          service!.selectedRequiredServiceMan =
              ((service!.selectedRequiredServiceMan!) - 1);
        }
      }
    }
    notifyListeners();
  }

  onAdd({id}) {
    log("count:::");
    isAlert = false;
    notifyListeners();
    if (id != null) {
      log("count:::$id");
      int count = (service!.relatedServices![id].selectedRequiredServiceMan!);
      count++;
      service!.relatedServices![id].selectedRequiredServiceMan = count;
    } else {
      int count = (service!.selectedRequiredServiceMan!);
      log("count:::$count");
      count++;
      service!.selectedRequiredServiceMan = count;
    }
    notifyListeners();
  }

  /* dynamic data;
  onChatTap(context) {
    log("onChatTap::");

    final chat = Provider.of<ChatHistoryProvider>(context, listen: false);
    for (var doc in chat.chatHistory) {
      final data = doc.data() as Map<String, dynamic>;
      log("Receiver Name: ${data['receiverName']}");
    }
    List filteredChat = chat.chatHistory.where((doc) {
      data = doc.data() as Map<String, dynamic>;
      return data['receiverName'] == service!.user!.name
          ? data['receiverName'] == service!.user!.name
          : data = null;
    }).toList();

// Log the result
    for (var doc in filteredChat) {
      data = doc.data() as Map<String, dynamic>;
      log("✅ Matched Chat Data: $data");
    }

    notifyListeners();
    log("Chat DATA : ${data?['chatId'] ?? ''}");
    route.pushNamed(context, routeName.providerChatScreen, arg: {
      "image": service!.user!.media.isNotEmpty
          ? service!.user!.media[0].originalUrl!
          : "",
      "name": service!.user!.name,
      "role": "user",
      "userId": service!.user!.id,
      "chatId": data?['chatId'] ?? ''
      // "token": service!.user!.fcmToken,
      // "phone": service!.user!.phone,
      // "code": service!.user!.code,
    }).then((value) => data = null, data = [], data = {}, data = "");

    notifyListeners();
  } */

  dynamic data;

  Future<void> onHomeChatTap(BuildContext context, {var user}) async {
    log("onChatTap:: ${user.name}");

    final chat = Provider.of<ChatHistoryProvider>(context, listen: false);
    Map<String, dynamic>? data;

    List filteredChat = chat.chatHistory.where((doc) {
      final docData = doc.data() as Map<String, dynamic>;
      return docData['receiverId'].toString() == user.id.toString();
    }).toList();

    if (filteredChat.isNotEmpty) {
      data = filteredChat.first.data();
      log("✅ Matched Chat Data: $data");
    } else {
      log("❌ No matched chat data found.");
    }

    final imageUrl =
        user.media?.isNotEmpty == true ? user.media![0].originalUrl ?? "" : "";

    await route.pushNamed(
      context,
      routeName.providerChatScreen,
      arg: {
        "image": imageUrl,
        "name": user.name,
        "role": "user",
        "userId": user.id,
        "token": user.fcmToken,
        "phone": user.phone,
        "code": user.code,
        if (data != null) "chatId": data['chatId'],
      },
    );

    // Optional: clear after returning
    data = null;
  }

  onChatTap(BuildContext context) {
    log("onChatTap::");

    final chat = Provider.of<ChatHistoryProvider>(context, listen: false);

    // Filter matched chats
    List filteredChat = chat.chatHistory.where((doc) {
      final docData = doc.data() as Map<String, dynamic>;
      return docData['receiverName'] == service?.user?.name;
    }).toList();

    // If match found, set data and log
    if (filteredChat.isNotEmpty) {
      final matchedDoc = filteredChat.first;
      data = matchedDoc.data();
      log("✅ Matched Chat Data: $data");
    } else {
      data = null;
      log("❌ No matched chat data found.");
    }

    notifyListeners();
    log("fcm_token:::${service!.user!.fcmToken}");
    data == null
        ? route.pushNamed(
            context,
            routeName.providerChatScreen,
            arg: {
              "image": service!.user!.media.isNotEmpty
                  ? service!.user!.media[0].originalUrl!
                  : "",
              "name": service!.user!.name,
              "role": "user",
              "userId": service!.user!.id,
              "token": service!.user!.fcmToken,
            },
          )
        : route.pushNamed(
            context,
            routeName.providerChatScreen,
            arg: {
              "image": service!.user!.media.isNotEmpty
                  ? service!.user!.media[0].originalUrl!
                  : "",
              "name": service!.user!.name,
              "role": "user",
              "userId": service!.user!.id,
              "chatId": data?['chatId'] ?? '',
              'token': service!.user!.fcmToken,
            },
          ).then((_) {
            data = null; // clear after return
            notifyListeners();
          });
  }
}
 */
import 'dart:developer';

import 'package:fixit_user/common_tap.dart';
import 'package:fixit_user/config.dart';

import '../../models/service_details_model.dart';

class ServicesDetailsProvider with ChangeNotifier {
  int selectedIndex = 0, selected = -1;
  bool isBottom = true;
  int? serviceId;
  ScrollController scrollController = ScrollController();
  double widget1Opacity = 0.0;

  ServiceDetailsModel? service;
  List<ServiceFaqModel> serviceFaq = [];
  List<AdditionalService> additionalService = [];

  /* final Map<int, int> counts = {}; // index -> count
 


  int getCount(int index) => counts[index] ?? 1;

  void increment(int index) {
    counts[index] = (counts[index] ?? 1) + 1;

    notifyListeners();
  }

  void decrement(int index) {
    if ((counts[index] ?? 1) > 1) {
      counts[index] = (counts[index] ?? 1) - 1;
      notifyListeners();
    }
  }
 */

  // Set data after API fetch
  void setServices(List<AdditionalService> newServices) {
    additionalService = newServices.map((s) {
      s.qty = s.qty == 0 ? 1 : s.qty; // default qty = 1
      return s;
    }).toList();
    notifyListeners();
  }

  // Get qty safely
  int getCount(int index) {
    if (index < 0 || index >= additionalService.length) return 0;
    return additionalService[index].qty ?? 0;
  }

  // Increment qty
  void increment(int index) {
    if (index < 0 || index >= additionalService.length) return;
    additionalService[index].qty = (additionalService[index].qty ?? 0) + 1;
    notifyListeners();
  }

  // Decrement qty
  void decrement(int index) {
    if (index < 0 || index >= additionalService.length) return;
    if ((additionalService[index].qty ?? 0) > 1) {
      additionalService[index].qty = (additionalService[index].qty ?? 1) - 1;
      notifyListeners();
    }
  }

  onImageChange(index) {
    selectedIndex = index;
    isVideo = false;
    notifyListeners();
  }

  bool isVideo = false;

  onVideo() {
    isVideo = true;
    notifyListeners();
  }

  bool isContain(id) =>
      additionalService.where((element) => element.id == id).isNotEmpty;

  addAdditionalService(data) {
    log("hdyfudgsdl");
    int index =
        additionalService.indexWhere((element) => element.id == data.id);
    if (index >= 0) {
      additionalService.removeAt(index);
    } else {
      additionalService.add(data);
    }
    notifyListeners();
  }

  void clearAdditionalServices() {
    additionalService.clear();
    log("Cleared additional services.");
    notifyListeners();
  }

  onReady(context) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.setString(session.booking, "booking");

      widget1Opacity = 1.0;
      scrollController.addListener(listen);
      notifyListeners();

      dynamic data = ModalRoute.of(context)!.settings.arguments;

      // int? serviceId;
      getServiceFaqId(context, data['serviceId']);
      // await pref.setInt("lastOpenedServiceId", data['serviceId']);

      // final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      // chatProvider.onReady(context);

      /* if (data != null) {
        if (data['serviceId'] != null) {
          serviceId = data['serviceId'];
        } else if (data['services'] != null && data['services'] is Services) {
          service = data['services'];
          serviceId = service!.id;
        }
      }

      if (serviceId != null) {
        await Future.wait([
          getServiceById(context, serviceId),
          // getRelatedServices(context, serviceId), // Fetch related services
        ]);
      } else {
        log('Error: No service ID provided');
        widget1Opacity = 0.0; // Show shimmer or error state
        notifyListeners();
      }*/
    } catch (e) {
      log('Error in onReady: $e');
      widget1Opacity = 0.0;
      notifyListeners();
    }
  }

/*
  onReady(context) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString(session.booking, "booking");
    widget1Opacity = 1;
    scrollController.addListener(listen);

    notifyListeners();
    dynamic data = ModalRoute.of(context)!.settings.arguments;

    if (data['serviceId'] != null) {
      await Future.wait([
        getServiceById(context, service!.id),
        getServiceFaqId(context, service!.id)
      ]);
    } else {
      service = data['services'];
      notifyListeners();
      await Future.wait([
        Future(
          () {
            getServiceById(context, service!.id);
            getServiceFaqId(context, service!.id);
          },
        )
      ]);
    }
    notifyListeners();
    */
/*  Future.delayed(const Duration(milliseconds: 500), () {
      widget1Opacity = 1;
      notifyListeners();
    }); */ /*

    notifyListeners();
  }
*/

  onRefresh(context) async {
    showLoading(context);
    notifyListeners();
    await getServiceById(context, service!.id);
    await getServiceFaqId(context, service!.id);

    notifyListeners();
  }

  @override
  void dispose() {
    // Remove the listener before disposing the controller
    scrollController.removeListener(listen);
    scrollController.dispose();
    super.dispose();
  }

  onExpansionChange(newState, index) {
    log("dghfdkg:$newState");
    if (newState) {
      const Duration(seconds: 20000);
      selected = index;
      notifyListeners();
    } else {
      selected = -1;
      notifyListeners();
    }
  }

  void listen() {
    if (scrollController.position.pixels >= 200) {
      hide();
      notifyListeners();
    } else {
      show();
      notifyListeners();
    }
  }

  void show() {
    if (!isBottom) {
      isBottom = true;
      notifyListeners();
    }
    notifyListeners();
  }

  void hide() {
    if (isBottom) {
      isBottom = false;
      notifyListeners();
    }
    notifyListeners();
  }

  onBack(context, isBack) async {
    // service = null;

    serviceFaq = [];
    selectedIndex = 0;
    // serviceId = 0;
    widget1Opacity = 0.0;
    isVideo = false;

    notifyListeners();
    // log("djhfkf :$service");
    // SharedPreferences pref = await SharedPreferences.getInstance();
    /* if (pref.getString(session.booking) == 'booking') {
      route.pushReplacementNamed(context, routeName.dashboard);
    }*/
    if (isBack) {
      // route.pop(context);
      Navigator.pop(context);
    } else {
      log("back else");
      if (Navigator.of(context).canPop()) {
        Navigator.pop(context);
      }
    }
  }

  bool isLoading = false;

  Future<void> getServiceById(context, serviceId) async {
    isLoading = true;
    try {
      await apiServices
          .getApi("${api.service}/$serviceId", [], isToken: true)
          .then((value) {
        if (value.isSuccess!) {
          log("value.isSuccess service :::${value.data}");
          service = ServiceDetailsModel.fromJson(value.data);
          if (context.mounted) {
            hideLoading(context);
          }
          isLoading = false;
          notifyListeners();
        } else {
          hideLoading(context);
          isLoading = false;
          notifyListeners();
        }
      });
    } catch (e) {
      log("ERRROEEE SERVICE getServiceById : $e");
      isLoading = false;
      hideLoading(context);
      notifyListeners();
    }
  }

  Future<void> getServiceFaqId(context, serviceId) async {
    try {
      await apiServices
          .getApi("${api.serviceFaq}?service_id=$serviceId", [],
              isData: true, isMessage: false)
          .then((value) {
        if (value.isSuccess!) {
          serviceFaq.clear();
          for (var d in value.data) {
            if (!serviceFaq.contains(ServiceFaqModel.fromJson(d))) {
              serviceFaq.add(ServiceFaqModel.fromJson(d));
            }
          }
          log("serviceFaq :${serviceFaq.length}");
          hideLoading(context);
          notifyListeners();
        } else {
          hideLoading(context);
          notifyListeners();
        }
      });
    } catch (e, s) {
      log("ERRROEEE getServiceFaqId : $e===> $s");
      hideLoading(context);
      notifyListeners();
    }
  }

  onFeatured(context, services, id) async {
    final providerDetail =
        Provider.of<ProviderDetailsProvider>(context, listen: false);
    providerDetail.selectProviderIndex = 0;
    providerDetail.notifyListeners();
    onBook(context, services!,
        addTap: () => onAdd(id: id),
        minusTap: () => onRemoveService(context, id: id)).then((e) {
      service!.relatedServices![id].selectedRequiredServiceMan =
          service!.relatedServices![id].requiredServicemen!;
      notifyListeners();
    });
  }

  onRemoveService(context, {id}) async {
    if (id != null) {
      if ((service!.relatedServices![id].selectedRequiredServiceMan!) == 1) {
        route.pop(context);
        isAlert = false;
        notifyListeners();
      } else {
        if ((service!.relatedServices![id].requiredServicemen!) ==
            (service!.relatedServices![id].selectedRequiredServiceMan!)) {
          isAlert = true;
          notifyListeners();
          await Future.delayed(DurationClass.s3);
          isAlert = false;
          notifyListeners();
        } else {
          isAlert = false;
          notifyListeners();
          service!.relatedServices![id].selectedRequiredServiceMan =
              ((service!.relatedServices![id].selectedRequiredServiceMan!) - 1);
        }
      }
    } else {
      if ((service!.selectedRequiredServiceMan!) == 1) {
        route.pop(context);
        isAlert = false;
        notifyListeners();
      } else {
        if ((service!.requiredServicemen!) ==
            (service!.selectedRequiredServiceMan!)) {
          isAlert = true;
          notifyListeners();
          await Future.delayed(DurationClass.s3);
          isAlert = false;
          notifyListeners();
        } else {
          isAlert = false;
          notifyListeners();
          service!.selectedRequiredServiceMan =
              ((service!.selectedRequiredServiceMan!) - 1);
        }
      }
    }
    notifyListeners();
  }

  onAdd({id}) {
    log("count:::");
    isAlert = false;
    notifyListeners();
    if (id != null) {
      log("count:::$id");
      int count = (service!.relatedServices![id].selectedRequiredServiceMan!);
      count++;
      service!.relatedServices![id].selectedRequiredServiceMan = count;
    } else {
      int count = (service!.selectedRequiredServiceMan!);
      log("count:::$count");
      count++;
      service!.selectedRequiredServiceMan = count;
    }
    notifyListeners();
  }

  /* dynamic data;
  onChatTap(context) {
    log("onChatTap::");

    final chat = Provider.of<ChatHistoryProvider>(context, listen: false);
    for (var doc in chat.chatHistory) {
      final data = doc.data() as Map<String, dynamic>;
      log("Receiver Name: ${data['receiverName']}");
    }
    List filteredChat = chat.chatHistory.where((doc) {
      data = doc.data() as Map<String, dynamic>;
      return data['receiverName'] == service!.user!.name
          ? data['receiverName'] == service!.user!.name
          : data = null;
    }).toList();

// Log the result
    for (var doc in filteredChat) {
      data = doc.data() as Map<String, dynamic>;
      log("✅ Matched Chat Data: $data");
    }

    notifyListeners();
    log("Chat DATA : ${data?['chatId'] ?? ''}");
    route.pushNamed(context, routeName.providerChatScreen, arg: {
      "image": service!.user!.media.isNotEmpty
          ? service!.user!.media[0].originalUrl!
          : "",
      "name": service!.user!.name,
      "role": "user",
      "userId": service!.user!.id,
      "chatId": data?['chatId'] ?? ''
      // "token": service!.user!.fcmToken,
      // "phone": service!.user!.phone,
      // "code": service!.user!.code,
    }).then((value) => data = null, data = [], data = {}, data = "");

    notifyListeners();
  } */

  dynamic data;

  Future<void> onHomeChatTap(BuildContext context, {var user}) async {
    log("onChatTap:: ${user.name}");

    final chat = Provider.of<ChatHistoryProvider>(context, listen: false);
    Map<String, dynamic>? data;

    List filteredChat = chat.chatHistory.where((doc) {
      final docData = doc.data() as Map<String, dynamic>;
      return docData['receiverId'].toString() == user.id.toString();
    }).toList();

    if (filteredChat.isNotEmpty) {
      data = filteredChat.first.data();
      log("✅ Matched Chat Data: $data");
    } else {
      log("❌ No matched chat data found.");
    }

    final imageUrl =
        user.media?.isNotEmpty == true ? user.media![0].originalUrl ?? "" : "";

    await route.pushNamed(
      context,
      routeName.providerChatScreen,
      arg: {
        "image": imageUrl,
        "name": user.name,
        "role": "user",
        "userId": user.id,
        "token": user.fcmToken,
        "phone": user.phone,
        "code": user.code,
        if (data != null) "chatId": data['chatId'],
      },
    );

    // Optional: clear after returning
    data = null;
  }

  onChatTap(BuildContext context) {
    log("onChatTap::");

    final chat = Provider.of<ChatHistoryProvider>(context, listen: false);

    // Filter matched chats
    List filteredChat = chat.chatHistory.where((doc) {
      final docData = doc.data() as Map<String, dynamic>;
      return docData['receiverName'] == service?.user?.name;
    }).toList();

    // If match found, set data and log
    if (filteredChat.isNotEmpty) {
      final matchedDoc = filteredChat.first;
      data = matchedDoc.data();
      log("✅ Matched Chat Data: $data");
    } else {
      data = null;
      log("❌ No matched chat data found.");
    }

    notifyListeners();
    log("fcm_token:::${service!.user!.fcmToken}");
    data == null
        ? route.pushNamed(
            context,
            routeName.providerChatScreen,
            arg: {
              "image": service!.user!.media.isNotEmpty
                  ? service!.user!.media[0].originalUrl!
                  : "",
              "name": service!.user!.name,
              "role": "user",
              "userId": service!.user!.id,
              "token": service!.user!.fcmToken,
            },
          )
        : route.pushNamed(
            context,
            routeName.providerChatScreen,
            arg: {
              "image": service!.user!.media.isNotEmpty
                  ? service!.user!.media[0].originalUrl!
                  : "",
              "name": service!.user!.name,
              "role": "user",
              "userId": service!.user!.id,
              "chatId": data?['chatId'] ?? '',
              'token': service!.user!.fcmToken,
            },
          ).then((_) {
            data = null; // clear after return
            notifyListeners();
          });
  }
}
