import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DeveloperPage extends StatelessWidget {
  const DeveloperPage({super.key});

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.secondary,
        automaticallyImplyLeading: true,
        title: Text(
          'Developer Page',
          style: textTheme.displayMedium,
        ),
        centerTitle: true,
        elevation: 0,
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
                child: Text('Reset Fishing Location', style: textTheme.titleSmall,),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
