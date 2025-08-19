import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core_scroll_behavior.dart';
import 'pages/detail_page.dart';
import 'pages/main_list_page.dart';
import 'pages/favorites_page.dart';
import 'pages/settings_page.dart';
import 'pages/search_page.dart';
import 'theme.dart';
import 'providers/restaurant_providers.dart';
import 'services/restaurant_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static const _themePrefKey = 'dark_mode_enabled';

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themePrefKey) ?? false;
    setState(() => _mode = isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> _updateThemeMode(ThemeMode m) async {
    setState(() => _mode = m);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themePrefKey, m == ThemeMode.dark);
  }

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
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => RestaurantListProvider(const RestaurantService())),
          ChangeNotifierProvider(create: (_) => RestaurantDetailProvider(const RestaurantService())),
          ChangeNotifierProvider(create: (_) => RestaurantSearchProvider(const RestaurantService())),
        ],
        child: MaterialApp(
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
                  onThemeModeChanged: _updateThemeMode,
                ),
              ],
            ),
        '/detail': (_) => const DetailPage(),
        '/search': (_) => const SearchPage(),
      },
    ),
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
