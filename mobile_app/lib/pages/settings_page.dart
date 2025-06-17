import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
                    Text('Dark Mode', style: theme.textTheme.titleMedium),
                    Switch(value: false, onChanged: null),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Language', style: theme.textTheme.titleMedium),
                    const SizedBox(width: 16.0),
                    DropdownButton<String>(
                      value: 'English',
                      items: const [
                        DropdownMenuItem(
                          value: 'English',
                          child: Text('English'),
                        ),
                        DropdownMenuItem(
                          value: 'Russian',
                          child: Text('Russian'),
                        ),
                      ],
                      onChanged: null,
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Notifications', style: theme.textTheme.titleMedium),
                    Switch(value: false, onChanged: null),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Font Size', style: theme.textTheme.titleMedium),
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
