import 'package:flutter/material.dart';
import 'package:ngo/apptheme.dart';

class ComingSoon extends StatelessWidget {
  const ComingSoon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Coming\nSoon!',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppTheme.button,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
