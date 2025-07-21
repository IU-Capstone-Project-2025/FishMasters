import 'package:flutter/material.dart';
import 'package:mobile_app/components/components.dart';
import 'dart:math';

import 'package:mobile_app/l10n/app_localizations.dart';

class CatchItem extends StatelessWidget {
  const CatchItem({
    super.key,
    required this.date,
    required this.duration,
    required this.fishCount,
    required this.fishNames,
  });

  final String date;
  final int duration;
  final int fishCount;
  final List<String> fishNames;

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var localizations = AppLocalizations.of(context);
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Text(
            date,
            style: textTheme.bodySmall,
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
                      "${duration != 0 ? duration : localizations!.lessThan} ${localizations!.hour}"
                      "${duration < 2 ? '' : 's'} - $fishCount ${localizations.fishNameLabel}",
                      style: textTheme.bodySmall,
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
                        if (fishNames.isEmpty) Text(localizations.noFishCought, style: textTheme.bodySmall),
                        if (fishNames.isNotEmpty)
                          FishItem(name: fishNames[0], highlighted: true),
                        if (fishNames.length > 1)
                          for (var i = 1; i < min(fishNames.length, 3); i++)
                            FishItem(name: fishNames[i]),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Details not implemented yet')),
                    );
                  },
                  child: Text(localizations.viewDetails, style: textTheme.bodySmall,),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
