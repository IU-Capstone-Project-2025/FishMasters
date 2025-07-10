import 'package:flutter/material.dart';
import 'package:mobile_app/l10n/app_localizations.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    var colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations!.menuText),
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(localizations.settingsLabel),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(localizations.aboutLabel),
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
          ListTile(
            leading: const Icon(Icons.developer_mode),
            title: const Text('Developer'),
            onTap: () {
              Navigator.pushNamed(context, '/developer');
            },
          ),
        ],
      ),
    );
  }
}
