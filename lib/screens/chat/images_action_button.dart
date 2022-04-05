import 'dart:math';

import 'package:flutter/material.dart';

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    Key? key,
    this.onPressed,
    required this.icon,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      child: Card(
        child: Row(
          children: [
            Material(
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              color: theme.colorScheme.secondary,
              elevation: 4.0,
              child: IconButton(
                onPressed: onPressed,
                splashColor: Colors.purple,
                icon: const Icon(Icons.bookmark),
                // color: Colors.red,
              ),
            ),
            Material(
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              color: theme.colorScheme.secondary,
              elevation: 4.0,
              child: IconButton(
                splashColor: Colors.purple,
                onPressed: onPressed,
                icon: icon,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@immutable
class ExpandingActionButton extends StatelessWidget {
  const ExpandingActionButton({
    Key? key,
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  }) : super(key: key);

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          left: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(opacity: progress, child: child),
    );
  }
}
