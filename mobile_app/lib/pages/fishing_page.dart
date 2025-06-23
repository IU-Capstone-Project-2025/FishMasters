import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class FishingPage extends StatefulWidget {
  const FishingPage({super.key});

  @override
  State<FishingPage> createState() => _FishingPageState();
}

class _FishingPageState extends State<FishingPage> {
  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    if (!Hive.isBoxOpen('settings')) {
      Hive.openBox('settings');
    }
    var box = Hive.box('settings');
    if (!box.containsKey('fishingTime')) {
      debugPrint('No fishing time found, initializing to now');
      box.put('fishingTime', DateTime.now().toIso8601String());
    }
    String fishingStartTime = box.get('fishingTime') as String;
    _elapsedSeconds = DateTime.now()
        .difference(DateTime.parse(fishingStartTime))
        .inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _stopFishing(BuildContext context) async {
    debugPrint('Stop fishing button pressed');

    if (!Hive.isBoxOpen('settings')) {
      await Hive.openBox('settings');
    }
    var box = Hive.box('settings');
    box.put('fishingStarted', false);
    box.delete('fishingTime');

    if (!context.mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fishing stopped'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fishing'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Fishing in progress...',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text(
              'Elapsed time: ${_formatDuration(_elapsedSeconds)}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _stopFishing(context),
              child: const Text('Stop Fishing'),
            ),
          ],
        ),
      ),
    );
  }
}
