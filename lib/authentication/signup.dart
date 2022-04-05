import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ngo/apptheme.dart';
import 'package:ngo/authentication/components/verify_ngo.dart';

import 'components/conditional_checkbox.dart';
import 'components/set_password.dart';
import 'functions/error_notify.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

enum AuthMode { signup, login }

class _LoginPageState extends State<LoginPage> {
  bool _isavailable = false;
  bool _findaccount = false;
  bool _isusername = false;
  final FirebaseFirestore _auth = FirebaseFirestore.instance;
  late String account;
  AuthMode _authMode = AuthMode.login;
  final TextEditingController _email = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _ngoId = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  checkFormValidation(String? value) {
    if (value == null || value.isEmpty) {
      return "Please Enter Your Username";
    }
    if (value.contains(' ')) {
      return "Username Can't Have Spaces";
    }

    return null;
  }

  checkemail(String email) {
    setState(
      () {
        if (RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(email)) {
          _isavailable = true;
        } else {
          _isavailable = false;
        }
      },
    );
  }

  void switchstate() {
    if (_authMode == AuthMode.login) {
      _authMode = AuthMode.signup;
    } else {
      _authMode = AuthMode.login;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _email.addListener(() => checkemail(_email.text.trim()));
  }

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
  }

  Future<User?> checkUser({required String username}) async {
    try {
      await _auth
          .collection('users')
          .where('username', isEqualTo: username)
          .get()
          .then(
        (snapshot) async {
          var value = snapshot.docs[0].data()['email'];
          setState(() {
            if (username.length >= 6) {
              _isusername = false;
              _findaccount = true;
            } else {
              _isusername = false;
              _findaccount = false;
            }
            account = value;
          });
        },
      );
    } catch (e) {
      setState(() {
        if (username.length >= 6) {
          _findaccount = false;
          _isusername = true;
        } else {
          _isusername = false;
          _findaccount = false;
        }
        account = "";
      });
    }
    return null;
  }

  void verifyNgo() async {
    try {
      await _auth
          .collection('NGO')
          .where('uniqueId', isEqualTo: _ngoId.text.trim())
          .get()
          .then(
        (snapshot) async {
          var phone = snapshot.docs[0].data()['mobile'];
          var ngoName = snapshot.docs[0].data()['name'];
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyNgo(
                ngoName: ngoName,
                phone: phone,
              ),
            ),
          );
        },
      );
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Please check your NGO id. Ngo doesn't found.");
    }
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
        title: Text(
            _authMode == AuthMode.login
                ? "Login With Your Account"
                : "SignUp Your Account",
            style: AppTheme.title),
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
                            _authMode == AuthMode.login
                                ? "Enter your username"
                                : "Create your account",
                            style: AppTheme.headline),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          _authMode == AuthMode.login
                              ? "Welcome back to Danation. Its nice to see you again"
                              : "Welcome to Danation. Lets get started",
                          style: AppTheme.body1,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please Enter Your Username";
                                  }
                                  if (value.contains(' ')) {
                                    return "Username Can't Have Spaces";
                                  }

                                  return null;
                                },
                                controller: _username,
                                onEditingComplete: () {
                                  checkUser(username: _username.text);
                                },
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    CupertinoIcons.person,
                                    color: Colors.black,
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(
                                          color: Colors.black)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(
                                          color: Colors.black)),
                                  hintText: "Username",
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 20,
                                  ),
                                ),
                              ),
                              if (_authMode == AuthMode.signup)
                                Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    TextFormField(
                                      validator: (value) {
                                        if (_email.text.isEmpty) {
                                          return "Email Can't Be Empty";
                                        }
                                        if (_email.text.contains(' ')) {
                                          return "Email Can't Have Spaces";
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.emailAddress,
                                      controller: _email,
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(
                                          CupertinoIcons.mail,
                                          color: Colors.black,
                                        ),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            borderSide: const BorderSide(
                                                color: Colors.black)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            borderSide: const BorderSide(
                                                color: Colors.black)),
                                        hintText: "Email",
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 20),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(
                                height: 30,
                              ),
                            ],
                          ),
                        ),
                        if (_authMode == AuthMode.signup)
                          Column(
                            children: [
                              ConditionalCheckbox(
                                func: _isusername,
                                str: "This username is available",
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              ConditionalCheckbox(
                                func: _isavailable,
                                str: _isavailable
                                    ? "This email is valid"
                                    : "Invalid Email Found",
                              ),
                              const SizedBox(
                                height: 20,
                              )
                            ],
                          ),
                        if (_authMode == AuthMode.login)
                          Column(
                            children: [
                              Row(
                                children: [
                                  ConditionalCheckbox(
                                    func: _findaccount,
                                    str: _findaccount
                                        ? "Account Found"
                                        : "No Account Found",
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacementNamed(
                                          context, '/forgotPass');
                                    },
                                    child: const Text('Forgot password ?'),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                            ],
                          ),
                        MaterialButton(
                          height: 40,
                          minWidth: double.infinity,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (_authMode == AuthMode.signup &&
                                  _isavailable == true &&
                                  _isusername == true) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return SetPassword(
                                        email: _email.text.trim(),
                                        state: AuthMode.signup,
                                        username: _username.text.toLowerCase(),
                                      );
                                    },
                                  ),
                                );
                              }
                              if (_authMode == AuthMode.login &&
                                  _findaccount == true) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return SetPassword(
                                        username: _username.text.toLowerCase(),
                                        state: AuthMode.login,
                                        email: account.trim(),
                                      );
                                    },
                                  ),
                                );
                              }
                            }
                          },
                          color: AppTheme.button,
                          child: const Text(
                            "CONTINUE",
                            style: TextStyle(color: Colors.white),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        if (_authMode == AuthMode.login)
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    color: Colors.grey,
                                    height: 2,
                                    width: _size.width / 3,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    "OR",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    color: Colors.grey,
                                    height: 2,
                                    width: _size.width / 3,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              TextFormField(
                                validator: (value) {
                                  checkFormValidation(value);
                                },
                                controller: _ngoId,
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      if (_ngoId.text.isEmpty) {
                                        errorMessage(context,
                                            "NGO ID Can't Be Empty", "error");
                                      } else {
                                        verifyNgo();
                                      }
                                    },
                                    icon: const Icon(
                                      CupertinoIcons.arrowtriangle_right,
                                      color: Colors.black,
                                      size: 25,
                                    ),
                                  ),
                                  prefixIcon: const Icon(
                                    CupertinoIcons.house,
                                    color: Colors.black,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                    ),
                                  ),
                                  hintText: "Login with NGO ID",
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 20),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        GestureDetector(
                          onTap: () => switchstate(),
                          child: Center(
                            child: _authMode == AuthMode.login
                                ? const Text('Create an account?')
                                : const Text('Already have an account?'),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
