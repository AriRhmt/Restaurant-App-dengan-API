import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core_scroll_behavior.dart';
import 'pages/detail_page.dart';
import 'pages/details_page.dart';
import 'pages/main_list_page.dart';
import 'pages/favorites_page.dart';
import 'pages/settings_page.dart';
import 'theme.dart';

void main() {
  runApp(const AppRoot());
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  ThemeMode _mode = ThemeMode.light;
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightDynamic, darkDynamic) {
      final light = AppTheme.light();
      final dark = AppTheme.dark();
      final theme = lightDynamic != null
          ? light.copyWith(colorScheme: lightDynamic.harmonized())
          : light;
      final darkTheme = darkDynamic != null
          ? dark.copyWith(colorScheme: darkDynamic.harmonized())
          : dark;
      return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Submission App',
      theme: theme,
      darkTheme: darkTheme,
      themeMode: _mode,
      builder: (context, child) => ScrollConfiguration(behavior: const AppScrollBehavior(), child: child!),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('id')],
      routes: {
        '/': (_) => _ScaffoldShell(
              index: _tab,
              onIndexChanged: (i) => setState(() => _tab = i),
              pages: [
                const MainListPage(),
                const FavoritesPage(),
                SettingsPage(
                  themeMode: _mode,
                  onThemeModeChanged: (m) => setState(() => _mode = m),
                ),
              ],
            ),
        '/detail': (_) => const DetailPage(),
        '/details': (_) => const DetailsPage(),
      },
    );
    });
  }
}

class _ScaffoldShell extends StatelessWidget {
  const _ScaffoldShell({required this.index, required this.onIndexChanged, required this.pages});
  final int index;
  final ValueChanged<int> onIndexChanged;
  final List<Widget> pages;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: onIndexChanged,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.restaurant_menu_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.favorite_rounded), label: 'Favorites'),
          NavigationDestination(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}
