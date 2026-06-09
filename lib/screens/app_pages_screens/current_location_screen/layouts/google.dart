import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:fixit_user/services/environment.dart';
import 'package:http/http.dart' as http;

import '../../../../config.dart';

class SearchLocation extends StatefulWidget {
  const SearchLocation({super.key});

  @override
  State<SearchLocation> createState() => _SearchLocationState();
}

class _SearchLocationState extends State<SearchLocation> {
  List placePredictions = [];
  FocusNode focusNode = FocusNode();
  TextEditingController search = TextEditingController();
  int _autocompleteRequestId = 0;
  bool _isNavigating = false;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    focusNode.dispose();
    search.dispose();
    super.dispose();
  }

  void placeAutoComplete(String query) {
    _debounceTimer?.cancel();
    if (query.isEmpty) {
      setState(() => placePredictions = []);
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 400), () => _fetchPredictions(query));
  }

  Future<void> _fetchPredictions(String query) async {
    final int requestId = ++_autocompleteRequestId;
    final String url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        "?input=${Uri.encodeComponent(query)}&key=$googleMapKey";

    try {
      var res = await http.get(Uri.parse(url));
      if (requestId != _autocompleteRequestId) return;
      if (res.statusCode == 200) {
        setState(() {
          placePredictions = jsonDecode(res.body)['predictions'] ?? [];
        });
      } else {
        log("placeAutoComplete error: ${res.body}");
      }
    } catch (e) {
      log("placeAutoComplete exception: $e");
    }
  }

  findCord(context, placeID) async {
    if (_isNavigating) return;
    _isNavigating = true;
    try {
      var d = await http.get(Uri.parse(
          "https://maps.googleapis.com/maps/api/place/details/json"
          "?place_id=$placeID&key=$googleMapKey"));
      dynamic a = jsonDecode(d.body);
      log("findCord result: ${a['result']['geometry']['location']}");
      final lat = a['result']['geometry']['location']['lat'];
      final lng = a['result']['geometry']['location']['lng'];
      route.pop(context, arg: LatLng(lat + 0.0, lng + 0.0));
    } catch (e) {
      log("findCord exception: $e");
      _isNavigating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarCommon(title: language(context, translations!.location)),
        body: ListView(
          children: [
            TextFieldCommon(
                    border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: appColor(context).stroke)),
                    focusNode: focusNode,
                    onChanged: (v) => placeAutoComplete(v),
                    controller: search,
                    hintText: language(context, translations!.searchHere),
                    prefixIcon: eSvgAssets.location)
                .paddingSymmetric(horizontal: Insets.i20),
            const VSpace(Sizes.s20),
            Divider(color: appColor(context).stroke, height: 0),
            if (placePredictions.isNotEmpty) const VSpace(Sizes.s20),
            ButtonCommon(
                margin: 20,
                onTap: () => route.pop(context),
                title: language(context, translations!.useCurrentLocation),
                icon: SvgPicture.asset(eSvgAssets.zipcode,
                    colorFilter: ColorFilter.mode(
                        appColor(context).whiteBg, BlendMode.srcIn))),
            const VSpace(Sizes.s20),
            ...placePredictions.asMap().entries.map((e) => LocationListTile(
                loc: e.value['description'],
                onTap: () {
                  log("dvghh:${e.value}");
                  findCord(context, e.value['place_id']);
                })),
          ],
        ));
  }
}

class LocationListTile extends StatelessWidget {
  final String? loc;
  final GestureTapCallback? onTap;

  const LocationListTile({super.key, this.loc, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SvgPicture.asset(eSvgAssets.location),
            const HSpace(Sizes.s10),
            Expanded(child: Text(loc ?? "")),
          ],
        ).inkWell(onTap: onTap),
        Divider(
          color: appColor(context).stroke,
          height: 0,
        ).paddingSymmetric(vertical: Sizes.s15)
      ],
    ).paddingSymmetric(horizontal: Sizes.s20);
  }
}
