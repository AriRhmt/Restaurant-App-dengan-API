import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage(
      {super.key, required this.themeMode, required this.onThemeModeChanged});
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const _consentKey = 'user_consent_allowed';
  bool _consentAllowed = false;

  @override
  void initState() {
    super.initState();
    _loadConsent();
  }

  Future<void> _loadConsent() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _consentAllowed = prefs.getBool(_consentKey) ?? false);
  }

  Future<void> _saveConsent(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: widget.themeMode == ThemeMode.dark,
            onChanged: (v) =>
                widget.onThemeModeChanged(v ? ThemeMode.dark : ThemeMode.light),
          ),
          const Divider(height: 0),
          SwitchListTile(
            title: const Text('Saya izinkan'),
            subtitle: const Text('Izinkan penggunaan data untuk peningkatan pengalaman aplikasi'),
            value: _consentAllowed,
            onChanged: (v) async {
              setState(() => _consentAllowed = v);
              await _saveConsent(v);
            },
          ),
        ],
      ),
    );
  }
}
