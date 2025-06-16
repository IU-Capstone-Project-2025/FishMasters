import 'package:flutter/material.dart';
import 'package:mobile_app/assets/assets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(),
      body: Stack(
        children: [
          Positioned.fill(child: MapWidget()),
          Positioned(
            top: 25,
            left: 25,
            child: FloatingActionButton(
              shape: CircleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2.0,
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Floating Action Button Pressed!'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Icon(Icons.menu),
            ),
          ),
          Positioned(
            top: 25,
            right: 25,
            child: FloatingActionButton(
              shape: CircleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2.0,
                ),
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
              shape: CircleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2.0,
                ),
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
              shape: CircleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2.0,
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Search Button Pressed!'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Icon(Icons.search),
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
                    Theme.of(context).colorScheme.primaryContainer,
                  ),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                child: const Text(
                  'GO',
                  style: TextStyle(fontSize: 24, color: Colors.black87),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
