import 'package:fixit_user/config.dart';
import 'package:fixit_user/models/appernce_model.dart';
import 'package:fixit_user/models/category_advertisement_model.dart';

import 'models/app_setting_model.dart';

UserModel? userModel;

PrimaryAddress? userPrimaryAddress;

String? currentAddress, street;

LatLng? position;

String zoneIds = "";

int? setPrimaryAddress;

List<Services> servicePackageList = [];

List<CategoryModel> allCategoryList = [];

List<CategoryModel> homeCategoryList = [];
List<CategoryModel> homeHasSubCategoryList = [];
List<ServicePackageModel> homeServicePackagesList = [];
List<ProviderModel> homeProvider = [];
List<BlogModel> homeBlog = [];
List<Services> homeFeaturedService = [];
List<Services> homeServicesAdvertisements = [];
// AppearanceModel? appearanceList;
AppearanceModel? appearance;
CategoryAdvertisementModel? fetchBannerAds;
List<OnboardingModel> onboardingScreens = [];

bool? isGuest;
