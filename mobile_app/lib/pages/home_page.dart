import 'package:flutter/material.dart';
import 'package:mobile_app/assets/assets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: MainAppBar(), body: MapWidget());
  }
}
