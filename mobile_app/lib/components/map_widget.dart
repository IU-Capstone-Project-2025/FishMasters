import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile_app/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/models/water_model.dart';
import 'dart:convert';

class MapWidget extends StatelessWidget {
  const MapWidget({super.key});

  Future<List<WaterModel>> _fetchWaterPoints() async {
    final response = await http.get(
      Uri.parse('https://capstone.aquaf1na.fun/api/water/all'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((item) => WaterModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load water points');
    }
  }

  Future<List<Marker>> _buildMarkers(BuildContext context) async {
    final waterPoints = await _fetchWaterPoints();
    return waterPoints
        .map((wp) => MarkerUnit(x: wp.x, y: wp.y))
        .toList()
        .map((markerUnit) => markerUnit.build(context))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Fetch list of WaterPoints from the server
    return Center(
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(55.775000, 49.123611),
          initialZoom: 13.0,
          onTap: null,
        ),
        children: [
          TileLayer(
            retinaMode: true,
            urlTemplate:
                'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          FutureBuilder<List<Marker>>(
            future: _buildMarkers(context),
            builder: (context, snapshot) {
              return snapshot.connectionState == ConnectionState.waiting
                  ? Stack(
                      children: [
                        // Darken the map background
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.2),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.loadingMarkersLabel,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : MarkerLayer(markers: snapshot.data ?? []);
            },
          ),
        ],
      ),
    );
  }
}

class MarkerUnit {
  final double x;
  final double y;
  late final double id;

  MarkerUnit({required this.x, required this.y});

  Marker build(BuildContext context) {
    id = x * 1000 + y;
    var localizations = AppLocalizations.of(context);
    return Marker(
      point: LatLng(x, y),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(localizations!.fishingLocationLabel),
              content: Text(
                '$x, $y\n\n'
                'Здесь могла быть ваша рыбалка (placeholder)!',
              ),
              actions: [
                Card(
                  child: IconButton(
                    onPressed: () {
                      if (!Hive.isBoxOpen('settings')) {
                        Hive.openBox('settings');
                      }
                      var box = Hive.box('settings');
                      box.put('fishingLocationId', id);
                      box.put('fishingLocationX', x);
                      box.put('fishingLocationY', y);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Fishing location selected (id: $id).'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: const Icon(Icons.place_outlined),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/discussion');
                  },
                  child: Text(localizations.chatLabel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(localizations.closeLabel),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.location_on, color: Colors.red, size: 40.0),
      ),
    );
  }
}
