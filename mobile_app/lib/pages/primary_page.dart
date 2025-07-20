import 'package:flutter/material.dart';
import 'package:mobile_app/components/components.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile_app/l10n/app_localizations.dart';

class PrimaryPage extends StatelessWidget {
  const PrimaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: MainAppBar(), body: PrimaryBody());
  }
}

class PrimaryBody extends StatefulWidget {
  const PrimaryBody({super.key});

  @override
  State<PrimaryBody> createState() => _PrimaryBodyState();
}

class _PrimaryBodyState extends State<PrimaryBody> {
  Future<void> _startFishing(BuildContext context) async {
    debugPrint('Start fishing button pressed');

    if (!Hive.isBoxOpen('settings')) {
      await Hive.openBox('settings');
    }
    var box = Hive.box('settings');

    var fishingLocationId = box.get('fishingLocationId');
    if (fishingLocationId == null) {
      debugPrint('No fishing location selected');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a fishing location first.'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    debugPrint('Fishing...');

    if (!context.mounted) return;
    Navigator.pushNamed(context, '/fishing');
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    var colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Positioned.fill(child: MapWidget()),

        Positioned(
          top: 25,
          left: 25,
          child: PrimaryFloatingButton(
            heroTag: 'menuButton',
            icon: const Icon(Icons.menu),
            page: '/menu',
          ),
        ),

        Positioned(
          top: 25,
          right: 25,
          child: PrimaryFloatingButton(
            heroTag: 'profileButton',
            icon: const Icon(Icons.person),
            page: '/profile',
          ),
        ),

        Positioned(
          bottom: 25,
          right: 25,
          child: PrimaryFloatingButton(
            heroTag: 'catchButton',
            icon: const Icon(FontAwesomeIcons.fishFins),
            page: '/catch',
          ),
        ),

        Positioned(
          bottom: 25,
          left: 25,
          child: PrimaryFloatingButton(
            heroTag: 'leaderboardButton',
            icon: const Icon(Icons.leaderboard),
            page: '/notifications',
          ),
        ),

        ValueListenableBuilder(
          valueListenable: Hive.box('settings').listenable(),
          builder: (context, Box box, _) {
            bool fishingStarted = box.get(
              'fishingStarted',
              defaultValue: false,
            );
            return Positioned(
              bottom: 25,
              left:
                  MediaQuery.of(context).size.width / 2 -
                  (fishingStarted ? 100 : 50),
              child: SafeArea(
                child: SizedBox(
                  width: fishingStarted ? 200 : 100,
                  height: fishingStarted ? 80 : 60,
                  child: ElevatedButton(
                    onPressed: () => _startFishing(context),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                        colorScheme.primaryContainer,
                      ),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: BorderSide(
                            color: colorScheme.primary,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                    child: Text(
                      fishingStarted
                          ? localizations!.fishingInProgress
                          : localizations!.startFishingButton,
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
