import 'package:flutter/material.dart';

class PrimaryFloatingButton extends StatelessWidget {
  const PrimaryFloatingButton({
    super.key,
    required this.heroTag,
    required this.icon,
    required this.page,
  });

  final String heroTag;
  final Icon icon;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return FloatingActionButton(
      heroTag: heroTag,
      shape: CircleBorder(
        side: BorderSide(color: colorScheme.primary, width: 2.0),
      ),
      onPressed: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => page));
      },
      child: icon,
    );
  }
}
