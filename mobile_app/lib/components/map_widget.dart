import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MapWidget extends StatelessWidget {
  const MapWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(55.775000, 49.1236111),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Marker'),
                        content: Text(
                          '55.775000, 49.1236111\n\n'
                          'Здесь могла быть ваша рыбалка!',
                        ),
                        actions: [
                          Card(
                            child: IconButton(
                              onPressed: () {
                                if (!Hive.isBoxOpen('settings')) {
                                  Hive.openBox('settings');
                                }
                                var box = Hive.box('settings');
                                box.put('fishingLocationId', 1);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Fishing location selected.'),
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
                            child: const Text('Discussion'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
