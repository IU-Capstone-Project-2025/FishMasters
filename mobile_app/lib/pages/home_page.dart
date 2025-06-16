import 'package:flutter/material.dart';
import 'package:mobile_app/assets/assets.dart';
import 'package:mobile_app/assets/main_app_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(),
      body: HomeBody(),
      drawer: MainAppDrawer(),
    );
  }
}

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Positioned.fill(child: MapWidget()),
        Positioned(
          top: 25,
          left: 25,
          child: FloatingActionButton(
            heroTag: 'menuButton',
            shape: CircleBorder(
              side: BorderSide(color: colorScheme.primary, width: 2.0),
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            child: const Icon(Icons.menu),
          ),
        ),
        Positioned(
          top: 25,
          right: 25,
          child: FloatingActionButton(
            heroTag: 'profileButton',
            shape: CircleBorder(
              side: BorderSide(color: colorScheme.primary, width: 2.0),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Profile Button Pressed!'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Icon(Icons.person),
          ),
        ),
        Positioned(
          bottom: 25,
          right: 25,
          child: FloatingActionButton(
            heroTag: 'fishButton',
            shape: CircleBorder(
              side: BorderSide(color: colorScheme.primary, width: 2.0),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Boat Button Pressed!'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Icon(Icons.directions_boat_filled),
          ),
        ),
        Positioned(
          bottom: 25,
          left: 25,
          child: FloatingActionButton(
            heroTag: 'chatButton',
            shape: CircleBorder(
              side: BorderSide(color: colorScheme.primary, width: 2.0),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Chat Button Pressed!'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Icon(Icons.chat),
          ),
        ),
        Positioned(
          bottom: 25,
          left: MediaQuery.of(context).size.width / 2 - 50,
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
      ],
    );
  }
}
