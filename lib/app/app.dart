import 'package:e_demand/app/generalImports.dart';
import 'package:e_demand/app/registerBlocks.dart';
import 'package:flutter/material.dart';

/// Starts Flutter immediately so the native splash is dismissed on the first
/// frame; all startup work runs behind [BrandSplash] in [_AppBootstrap].
void initApp() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _AppBootstrap());
}

Future<void> _initServices() async {
  //locked in portrait mode only
  final orientation = SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  FirebaseMessaging.onBackgroundMessage(onBackgroundMessageHandler);

  await Hive.initFlutter();
  await HiveRepository.init();
  await AppLocalization.preloadBundled();
  await orientation;

  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_outlined,
            color: Colors.red,
            size: 100,
          ),
          CustomText(errorDetails.exception.toString()),
        ],
      ),
    );
  };
}

/// Shows [BrandSplash] while [_initServices] runs, then mounts the real app
/// (blocs read Hive on creation, so they are only created afterwards).
class _AppBootstrap extends StatefulWidget {
  const _AppBootstrap();

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _initServices().then((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Directionality(
        textDirection: TextDirection.ltr,
        child: BrandSplash(),
      );
    }
    return MultiBlocProvider(providers: registerBlocks(), child: const App());
  }
}

class App extends StatefulWidget {
  const App({final Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    ClarityService.logAction(ClarityActions.appLaunch, {
      'timestamp': DateTime.now().toIso8601String(),
    });

    Future.delayed(Duration.zero).then((final value) {
      if (HiveRepository.isDarkThemeUsing) {
        context.read<AppThemeCubit>().changeTheme(AppTheme.dark);
      } else {
        context.read<AppThemeCubit>().changeTheme(AppTheme.light);
      }

      // Fire-and-forget: nothing here blocks the first frame. The cubit
      // renders the cache (or the fallback) immediately and only rebuilds
      // the theme if this brings back a palette that differs from it.
      context.read<ThemePaletteCubit>().refresh();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        ClarityService.logAction(ClarityActions.appResume, {
          'timestamp': DateTime.now().toIso8601String(),
        });
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        ClarityService.logAction(ClarityActions.appBackground, {
          'timestamp': DateTime.now().toIso8601String(),
          'state': state.name,
        });
        break;
    }
  }

  @override
  Widget build(final BuildContext context) => Builder(
    builder: (final context) {
      final AppTheme currentTheme = context
          .watch<AppThemeCubit>()
          .state
          .appTheme;
      // Watched, not read: when the admin palette arrives the cubit emits and
      // the theme rebuilds under every screen. Today it always holds the
      // committed fallback, because refresh() is not called yet (see initState).
      final KigenPrimitives palette = context
          .watch<ThemePaletteCubit>()
          .primitives;
      return BlocBuilder<LanguageDataCubit, LanguageDataState>(
        builder: (context, languageState) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: MicrosoftClarityInitializer(
              projectId: microsoftClarityProjectId,
              child: MaterialApp(
                theme: buildAppTheme(currentTheme, palette),
                title: appName,
                debugShowCheckedModeBanner: false,
                navigatorKey: UiUtils.rootNavigatorKey,
                navigatorObservers: [clarityRouteObserver],
                onGenerateRoute: Routes.onGeneratedRoute,
                initialRoute: splashRoute,
                builder: (context, child) {
                  TextDirection direction = TextDirection.ltr;
                  if (languageState is GetLanguageDataSuccess) {
                    direction = languageState.currentLanguage.isRtl == "1"
                        ? TextDirection.rtl
                        : TextDirection.ltr;
                  }
                  return Directionality(
                    textDirection: direction,
                    child: AnnotatedRegion<SystemUiOverlayStyle>(
                      value: UiUtils.getSystemUiOverlayStyle(context: context),
                      child: ColoredBox(
                        color: context.colors.backgroundPrimary,
                        child: ValueListenableBuilder<bool>(
                          valueListenable: UiUtils.drawBehindNavigationBar,
                          child: child,
                          builder: (context, drawBehind, child) => SafeArea(
                            top: false,
                            bottom: Platform.isAndroid && !drawBehind,
                            child: child!,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                localizationsDelegates: const [
                  AppLocalization.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                locale: loadLocalLanguageIfFail(languageState),
              ),
            ),
          );
        },
      );
    },
  );

  dynamic loadLocalLanguageIfFail(LanguageDataState state) {
    if (state is GetLanguageDataSuccess) {
      return Locale(state.currentLanguage.languageCode);
    } else if (state is GetLanguageDataError) {
      return const Locale("en");
    }
  }
}

///To remove scroll-glow from the ListView/GridView etc..
class CustomScrollBehaviour extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    final BuildContext context,
    final Widget child,
    final ScrollableDetails details,
  ) => child;
}

///To apply BouncingScrollPhysics() to every scrollable widget
class GlobalScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(final BuildContext context) =>
      const BouncingScrollPhysics();
}
