import 'package:e_demand/app/generalImports.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSubCategories extends SubCategoryRepository {
  Map<String, dynamic>? cached;
  final List<Completer<Map<String, dynamic>>> requests = [];

  @override
  Map<String, dynamic>? cachedSubCategory({required String categoryID}) =>
      cached;

  @override
  Future<Map<String, dynamic>> fetchSubCategory({
    required bool isAuthTokenRequired,
    required String categoryID,
    bool saveToCache = false,
  }) {
    final c = Completer<Map<String, dynamic>>();
    requests.add(c);
    return c.future;
  }
}

class FakeProviders extends ProviderRepository {
  Map<String, dynamic>? cached;
  final List<Completer<Map<String, dynamic>>> requests = [];

  @override
  Map<String, dynamic>? cachedProviderList(Map<String, dynamic> parameter) =>
      cached;

  @override
  Future<Map<String, dynamic>> fetchProviderList({
    required bool isAuthTokenRequired,
    String? categoryId,
    String? providerIdOrSlug,
    String? subCategoryId,
    String? filter,
    String? promocode,
    ProviderDetailsParamType? type,
    int? availableToday,
    int? maxDuration,
    String? providerType,
    String? sortBy,
    double? ratingMin,
    double? priceMax,
    String? search,
    String? offset,
    String? limit,
    bool saveToCache = false,
  }) {
    final c = Completer<Map<String, dynamic>>();
    requests.add(c);
    return c.future;
  }
}

Map<String, dynamic> subs(final String fp) => {
  'subCategoryList': <SubCategory>[],
  'fingerprint': fp,
};

Map<String, dynamic> providers(final int count, final String fp) => {
  'providerList': List.generate(count, (_) => Providers()),
  'totalProviders': '$count',
  'serviceMinPrice': null,
  'serviceMaxPrice': null,
  'fingerprint': fp,
};

void main() {
  late FakeSubCategories subRepo;
  late FakeProviders providerRepo;
  late SubCategoryAndProviderCubit cubit;
  late List<SubCategoryAndProviderState> states;
  late Directory dir;

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('category_cache_test');
    Hive.init(dir.path);
    await Hive.openBox(HiveRepository.userDetailBoxKey);
    await Hive.openBox(HiveRepository.languageBoxKey);
  });

  tearDownAll(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  setUp(() {
    subRepo = FakeSubCategories();
    providerRepo = FakeProviders();
    cubit = SubCategoryAndProviderCubit(
      subCategoryRepository: subRepo,
      providerRepository: providerRepo,
    );
    states = [];
    cubit.stream.listen(states.add);
  });

  tearDown(() => cubit.close());

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  int shownProviders() =>
      (cubit.state as SubCategoryAndProviderFetchSuccess).providerList.length;

  test('subcategories and providers are requested in parallel', () async {
    final done = cubit.getSubCategoriesAndProviderList(categoryID: '6');
    expect(subRepo.requests.length, 1);
    expect(providerRepo.requests.length, 1, reason: 'not waiting on subcats');
    subRepo.requests.single.complete(subs('s1'));
    providerRepo.requests.single.complete(providers(3, 'p1'));
    await done;
    expect(shownProviders(), 3);
  });

  test('cached page shows at once; unchanged refresh does not rebuild', () async {
    subRepo.cached = subs('s1');
    providerRepo.cached = providers(2, 'p1');
    final done = cubit.getSubCategoriesAndProviderList(categoryID: '6');
    await settle();
    expect(states.single, isA<SubCategoryAndProviderFetchSuccess>());
    expect(shownProviders(), 2);

    subRepo.requests.single.complete(subs('s1'));
    providerRepo.requests.single.complete(providers(2, 'p1'));
    await done;
    await settle();
    expect(states.length, 1);
  });

  test('changed providers update the page', () async {
    subRepo.cached = subs('s1');
    providerRepo.cached = providers(2, 'p1');
    final done = cubit.getSubCategoriesAndProviderList(categoryID: '6');
    subRepo.requests.single.complete(subs('s1'));
    providerRepo.requests.single.complete(providers(5, 'p2'));
    await done;
    expect(shownProviders(), 5);
  });

  test('offline keeps cached providers (no error, no empty list)', () async {
    subRepo.cached = subs('s1');
    providerRepo.cached = providers(2, 'p1');
    final done = cubit.getSubCategoriesAndProviderList(categoryID: '6');
    subRepo.requests.single.completeError(ApiException('noInternetFound'));
    providerRepo.requests.single.completeError(
      ApiException('noInternetFound'),
    );
    await done;
    expect(shownProviders(), 2);
    expect(states.whereType<SubCategoryAndProviderFetchFailure>(), isEmpty);
  });

  test('a real "no providers" answer still empties the list', () async {
    subRepo.cached = subs('s1');
    providerRepo.cached = providers(2, 'p1');
    final done = cubit.getSubCategoriesAndProviderList(categoryID: '6');
    subRepo.requests.single.complete(subs('s1'));
    providerRepo.requests.single.completeError(ApiException('No data found'));
    await done;
    expect(shownProviders(), 0);
  });

  test('without cache: loading first, error if subcategories fail', () async {
    final done = cubit.getSubCategoriesAndProviderList(categoryID: '6');
    expect(cubit.state, isA<SubCategoryAndProviderFetchInProgress>());
    subRepo.requests.single.completeError(ApiException('noInternetFound'));
    providerRepo.requests.single.completeError(ApiException('x'));
    await done;
    expect(cubit.state, isA<SubCategoryAndProviderFetchFailure>());
  });
}
