import 'package:flutter/material.dart';

void errorMessage(BuildContext context, String message, String category) {
  if (category == "error") {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1),
      backgroundColor: Colors.red,
    ));
  } else if (category == "success") {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1),
      backgroundColor: Colors.green,
    ));
  } else if (category == "alert") {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1),
    ));
  }
}
