import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ngo/bottom_navigation_bar.dart';
import 'package:ngo/flow/wrapper.dart';

class StateChecker extends StatefulWidget {
  const StateChecker({Key? key}) : super(key: key);

  @override
  StateCheckerState createState() => StateCheckerState();
}

class StateCheckerState extends State<StateChecker>
    with AfterLayoutMixin<StateChecker> {
  Future getUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String determine = prefs.getString('userType')!;
    final String? name = prefs.getString('Ngo');
    print('--------------------------------------');
    print(determine);
    print(name);

    if (determine == 'Donor') {
      return Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const ShowBottomNavigationBar(userstate: userType.donor),
        ),
      );
    } else if (determine == 'NGO') {
      return Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ShowBottomNavigationBar(
            userstate: userType.ngo,
            ngoName: name,
          ),
        ),
      );
    }
  }

  @override
  void afterFirstLayout(BuildContext context) => getUserType();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
