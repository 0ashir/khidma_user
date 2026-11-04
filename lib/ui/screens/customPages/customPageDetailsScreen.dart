import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class CustomPageDetailsScreen extends StatefulWidget {
  final String title;
  final String pageKey;

  const CustomPageDetailsScreen({
    Key? key,
    required this.title,
    required this.pageKey,
  }) : super(key: key);

  static Route route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>;
    return CupertinoPageRoute(
      builder: (_) => BlocProvider(
        create: (context) =>
            FetchCustomPageDetailsCubit(CustomPageRepository()),
        child: CustomPageDetailsScreen(
          title: arguments['title'] ?? '',
          pageKey: arguments['pageKey'] ?? '',
        ),
      ),
    );
  }

  @override
  State<CustomPageDetailsScreen> createState() =>
      _CustomPageDetailsScreenState();
}

class _CustomPageDetailsScreenState extends State<CustomPageDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      context.read<FetchCustomPageDetailsCubit>().fetchCustomPageDetails(
        pageKey: widget.pageKey,
      );
    });
  }

  List<Color> _extractGradientColors(String style) {
    final regex = RegExp('#([0-9a-fA-F]{6})');
    final matches = regex.allMatches(style);

    return matches.map((match) {
      final hex = match.group(0)!;
      return Color(int.parse('0xFF${hex.substring(1)}'));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedSafeArea(
      isAnnotated: true,
      applyBottomInset: false,
      child: Scaffold(
        backgroundColor: context.colors.surfaceElevated,
        appBar: UiUtils.getSimpleAppBar(context: context, title: widget.title),
        body:
            BlocBuilder<
              FetchCustomPageDetailsCubit,
              FetchCustomPageDetailsState
            >(
              builder: (context, state) {
                if (state is FetchCustomPageDetailsInProgress) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      10,
                      15,
                      10,
                      15 + MediaQuery.viewPaddingOf(context).bottom,
                    ),
                    child: Column(
                      children: List.generate(
                        15,
                        (index) => const CustomShimmerLoadingContainer(
                          height: 15,
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 10),
                        ),
                      ),
                    ),
                  );
                }

                if (state is FetchCustomPageDetailsFailure) {
                  return ErrorContainer(
                    errorMessage: state.errorMessage.translate(
                      context: context,
                    ),
                    onTapRetry: () {
                      context
                          .read<FetchCustomPageDetailsCubit>()
                          .fetchCustomPageDetails(pageKey: widget.pageKey);
                    },
                  );
                }

                if (state is FetchCustomPageDetailsSuccess) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      10,
                      15,
                      10,
                      15 + MediaQuery.viewPaddingOf(context).bottom,
                    ),
                    child: HtmlWidget(
                      state.content,
                      customWidgetBuilder: (element) {
                        final style = element.attributes['style'] ?? '';

                        if (style.contains('linear-gradient')) {
                          final colors = _extractGradientColors(style);

                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: colors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: HtmlWidget(
                              element.innerHtml,
                              textStyle: const TextStyle(color: Colors.white),
                            ),
                          );
                        }

                        return null;
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
      ),
    );
  }
}
