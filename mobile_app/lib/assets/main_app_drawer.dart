import 'package:flutter/material.dart';

class MainAppDrawer extends StatelessWidget {
  const MainAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                Icons.home,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'Home',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'Settings',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
