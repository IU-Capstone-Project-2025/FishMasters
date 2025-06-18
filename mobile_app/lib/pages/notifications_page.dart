import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(8.0),
          children: [
            NotificationItem(),
            NotificationItem(),
            NotificationItem(),
            NotificationItem(),
            NotificationItem(),
            NotificationItem(),
          ],
        ),
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  const NotificationItem({super.key});

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: colorScheme.primaryContainer,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.onPrimaryContainer,
                    width: 1.0,
                  ),
                ),
                child: CircleAvatar(
                  radius: 15,
                  backgroundImage: AssetImage(
                    'assets/images/profile_picture.png',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "User1337228",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
        Card(
          elevation: 2,
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "March 18, 2025",
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  Text(
                    "That's a nice fish you caught!",
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Like clicked!"),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: Icon(Icons.favorite, color: colorScheme.primary),
                        label: const Text("12"),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Reply clicked!"),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: Icon(Icons.reply, color: colorScheme.primary),
                        label: const Text("Reply"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
