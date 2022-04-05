import 'package:flutter/material.dart';

class ConditionalCheckbox extends StatefulWidget {
  final bool func;
  final String str;
  const ConditionalCheckbox({
    Key? key,
    required this.func,
    required this.str,
  }) : super(key: key);

  @override
  _ConditionCheckboxState createState() => _ConditionCheckboxState();
}

class _ConditionCheckboxState extends State<ConditionalCheckbox> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
              color: widget.func ? Colors.green : Colors.transparent,
              border: widget.func
                  ? Border.all(color: Colors.transparent)
                  : Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(50)),
          child: const Center(
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 15,
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Text(widget.str)
      ],
    );
  }
}
