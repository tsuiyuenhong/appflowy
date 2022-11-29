import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:example/home_page.dart';
import 'package:example/pages/collaborative_web_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:go_router/go_router.dart';

import 'config/desktop_config.dart'
    if (dart.library.html) 'config/web_config.dart';

void main() async {
  await configureApp();
  runApp(const MyApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/docs/:token',
      builder: (context, state) {
        final token = state.params['token'] ?? '';
        return CollaborativeWebPage(token: token);
      },
    )
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
      routeInformationProvider: _router.routeInformationProvider,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        AppFlowyEditorLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US')],
      debugShowCheckedModeBanner: false,
    );
  }
}
