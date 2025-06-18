import 'package:flutter/material.dart';
import 'package:mobile_app/components/components.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PrimaryPage extends StatelessWidget {
  const PrimaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: MainAppBar(), body: PrimaryBody());
  }
}

class PrimaryBody extends StatelessWidget {
  const PrimaryBody({super.key});

  @override
  Widget build(BuildContext context) {
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
            heroTag: 'notificationsButton',
            icon: const Icon(Icons.notifications),
            page: '/notifications',
          ),
        ),

        Positioned(
          bottom: 25,
          left: MediaQuery.of(context).size.width / 2 - 50,
          child: SafeArea(
            child: SizedBox(
              width: 100,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Go Button Pressed!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                    colorScheme.primaryContainer,
                  ),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: BorderSide(color: colorScheme.primary, width: 2.0),
                    ),
                  ),
                ),
                child: const Text(
                  'GO',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
