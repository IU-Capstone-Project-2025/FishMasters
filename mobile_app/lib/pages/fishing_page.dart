import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mobile_app/l10n/app_localizations.dart';
import 'package:mobile_app/models/models.dart';

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
    fishingEventRequest(true);
  }

  void fishingEventRequest(bool isStart) async {
    if (!Hive.isBoxOpen('settings')) {
      await Hive.openBox('settings');
    }

    final name = isStart ? 'start' : 'end';

    final settingsBox = Hive.box('settings');
    final email = settingsBox.get('email', defaultValue: '').toString();

    final id = settingsBox.get('fishingLocationId') as double;
    final x = settingsBox.get('fishingLocationX') as double;
    final y = settingsBox.get('fishingLocationY') as double;

    final response = await http.post(
      Uri.parse('https://capstone.aquaf1na.fun/api/fishing/$name'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
        FishingSessionModel(
          fisherEmail: email,
          water: WaterModel(id: id, x: x, y: y),
        ).toJson(),
      ),
    );

    if (response.statusCode != 200) {
      debugPrint(
        'Fishing $name event failed: ${response.statusCode} ${response.reasonPhrase}',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fishing $name event failed: ${response.reasonPhrase}'),

          // Super SUS
          // content: Text("Fishing $name"),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    debugPrint('Fishing $name event: email: $email, Water: ($id, $x, $y)');

    if (isStart) {
      final responseJson = jsonDecode(response.body);
      settingsBox.put("last_fishing_id", responseJson["id"]);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fishing $name!'),
        duration: const Duration(seconds: 1),
      ),
    );
    if (!mounted) return;
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

    fishingEventRequest(false);

    box.put('fishingStarted', false);
    box.delete('fishingTime');
    box.delete('fishCaught');

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
    var localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations!.fishingText),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              localizations.fishingInProgress,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _stopFishing(context),
              child: Text(localizations.stopFishingButton),
            ),
            const SizedBox(height: 30),
            Text(
              '${localizations.elapsedTime}: ${_formatDuration(_elapsedSeconds)}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(localizations.fishCaught),
                const SizedBox(width: 10),
                ValueListenableBuilder(
                  valueListenable: Hive.box(
                    'settings',
                  ).listenable(keys: ['fishCaught']),
                  builder: (context, Box box, _) {
                    int fishCaught =
                        box.get('fishCaught', defaultValue: 0) as int;
                    return Text(
                      '$fishCaught',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // var box = Hive.box('settings');
                // int fishCaught = box.get('fishCaught', defaultValue: 0) as int;
                // box.put('fishCaught', fishCaught + 1);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      localizations.uploadFishImageText,
                      textAlign: TextAlign.center,
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [ImageUploadField()],
                    ),
                  ),
                );
              },
              child: Text(localizations.addFishButton),
            ),
            SizedBox(height: 30),
            // Text("Uploaded pictures:", style: const TextStyle(fontSize: 20),),
            // TODO: Show all uploaded pictures
          ],
        ),
      ),
    );
  }
}

class ImageUploadField extends StatefulWidget {
  const ImageUploadField({super.key});

  @override
  State<ImageUploadField> createState() => _ImageUploadFieldState();
}

class _ImageUploadFieldState extends State<ImageUploadField> {
  File? _image;
  String? _fishName;
  bool _isLoading = true;

  Future<void> _pickImage() async {
    _fishName = null;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => _image = File(picked.path));
      debugPrint("Fetching fish name...");
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://ml.aquaf1na.fun:5001/predict'),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _image!.path,
          filename: _image!.path.split('/').last,
        ),
      );
      var streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        debugPrint('Prediction successful: ${response.body}');
        final prediction = FishPredictionModel.fromJson(
          jsonDecode(response.body),
        );
        setState(() {
          _fishName = prediction.prediction;
          _isLoading = false;
        });
      } else {
        debugPrint('Prediction failed: ${response.statusCode}');
        setState(() {
          _fishName = null;
        });
      }
    }
  }

  void uploadFish() async {
    if (!Hive.isBoxOpen('settings')) {
      await Hive.openBox('settings');
    }

    final settingsBox = Hive.box('settings');
    final fishingId = settingsBox.get("last_fishing_id");
    // Hardcoded for now
    final fishId = 2;
    final weight = 5;
    final email = settingsBox.get('email', defaultValue: '').toString();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://capstone.aquaf1na.fun/api/caught-fish'),
    );
    request.files.add(
      http.MultipartFile.fromString(
        'data',
        jsonEncode({
          "fishingId": fishingId,
          "fishId": fishId,
          "weight": weight,
          "fisherEmail": email,
        }),
        filename: 'data.json',
        contentType: MediaType('application', 'json'),
      ),
    );
    request.files.add(
      await http.MultipartFile.fromPath(
        'photo',
        _image!.path,
        filename: _image!.path.split('/').last,
      ),
    );
    final response = await request.send();
    if (response.statusCode != 200) {
      debugPrint('Picture upload failed: ${response.statusCode}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // SUS
          content: Text('Picture uploaded'),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    debugPrint('Picture uploaded');
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
              image: _image != null
                  ? DecorationImage(
                      image: FileImage(_image!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _image == null
                ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          child: _image == null
              ? Text(localizations!.noFishNameLabel)
              : _isLoading
              ? Text(localizations!.loadingFishName)
              : _fishName == null
              ? Text('Error: ${localizations!.noFishNameLabel}')
              : Text(
                  '${localizations!.fishNameLabel}: $_fishName',
                  style: const TextStyle(fontSize: 16),
                ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            if (_image != null) {
              uploadFish();

              var box = Hive.box('settings');
              int fishCaught = box.get('fishCaught', defaultValue: 0) as int;
              box.put('fishCaught', fishCaught + 1);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fish added successfully!'),
                  duration: Duration(seconds: 1),
                ),
              );
              setState(() {
                _image = null;
              });
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error: attach image first!'),
                  duration: Duration(seconds: 1),
                ),
              );
            }
          },
          child: Text(localizations.uploadFishImageButton),
        ),
      ],
    );
  }
}
