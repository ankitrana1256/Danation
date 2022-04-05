import 'package:flutter/cupertino.dart';
import 'package:ngo/flow/wrapper.dart';

class UserTypeProvider extends ChangeNotifier {
  late userType _user;

  userType get user => _user;
  set user(value) {
    _user = value;
    notifyListeners();
  }
}
