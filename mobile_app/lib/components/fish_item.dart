import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FishItem extends StatelessWidget {
  final String name;
  final bool highlighted;

  const FishItem({super.key, required this.name, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    var colorTheme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.fishFins,
            size: 16,
            color: colorTheme.onSurface,
          ),
          const SizedBox(width: 6),
          Text(
            name,
            style: textTheme.labelLarge?.copyWith(
              color: highlighted ? colorTheme.onPrimary : colorTheme.onSurface,
              fontWeight: highlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
