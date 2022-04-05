import 'package:flutter/material.dart';

import 'images_action_button.dart';

@immutable
class ExpandableImages extends StatefulWidget {
  const ExpandableImages(
      {Key? key,
      this.initialOpen,
      required this.distance,
      required this.actionButton
      // required this.children,
      })
      : super(key: key);

  final bool? initialOpen;
  final double distance;
  final ActionButton actionButton;
  // final List<Widget> children;

  @override
  _ExpandableImagesState createState() => _ExpandableImagesState();
}

class _ExpandableImagesState extends State<ExpandableImages>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      // fit: StackFit.loose,
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        _buildTapToClose(),
        _buildExpandingActionButtons(),
        _buildTapToOpen(),
      ],
    );
  }

  Widget _buildExpandingActionButtons() {
    // final children = <Widget>[];
    // final count = widget.children.length;
    // for (var i = 0, angleInDegrees = 30.0;
    // i < count;
    // i++, angleInDegrees += step) {
    //   children.add(
    return ExpandingActionButton(
      directionInDegrees: 30,
      maxDistance: widget.distance,
      progress: _expandAnimation,
      child: widget.actionButton,
    );
    // );
    // }
    // return children;
  }

  Widget _buildTapToClose() {
    return SizedBox(
      width: 48.0,
      height: 48.0,
      child: Center(
        child: AnimatedOpacity(
          opacity: !_open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: Material(
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            elevation: 4.0,
            child: InkWell(
              onTap: _toggle,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.close,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTapToOpen() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: CircleAvatar(
            radius: 22.0,
            child: IconButton(
              alignment: Alignment.center,
              icon: const Icon(Icons.collections_outlined),
              onPressed: _toggle,
            ),
          ),
        ),
      ),
    );
  }
}
