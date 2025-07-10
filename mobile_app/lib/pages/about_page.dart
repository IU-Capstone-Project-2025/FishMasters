import 'package:flutter/material.dart';
import 'package:mobile_app/l10n/app_localizations.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);

    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations!.aboutLabel),
        backgroundColor: theme.colorScheme.tertiary,
        foregroundColor: theme.colorScheme.onTertiary,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              localizations.appDescription,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'v1.0.0-alpha',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
