import 'package:flutter/material.dart';
import 'package:mobile_app/l10n/app_localizations.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    var colorScheme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        backgroundColor: colorScheme.secondary,
        automaticallyImplyLeading: true,
        title: Text(
          localizations!.menuText,
          style: textTheme.displayMedium,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(localizations.settingsLabel, style: textTheme.headlineSmall,),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(localizations.aboutLabel, style: textTheme.headlineSmall),
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.developer_mode),
          //   title: Text('Developer', style: textTheme.headlineSmall),
          //   onTap: () {
          //     Navigator.pushNamed(context, '/developer');
          //   },
          // ),
        ],
      ),
    );
  }
}
