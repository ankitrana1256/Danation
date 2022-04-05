import 'package:flutter/material.dart';

class DonationRequestsCardProvider extends ChangeNotifier {
  late bool _accepted;
  bool _scrollVisibility = false;

  bool get scrollVisibility => _scrollVisibility;

  set scrollVisibility(bool value) {
    _scrollVisibility = value;
    notifyListeners();
  }

  bool get accepted => _accepted;

  set accepted(bool value) {
    _accepted = value;
    notifyListeners();
  }
}
