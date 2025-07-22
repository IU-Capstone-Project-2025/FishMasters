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
  final String page;

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: FloatingActionButton(
        heroTag: heroTag,
        backgroundColor: colorScheme.secondary,
        shape: CircleBorder(
          side: BorderSide(color: colorScheme.onPrimary, width: 3.0),
        ),
        onPressed: () {
          Navigator.pushNamed(context, page);
        },
        foregroundColor: colorScheme.onPrimary,
        child: icon,
      ),
    );
  }
}
