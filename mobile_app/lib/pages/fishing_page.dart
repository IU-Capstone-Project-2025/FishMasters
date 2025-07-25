import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
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

    if (!Hive.isBoxOpen('settings')) {
      Hive.openBox('settings');
    }
    var box = Hive.box('settings');
    if (!box.get('fishingStarted', defaultValue: false)) {
      box.put('fishingStarted', true);
      fishingEventRequest(true);
    }
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
    var colorScheme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: colorScheme.secondary,
        automaticallyImplyLeading: true,
        title: Text(localizations!.fishingText, style: textTheme.displayMedium),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              localizations.fishingInProgress,
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _stopFishing(context),
              child: Text(
                localizations.stopFishingButton,
                style: textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              '${localizations.elapsedTime}: ${_formatDuration(_elapsedSeconds)}',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(localizations.fishCaught, style: textTheme.labelLarge),
                const SizedBox(width: 10),
                ValueListenableBuilder(
                  valueListenable: Hive.box(
                    'settings',
                  ).listenable(keys: ['fishCaught']),
                  builder: (context, Box box, _) {
                    int fishCaught =
                        box.get('fishCaught', defaultValue: 0) as int;
                    return Text('$fishCaught', style: textTheme.bodySmall);
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
                      style: textTheme.titleLarge,
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [ImageUploadField()],
                    ),
                  ),
                );
              },
              child: Text(
                localizations.addFishButton,
                style: textTheme.titleSmall,
              ),
            ),
            SizedBox(height: 30),
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
  bool _hasNetworkError = false;

  Future<void> _pickImage() async {
    _fishName = null;
    _hasNetworkError = false;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => _image = File(picked.path));
      debugPrint("Fetching fish name...");

      try {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('http://ml.aquaf1na.fun:5001/search_image'),
        );
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            _image!.path,
            filename: _image!.path.split('/').last,
            contentType: MediaType('image', 'jpeg'),
          ),
        );

        var streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        if (response.statusCode == 200) {
          final prediction = FishSearchResponseModel.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>,
          );
          setState(() {
            _fishName = prediction.results.isNotEmpty
                ? prediction.results.first.name.replaceAll('_', ' ')
                : null;
            debugPrint('Fish prediction: $_fishName');
            _isLoading = false;
          });
        } else {
          debugPrint('Fish prediction failed: ${response.statusCode}');
          debugPrint('Response body: ${response.body}');
          setState(() {
            _fishName = null;
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint('ML service unreachable: $e');
        setState(() {
          _fishName = null;
          _isLoading = false;
          _hasNetworkError = true;
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
    final fishId = 1;
    final weight = 1.0;
    final email = settingsBox.get('email', defaultValue: '').toString();
    debugPrint(
      'Uploading fish: fishingId: $fishingId, fishId: $fishId, weight: $weight, email: $email',
    );
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://capstone.aquaf1na.fun/api/caught-fish'),
    );
    request.headers['Content-Type'] = 'multipart/form-data';
    request.files.add(
      http.MultipartFile.fromString(
        'data',
        jsonEncode({
          "fishingId": fishingId,
          "fishId": fishId,
          "weight": weight,
          "fishName": _fishName ?? '',
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
    var textTheme = Theme.of(context).textTheme;
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
              ? Text(localizations!.noFishNameLabel, style: textTheme.bodySmall)
              : _isLoading
              ? Text(localizations!.loadingFishName, style: textTheme.bodySmall)
              : _hasNetworkError
              ? Text(
                  'Service unavailable. Please use manual upload.',
                  style: textTheme.bodySmall,
                )
              : _fishName == null
              ? Text(
                  'Fish not recognized. Please use manual upload.',
                  style: textTheme.bodySmall,
                )
              : Text(
                  '${localizations!.fishNameLabel}: $_fishName',
                  style: textTheme.bodySmall,
                ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            if (_image != null && !_isLoading && _fishName != null) {
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
            } else if (_image == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error: attach image first!'),
                  duration: Duration(seconds: 1),
                ),
              );
            } else if (_isLoading) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Please wait for fish identification to complete',
                  ),
                  duration: Duration(seconds: 1),
                ),
              );
            } else if (_fishName == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Fish identification failed or service unavailable. Please use manual upload.',
                  ),
                  duration: Duration(seconds: 3),
                ),
              );
            }
          },
          child: Text(
            localizations!.uploadFishImageButton,
            style: textTheme.bodySmall,
          ),
        ),
        TextButton(
          onPressed: () {
            // Dismiss keyboard before showing dialog
            FocusScope.of(context).unfocus();
            Navigator.of(context).pop();
            showDialog(
              context: context,
              builder: (context) => ManualUploadDialog(),
            );
          },
          child: Text(
            localizations.manualUploadButton,
            style: textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class ManualUploadDialog extends StatefulWidget {
  const ManualUploadDialog({super.key});

  @override
  State<ManualUploadDialog> createState() => _ManualUploadDialogState();
}

class _ManualUploadDialogState extends State<ManualUploadDialog> {
  final TextEditingController _fishNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<FishResultModel> _searchResults = [];
  bool _isSearching = false;
  FishResultModel? _selectedFish;

  @override
  void initState() {
    super.initState();
    _fishNameController.addListener(() {
      setState(() {}); // Trigger rebuild when text changes
    });
  }

  @override
  void dispose() {
    _fishNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _searchFishByDescription() async {
    if (_descriptionController.text.trim().isEmpty) return;

    // Dismiss keyboard before starting search
    FocusScope.of(context).unfocus();

    setState(() {
      _isSearching = true;
      _searchResults = [];
      _selectedFish = null;
    });

    try {
      final request = FishSearchRequestModel(
        description: _descriptionController.text.trim(),
        topK: 3, // Get top 3 results
      );

      final response = await http.post(
        Uri.parse('http://ml.aquaf1na.fun:5001/search'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      debugPrint(response.body);

      if (response.statusCode == 200) {
        final searchResponse = FishSearchResponseModel.fromJson(
          jsonDecode(response.body),
        );

        setState(() {
          _searchResults = searchResponse.results;
          _isSearching = false;
        });
      } else {
        debugPrint('Fish search failed: ${response.statusCode}');
        setState(() {
          _isSearching = false;
        });
      }
    } catch (e) {
      debugPrint('Fish search error: $e');
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _uploadFish(String fishName) async {
    if (!Hive.isBoxOpen('settings')) {
      await Hive.openBox('settings');
    }

    final settingsBox = Hive.box('settings');
    final fishingId = settingsBox.get("last_fishing_id");
    final fishId = 1;
    final weight = 1.0;
    final email = settingsBox.get('email', defaultValue: '').toString();
    debugPrint(
      'Uploading fish: fishingId: $fishingId, fishId: $fishId, weight: $weight, email: $email, fishName: $fishName',
    );
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://capstone.aquaf1na.fun/api/caught-fish'),
    );
    request.headers['Content-Type'] = 'multipart/form-data';
    request.files.add(
      http.MultipartFile.fromString(
        'data',
        jsonEncode({
          "fishingId": fishingId,
          "fishId": fishId,
          "weight": weight,
          "fishName": fishName,
          "fisherEmail": email,
        }),
        filename: 'data.json',
        contentType: MediaType('application', 'json'),
      ),
    );

    final response = await request.send();
    if (response.statusCode != 200) {
      debugPrint(
        'Manual upload failed: ${response.statusCode} ${response.reasonPhrase}',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Manual upload failed: ${response.reasonPhrase}'),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    // Increment fish caught counter
    var box = Hive.box('settings');
    int fishCaught = box.get('fishCaught', defaultValue: 0) as int;
    box.put('fishCaught', fishCaught + 1);

    debugPrint('Manual upload successful');
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context)!;
    var textTheme = Theme.of(context).textTheme;
    var colorTheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(localizations.manualUploadButton),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _fishNameController,
              decoration: InputDecoration(
                labelText: localizations.fishNameLabel,
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorTheme.outline, width: 2.0),
                ),
                labelStyle: textTheme.titleLarge,
              ),
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: localizations.fishDescriptionLabel,
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorTheme.outline, width: 2.0),
                ),
                hintText: 'e.g., "Small silver fish with blue fins"',
                labelStyle: textTheme.titleLarge,
              ),
              maxLines: 3,
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSearching ? null : _searchFishByDescription,
                child: _isSearching
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            localizations.searchingFishLabel,
                            style: textTheme.titleSmall,
                          ),
                        ],
                      )
                    : Text(
                        localizations.searchByDescriptionButton,
                        style: textTheme.titleSmall,
                      ),
              ),
            ),
            if (_searchResults.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(localizations.selectFishLabel, style: textTheme.bodySmall),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final fish = _searchResults[index];
                    final isSelected = _selectedFish?.id == fish.id;

                    return Card(
                      color: isSelected
                          ? Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.2)
                          : null,
                      child: ListTile(
                        title: Text(fish.name, style: textTheme.labelSmall),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${fish.genus} ${fish.species}',
                              style: textTheme.labelSmall,
                            ),
                            Text(
                              '${localizations.similarityScoreLabel}: ${(fish.similarityScore * 100).toStringAsFixed(2)}%',
                              style: textTheme.labelSmall,
                            ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            _selectedFish = fish;
                            _fishNameController.text = fish.name;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ] else if (_isSearching == false &&
                _descriptionController.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                localizations.noResultsFoundLabel,
                style: textTheme.labelLarge,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(localizations.cancelButton, style: textTheme.labelLarge),
        ),
        ElevatedButton(
          onPressed: _fishNameController.text.trim().isEmpty
              ? null
              : () async {
                  if (_selectedFish != null) {
                    _fishNameController.text = _selectedFish!.name;
                  }
                  await _uploadFish(_fishNameController.text.trim());

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fish added successfully!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                  Navigator.of(context).pop();
                },
          child: Text(
            localizations.uploadButton,
            style: TextStyle(
              color: _fishNameController.text.trim().isEmpty
                  ? colorTheme.onSurface
                  : colorTheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
