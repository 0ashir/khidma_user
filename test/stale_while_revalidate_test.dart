import 'package:e_demand/app/generalImports.dart';
import 'package:flutter_test/flutter_test.dart';

/// Home repository whose cache and network answers the test controls.
class FakeHomeRepository extends HomeScreenRepository {
  HomeScreenResponse? cached;
  final List<Completer<HomeScreenResponse>> requests = [];

  @override
  HomeScreenResponse? cachedHomeScreenData({
    required String latitude,
    required String longitude,
  }) => cached;

  @override
  Future<HomeScreenResponse> fetchHomeScreenResponse({
    required String latitude,
    required String longitude,
  }) {
    final c = Completer<HomeScreenResponse>();
    requests.add(c);
    return c.future;
  }
}

class InstantSettings extends SettingRepository {
  @override
  Future<CountrySettings> getCountrySettings({
    required String latitude,
    required String longitude,
  }) async => CountrySettings(currency: 'AED');
}

HomeScreenResponse response(final String fingerprint) => HomeScreenResponse(
  model: HomeScreenModel(const [], const []),
  fingerprint: fingerprint,
);

void main() {
  late Directory dir;

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('swr_test');
    Hive.init(dir.path);
    await Hive.openBox(HiveRepository.userDetailBoxKey);
    await Hive.openBox(HiveRepository.languageBoxKey);
    await ApiResponseCache.init();
  });

  tearDownAll(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  group('ApiResponseCache', () {
    test('round-trips a response and separates parameters', () async {
      final key = ApiResponseCache.keyFor('url/home', {'lat': '1'});
      final otherKey = ApiResponseCache.keyFor('url/home', {'lat': '2'});
      expect(key, isNot(otherKey));
      await ApiResponseCache.write(key, {
        'sliders': ['a'],
      });
      expect(ApiResponseCache.read(key), {
        'sliders': ['a'],
      });
      expect(ApiResponseCache.read(otherKey), isNull);
    });

    test('parameter order does not change the key', () {
      expect(
        ApiResponseCache.keyFor('u', {'a': 1, 'b': 2}),
        ApiResponseCache.keyFor('u', {'b': 2, 'a': 1}),
      );
    });

    test('clear (logout) removes everything', () async {
      final key = ApiResponseCache.keyFor('url/x', {});
      await ApiResponseCache.write(key, {'v': 1});
      await ApiResponseCache.clear();
      expect(ApiResponseCache.read(key), isNull);
    });
  });

  group('HomeScreenCubit', () {
    late FakeHomeRepository repo;
    late HomeScreenCubit cubit;
    late List<HomeScreenState> states;

    setUp(() {
      repo = FakeHomeRepository();
      cubit = HomeScreenCubit(repo, CountrySettingsCubit(InstantSettings()));
      states = [];
      cubit.stream.listen(states.add);
    });

    tearDown(() => cubit.close());

    test('shows cached data at once, no reload when unchanged', () async {
      repo.cached = response('v1');
      final done = cubit.fetchHomeScreenData();
      await Future<void>.delayed(Duration.zero);
      expect(states.single, isA<HomeScreenDataFetchSuccess>());

      repo.requests.single.complete(response('v1'));
      await done;
      await Future<void>.delayed(Duration.zero);
      expect(states.length, 1, reason: 'identical data must not rebuild');
    });

    test('updates the page when the server data changed', () async {
      repo.cached = response('v1');
      final done = cubit.fetchHomeScreenData();
      repo.requests.single.complete(response('v2'));
      await done;
      await Future<void>.delayed(Duration.zero);
      expect(states.length, 2);
      expect(states.last, isA<HomeScreenDataFetchSuccess>());
    });

    test('offline keeps the cached page instead of an error', () async {
      repo.cached = response('v1');
      final done = cubit.fetchHomeScreenData();
      repo.requests.single.completeError(ApiException('noInternetFound'));
      await done;
      await Future<void>.delayed(Duration.zero);
      expect(states.whereType<HomeScreenDataFetchFailure>(), isEmpty);
      expect(cubit.state, isA<HomeScreenDataFetchSuccess>());
    });

    test('without cache: loading, then data or error as before', () async {
      final done = cubit.fetchHomeScreenData();
      expect(cubit.state, isA<HomeScreenDataFetchInProgress>());
      repo.requests.single.completeError(ApiException('noInternetFound'));
      await done;
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, isA<HomeScreenDataFetchFailure>());
    });

    test('an older request finishing late cannot replace newer data', () async {
      final older = cubit.fetchHomeScreenData();
      final newer = cubit.fetchHomeScreenData();
      repo.requests[1].complete(response('new'));
      await newer;
      final HomeScreenState afterNewer = cubit.state;
      repo.requests[0].complete(response('old'));
      await older;
      expect(identical(cubit.state, afterNewer), isTrue);
    });
  });
}
