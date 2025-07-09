import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mobile_app/l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.onLocaleChange});

  final Function(Locale) onLocaleChange;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);

    if (!Hive.isBoxOpen('settings')) {
      Hive.openBox('settings');
    }
    final box = Hive.box('settings');
    final localeCode = box.get('locale', defaultValue: 'en');

    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations!.settingsLabel),
        backgroundColor: theme.colorScheme.tertiary,
        foregroundColor: theme.colorScheme.onTertiary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localizations.darkModeLabel,
                      style: theme.textTheme.titleMedium,
                    ),
                    Switch(value: false, onChanged: null),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localizations.languageLabel,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(width: 16.0),
                    DropdownButton<String>(
                      value: localeCode,
                      items: [
                        DropdownMenuItem(
                          value: 'en',
                          child: Text(localizations.englishLanguage),
                        ),
                        DropdownMenuItem(
                          value: 'ru',
                          child: Text(localizations.russianLanguage),
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
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localizations.notificationsLabel,
                      style: theme.textTheme.titleMedium,
                    ),
                    Switch(value: false, onChanged: null),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localizations.fontSizeLabel,
                      style: theme.textTheme.titleMedium,
                    ),
                    DropdownButton<double>(
                      value: 14.0,
                      items: const [
                        DropdownMenuItem(value: 12.0, child: Text('12')),
                        DropdownMenuItem(value: 14.0, child: Text('14')),
                        DropdownMenuItem(value: 16.0, child: Text('16')),
                        DropdownMenuItem(value: 18.0, child: Text('18')),
                      ],
                      onChanged: null,
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Text(
              'Some functions are under development and may not work currently.',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
