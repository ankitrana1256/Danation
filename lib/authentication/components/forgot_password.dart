import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ngo/authentication/functions/firebase.dart';

import '../../apptheme.dart';

enum state { pending, done }

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  state _pageState = state.pending;
  final TextEditingController _email = TextEditingController();

  void switchstate() {
    if (_pageState == state.pending) {
      _pageState = state.done;
    } else {
      _pageState = state.pending;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppTheme.background,
        title: const Text("Forgot Password", style: AppTheme.title),
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
                        Text(
                          _pageState == state.done
                              ? "Email Sent"
                              : "Reset your account",
                          style: const TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          _pageState == state.done
                              ? "A mail with the password reset link is sent to the registered email address"
                              : "Please make sure that the given email is correct",
                          style: AppTheme.body1,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        _pageState == state.done
                            ? SizedBox(
                                height: _size.height / 5,
                                width: _size.width,
                                child: SvgPicture.asset(
                                  'assets/authentication/email_sent.svg',
                                ),
                              )
                            : Column(
                                children: [
                                  TextFormField(
                                    controller: _email,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(
                                        CupertinoIcons.mail,
                                        color: Colors.black,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                      hintText: "Email",
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        const SizedBox(
                          height: 30,
                        ),
                        MaterialButton(
                          height: 40,
                          minWidth: double.infinity,
                          onPressed: () async {
                            if (_pageState == state.pending) {
                              FocusManager.instance.primaryFocus?.unfocus();
                              if (_email.text.isNotEmpty &&
                                  _pageState == state.pending) {
                                await resetPassword(
                                  _email.text.trim(),
                                );
                              }
                              switchstate();
                            } else {
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                          },
                          color: const Color(0xff132137),
                          child: Text(
                            _pageState == state.done ? "Back" : "Send",
                            style: const TextStyle(color: Colors.white),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        if (_pageState == state.pending)
                          GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(
                                context, '/login'),
                            child: const Center(
                              child: Text('Back to login'),
                            ),
                          )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
