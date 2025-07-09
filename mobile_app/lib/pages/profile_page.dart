import 'package:flutter/material.dart';
import 'package:mobile_app/functions/functions.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    var colorScheme = Theme.of(context).colorScheme;

    if (!Hive.isBoxOpen('settings')) {
      Hive.openBox('settings');
    }
    final settingsBox = Hive.box('settings');
    final email = settingsBox.get('email', defaultValue: 'example@example.com');
    final fullName = settingsBox.get('fullName', defaultValue: 'User Name');
    var photoPath = settingsBox.get('profilePhotoPath', defaultValue: null);
    if (photoPath != null) {
      if (!File(photoPath).existsSync()) {
        photoPath = null;
        settingsBox.delete('profilePhotoPath');
      }
    }
    

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations!.profileText),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(localizations.profilePictureEditTitle),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ImageUploaderWidget(
                            uri:
                                "https://capstone.aquaf1na.fun/auth/update-photo",
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primary, width: 3.0),
                ),
                child: CircleAvatar(
                  backgroundImage: photoPath != null
                      ? FileImage(File(photoPath))
                      : null,
                  backgroundColor: Colors.grey[400],
                  child: photoPath != null
                      ? null
                      : const Icon(Icons.person, size: 60, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(fullName, style: Theme.of(context).textTheme.headlineLarge),
              Text(
                email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bio: Fishing enthusiast, love exploring new spots!',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Text(
                '${localizations.scoreLabel}: ${settingsBox.get('score', defaultValue: 0)}',
                style: Theme.of(context).textTheme.headlineMedium,
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
                child: Text(localizations.logoutButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageUploaderWidget extends StatefulWidget {
  final String uri;

  const ImageUploaderWidget({super.key, required this.uri});

  @override
  State<ImageUploaderWidget> createState() => _ImageUploaderWidgetState();
}

class _ImageUploaderWidgetState extends State<ImageUploaderWidget> {
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _uploadImage() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }
    if (!Hive.isBoxOpen('settings')) {
      Hive.openBox('settings');
    }
    final settingsBox = Hive.box('settings');
    final email = settingsBox.get('email', defaultValue: '');
    final request = http.MultipartRequest('POST', Uri.parse(widget.uri));
    request.fields['email'] = email;
    request.files.add(
      await http.MultipartFile.fromPath(
        'photo',
        _image!.path,
        filename: _image!.path.split('/').last,
      ),
    );
    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully')),
        );
        settingsBox.put('profilePhotoPath', _image!.path);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    debugPrint("upload is complete");
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    if (!Hive.isBoxOpen('settings')) {
      Hive.openBox('settings');
    }
    final settingsBox = Hive.box('settings');
    final currentPhoto = settingsBox.get('profilePhotoPath', defaultValue: null);

    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 60,
            backgroundImage: _image != null
                ? FileImage(_image!)
                : currentPhoto != null
                  ? FileImage(File(currentPhoto))
                  : null,
            backgroundColor: Colors.grey[400],
            child: _image == null
                ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _uploadImage,
          child: Text(localizations!.uploadPictureButton),
        ),
      ],
    );
  }
}
