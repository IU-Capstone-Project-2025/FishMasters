import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile_app/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/models/water_model.dart';
import 'dart:convert';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
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
          initialCenter: LatLng(55.904749, 48.726576),
          initialZoom: 15.0,
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
                  : MarkerLayer(markers: snapshot.data ?? [], rotate: true);
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

  void _handleDiscussion(BuildContext context) async {
    final response = await http.get(
      Uri.parse('https://capstone.aquaf1na.fun/api/water/$id'),
    );
    final water = WaterModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );

    if (water.discussion != null) {
      if (!context.mounted) return;
      Navigator.pushNamed(context, '/discussion', arguments: water.discussion);
    } else {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.noDiscussionTitle),
          content: Text(AppLocalizations.of(context)!.noDiscussionContent),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.cancelLabel),
            ),
            ElevatedButton(
              onPressed: () async {
                http.Response response = await http.post(
                  Uri.parse('https://capstone.aquaf1na.fun/api/discussion/$id'),
                );
                if (response.statusCode == 200) {
                  final discussionId = jsonDecode(response.body);
                  if (!context.mounted) return;
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.pushNamed(
                    context,
                    '/discussion',
                    arguments: discussionId,
                  );
                } else {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.errorCreatingDiscussion,
                      ),
                    ),
                  );
                }
              },
              child: Text(AppLocalizations.of(context)!.createDiscussionLabel),
            ),
          ],
        ),
      );
    }
  }

  Marker build(BuildContext context) {
    id = x * 1000 + y;
    var localizations = AppLocalizations.of(context);
    return Marker(
      point: LatLng(x, y),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              bool discussionIsLoading = false;
              return StatefulBuilder(
                builder: (context, setState) => AlertDialog(
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
                              content: Text(
                                'Fishing location selected (id: $id).',
                              ),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(Icons.place_outlined),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          discussionIsLoading = true;
                        });
                        _handleDiscussion(context);
                      },
                      child: discussionIsLoading
                          ? const SizedBox(
                              width: 40,
                              height: 20,
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(
                              width: 40,
                              height: 20,
                              child: Center(
                                child: Text(localizations.chatLabel),
                              ),
                            ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(localizations.closeLabel),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.location_on, color: Colors.red, size: 40.0),
      ),
    );
  }
}
