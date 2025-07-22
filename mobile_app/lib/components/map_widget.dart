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
    var themeMode = Theme.of(context).colorScheme.brightness == Brightness.light
        ? "light"
        : "dark";
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
                'https://{s}.basemaps.cartocdn.com/${themeMode}_all/{z}/{x}/{y}{r}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          FutureBuilder<List<Marker>>(
            future: _buildMarkers(context),
            builder: (context, snapshot) {
              return snapshot.connectionState == ConnectionState.waiting
                  ? Stack(
                      children: [
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
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
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
    var textTheme = Theme.of(context).textTheme;
    final response = await http.get(
      Uri.parse('https://capstone.aquaf1na.fun/api/water/$id'),
    );
    final water = WaterModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );

    if (!context.mounted) return;
    Navigator.of(context).pop();
    if (water.discussion != null) {
      Navigator.pushNamed(
        context,
        '/discussion',
        arguments: water.discussion?.id,
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.noDiscussionTitle,
            style: textTheme.headlineSmall,
          ),
          content: Text(
            AppLocalizations.of(context)!.noDiscussionContent,
            style: textTheme.headlineSmall,
          ),
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
                  Navigator.of(context).pop();
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
              child: Text(
                AppLocalizations.of(context)!.createDiscussionLabel,
                style: textTheme.headlineSmall,
              ),
            ),
          ],
        ),
      );
    }
  }

  Marker build(BuildContext context) {
    if (!Hive.isBoxOpen('settings')) {
      Hive.openBox('settings');
    }
    var box = Hive.box('settings');
    var choosenId = box.get("fishingLocationId");
    choosenId ??= -1;
    id = x * 1000 + y;
    var localizations = AppLocalizations.of(context);
    return Marker(
      point: LatLng(x, y),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              var textTheme = Theme.of(context).textTheme;
              bool discussionIsLoading = false;
              return StatefulBuilder(
                builder: (context, setState) => AlertDialog(
                  titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  actionsPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    localizations!.fishingLocationLabel,
                    style: textTheme.headlineSmall,
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text('$x, $y', style: textTheme.titleSmall)],
                  ),
                  actions: [
                    // First row for icon actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Save location button
                        Tooltip(
                          message: localizations.saveLocationLabel,
                          child: choosenId == id
                              ? Text(
                                  localizations.selected,
                                  style: textTheme.titleSmall,
                                )
                              : TextButton(
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
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    localizations.select,
                                    style: textTheme.titleSmall,
                                  ),
                                ),
                        ),

                        // Close button
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: Text(
                            localizations.closeLabel,
                            style: textTheme.titleSmall,
                          ),
                        ),
                      ],
                    ),

                    // Second row for the main action button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          setState(() {
                            discussionIsLoading = true;
                          });
                          _handleDiscussion(context);
                        },
                        child: discussionIsLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.chat_outlined,
                                    size: 20,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    localizations.chatLabel,
                                    style: textTheme.titleSmall,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Icon(
          Icons.location_on,
          color: Theme.of(context).colorScheme.error,
          size: 40.0,
        ),
      ),
    );
  }
}
