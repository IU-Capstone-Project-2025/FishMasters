import 'package:flutter/material.dart';
import 'package:mobile_app/components/components.dart';

class CatchItem extends StatelessWidget {
  const CatchItem({
    super.key,
    required this.date,
    required this.duration,
    required this.fishCount,
  });

  final String date;
  final int duration;
  final int fishCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.grey.shade400,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Text(
            date,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time),
                    SizedBox(width: 8),
                    Text(
                      "${duration != 0 ? duration : 'Less than an'} hour${duration < 2 ? '' : 's'} - $fishCount fish",
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(width: 32),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FishItem(name: "CARP", highlighted: true),
                        const FishItem(name: "STURGEON"),
                        const FishItem(name: "VOBLA"),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
