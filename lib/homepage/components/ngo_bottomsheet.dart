import 'package:flutter/material.dart';

import '../../apptheme.dart';

class NGOdata extends StatelessWidget {
  const NGOdata({
    Key? key,
    required this.heading,
    required this.title,
    required this.icon,
  }) : super(key: key);

  final String heading;
  final String title;
  final icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 0),
      child: ListTile(
        leading: Icon(icon),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(heading, style: AppTheme.subtitle),
            Text(title, style: AppTheme.caption)
          ],
        ),
      ),
    );
  }
}
