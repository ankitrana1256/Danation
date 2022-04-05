import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ngo/authentication/functions/firebase.dart';
import 'package:ngo/bottom_navigation_bar.dart';
import 'package:ngo/flow/wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../apptheme.dart';
import '../signup.dart';
import 'conditional_checkbox.dart';

class SetPassword extends StatefulWidget {
  final String email;
  final AuthMode state;
  final String username;
  const SetPassword({
    Key? key,
    required this.email,
    required this.state,
    required this.username,
  }) : super(key: key);

  @override
  _SetPasswordState createState() => _SetPasswordState();
}

class _SetPasswordState extends State<SetPassword> {
  bool _isVisible = false;
  bool _isPasswordEightCharacters = false;
  bool _hasPasswordOneNumber = false;
  bool _hasNoSpace = false;
  bool _isPasswordalpha = false;
  final TextEditingController _password = TextEditingController();
  late AuthMode _authMode;

  @override
  void initState() {
    super.initState();
    _authMode = widget.state;
  }

  onPasswordChanged(String password) {
    final numericRegex = RegExp(r'[0-9]');
    final alphaRegex = RegExp(r'[A-Za-z]');
    setState(() {
      _isPasswordEightCharacters = false;
      if (password.length >= 8) {
        _isPasswordEightCharacters = true;
      }

      if (!password.contains(" ") && password.isNotEmpty) {
        _hasNoSpace = true;
      } else {
        _hasNoSpace = false;
      }

      if (alphaRegex.hasMatch(password)) {
        _isPasswordalpha = true;
      } else {
        _isPasswordalpha = false;
      }

      _hasPasswordOneNumber = false;
      if (numericRegex.hasMatch(password)) _hasPasswordOneNumber = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.background,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          _authMode == AuthMode.signup
              ? "Create Your Account"
              : "Enter Your Password",
          style: AppTheme.title,
        ),
      ),
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: SingleChildScrollView(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _authMode == AuthMode.signup
                          ? "Set a password"
                          : 'Enter your password',
                      style: AppTheme.headline,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      _authMode == AuthMode.signup
                          ? "Please create a secure password including the following criteria below."
                          : "You are one step away from using our services",
                      style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.grey.shade600),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      controller: _password,
                      onChanged: (password) => onPasswordChanged(password),
                      obscureText: !_isVisible,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isVisible = !_isVisible;
                            });
                          },
                          icon: _isVisible
                              ? const Icon(
                                  Icons.visibility,
                                  color: Colors.black,
                                )
                              : const Icon(
                                  Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black)),
                        hintText: "Password",
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    if (_authMode == AuthMode.signup)
                      Column(
                        children: [
                          ConditionalCheckbox(
                              func: _isPasswordEightCharacters,
                              str: "Contains at least 8 characters"),
                          const SizedBox(
                            height: 10,
                          ),
                          ConditionalCheckbox(
                              func: _isPasswordalpha,
                              str: "Password should contain alphabets"),
                          const SizedBox(
                            height: 10,
                          ),
                          ConditionalCheckbox(
                              func: _hasPasswordOneNumber,
                              str: "Contains at least 1 number"),
                          const SizedBox(
                            height: 10,
                          ),
                          ConditionalCheckbox(
                              func: _hasNoSpace,
                              str: "Should not contain spaces"),
                          const SizedBox(
                            height: 50,
                          ),
                        ],
                      ),
                    MaterialButton(
                      height: 40,
                      minWidth: double.infinity,
                      onPressed: () async {
                        if (_authMode == AuthMode.signup &&
                            _isPasswordEightCharacters == true &&
                            _isPasswordalpha == true &&
                            _hasNoSpace == true &&
                            _hasPasswordOneNumber == true) {
                          await createAccount(widget.email, _password.text)
                              .then((value) async {
                            User? user = FirebaseAuth.instance.currentUser;
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user!.uid)
                                .set({
                              'uid': user.uid,
                              'username': widget.username,
                              'email': widget.email,
                            });
                          });
                          Navigator.pushReplacementNamed(context, '/verify');
                        }
                        if (_authMode == AuthMode.login) {
                          await login(widget.email, _password.text).then(
                            (value) async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              if (value != null) {
                                final _prefs =
                                    await SharedPreferences.getInstance();
                                final isSet =
                                    await _prefs.setString('userType', 'Donor');
                                isSet
                                    ? Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ShowBottomNavigationBar(
                                            userstate: userType.donor,
                                          ),
                                        ),
                                      )
                                    : ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                        SnackBar(
                                          backgroundColor:
                                              Theme.of(context).errorColor,
                                          content: const Text(
                                              'Shared Preferences: UserType error'),
                                        ),
                                      );
                              }
                            },
                          );
                        }
                      },
                      color: Colors.black,
                      child: Text(
                        _authMode == AuthMode.signup
                            ? "CREATE ACCOUNT"
                            : "Login",
                        style: const TextStyle(color: Colors.white),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
