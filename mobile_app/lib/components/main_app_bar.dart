import 'package:flutter/material.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        'FishMasters',
        style: TextStyle(color: theme.colorScheme.onPrimary),
      ),
      centerTitle: true,
      backgroundColor: theme.colorScheme.primary,
    );
  }
}
