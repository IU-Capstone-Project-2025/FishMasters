import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DeveloperPage extends StatelessWidget {
  const DeveloperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Page'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        foregroundColor: Theme.of(context).colorScheme.onTertiary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (!Hive.isBoxOpen('settings')) {
                    Hive.openBox('settings');
                  }
                  var box = Hive.box('settings');
                  box.delete('fishingLocationId');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fishing location reset.'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: const Text('Reset Fishing Location'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
