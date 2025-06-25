import 'package:flutter/material.dart';
import 'package:mobile_app/functions/functions.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.primary, width: 5.0),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                  'assets/images/profile_picture.png',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Username', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'Bio: Fishing enthusiast, love exploring new spots!',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await setLoggedIn(false);
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              child: Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
