import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ngo/bottom_navigation_bar.dart';
import 'package:ngo/flow/wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../apptheme.dart';
import '../functions/firebase.dart';

class VerifyUser extends StatefulWidget {
  const VerifyUser({Key? key}) : super(key: key);

  @override
  State<VerifyUser> createState() => _VerifyUserState();
}

class _VerifyUserState extends State<VerifyUser> {
  final auth = FirebaseAuth.instance;
  late User user;
  late Timer timer;

  @override
  void initState() {
    user = auth.currentUser!;
    user.sendEmailVerification();
    timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      checkemailverified();
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> checkemailverified() async {
    user = auth.currentUser!;
    await user.reload();
    if (user.emailVerified) {
      timer.cancel();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('userType', 'Donor');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ShowBottomNavigationBar(
            userstate: userType.donor,
          ),
        ),
      );
    }
  }

  Future<bool> doNotPop() async {
    timer.cancel();
    final user = FirebaseAuth.instance.currentUser;
    deleteUser(user!.uid);
    await user.delete();
    await logout();
    Navigator.pushReplacementNamed(context, '/login');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: doNotPop,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: AppTheme.background,
          title: const Text("Verify Your Email", style: AppTheme.title),
        ),
        body: SafeArea(
          child: Container(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    margin: const EdgeInsets.all(20.0),
                    elevation: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Email Verification',
                            style: AppTheme.headline,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            'We have send a verification link to ${user.email}. Click on the link to verify your account.',
                            style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.grey.shade600),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          SizedBox(
                            height: _size.height / 5,
                            width: _size.width,
                            child: SvgPicture.asset(
                              'assets/authentication/verification_sent.svg',
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          const Center(
                            child: Text("Waiting for verification",
                                style: AppTheme.body2),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          const Center(child: CircularProgressIndicator()),
                          const SizedBox(
                            height: 15,
                          ),
                          MaterialButton(
                            height: 40,
                            minWidth: double.infinity,
                            onPressed: () {
                              doNotPop();
                            },
                            color: const Color(0xff132137),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.white),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
