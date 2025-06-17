import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FishItem extends StatelessWidget {
  final String name;
  final bool highlighted;

  const FishItem({super.key, required this.name, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(FontAwesomeIcons.fishFins, size: 18),
        const SizedBox(width: 6),
        Text(
          name,
          style: TextStyle(
            fontWeight: highlighted ? FontWeight.bold : FontWeight.normal,
            backgroundColor: highlighted
                ? Colors.grey.shade300
                : Colors.transparent,
          ),
        ),
        if (highlighted)
          const Padding(
            padding: EdgeInsets.only(left: 4.0),
            child: Text("•", style: TextStyle(fontSize: 20)),
          ),
      ],
    );
  }
}
