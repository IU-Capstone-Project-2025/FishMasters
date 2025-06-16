import 'package:flutter/material.dart';

class CatchPage extends StatelessWidget {
  const CatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Catch'),
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
      ),
      body: Center(
        child: Text(
          'Catch Page',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
