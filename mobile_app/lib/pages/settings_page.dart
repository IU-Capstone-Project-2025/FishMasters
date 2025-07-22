import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mobile_app/Theme/theme_provider.dart';
import 'package:mobile_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.onLocaleChange});

  final Function(Locale) onLocaleChange;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    var colorScheme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    var localizations = AppLocalizations.of(context);

    if (!Hive.isBoxOpen('settings')) {
      Hive.openBox('settings');
    }
    final box = Hive.box('settings');
    final localeCode = box.get('locale', defaultValue: 'en');

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        backgroundColor: colorScheme.secondary,
        automaticallyImplyLeading: true,
        title: Text(
          localizations!.settingsLabel,
          style: textTheme.displayMedium,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(localizations.darkMode, style: textTheme.titleLarge),
                  Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) async {
                      themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: colorScheme.inverseSurface,
                          content: Text(
                            value ? localizations.darkModeEnabled : localizations.lightModeEnabled,
                            style: TextStyle(color: colorScheme.onInverseSurface),
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    //activeThumbColor: colorScheme.primary,
                    activeTrackColor: colorScheme.primaryContainer,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            // System Theme Switch
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(localizations.useSystemTheme, style: textTheme.titleLarge),
                  Switch(
                    value: themeProvider.isSystemMode,
                    onChanged: (value) async {
                      themeProvider.setThemeMode(value ? ThemeMode.system : ThemeMode.light);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: colorScheme.inverseSurface,
                          content: Text(
                            value ? localizations.systemModeEnabled : localizations.lightModeEnabled,
                            style: TextStyle(color: colorScheme.onInverseSurface),
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    activeTrackColor: colorScheme.primaryContainer,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localizations.languageLabel,
                    style: textTheme.titleLarge,
                  ),
                  const SizedBox(width: 16.0),
                  DropdownButton<String>(
                    value: localeCode,
                    items: [
                      DropdownMenuItem(
                        value: 'en',
                        child: Text(localizations.englishLanguage, style: textTheme.titleLarge,),
                      ),
                      DropdownMenuItem(
                        value: 'ru',
                        child: Text(localizations.russianLanguage, style: textTheme.titleLarge),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        widget.onLocaleChange(Locale(value));
                      }

                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
