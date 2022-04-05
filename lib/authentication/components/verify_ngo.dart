import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ngo/flow/wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../apptheme.dart';
import '../../bottom_navigation_bar.dart';
import '../functions/firebase.dart';

class VerifyNgo extends StatefulWidget {
  final int phone;
  final String ngoName;
  const VerifyNgo({Key? key, required this.phone, required this.ngoName})
      : super(key: key);

  @override
  State<VerifyNgo> createState() => _VerifyNgoState();
}

class _VerifyNgoState extends State<VerifyNgo> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _otp = TextEditingController();
  var verificationIDReceived = "";

  @override
  void initState() {
    super.initState();
    loginWithPhone(widget.phone);
  }

  Future<void> loginWithPhone(phone) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: '+91$phone',
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential).then(
              (value) =>
                  Fluttertoast.showToast(msg: 'You are logged in successfully'),
            );
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          Fluttertoast.showToast(
              msg: 'The provided phone number is not valid.');
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        setState(() {
          verificationIDReceived = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
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
        title: const Text(
          "Verification For Ngo",
          style: TextStyle(
            color: Colors.black,
          ),
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
                    const Text(
                      'Enter your OTP',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Please do not share your OTP, Passwords or any other confidential information with anyone",
                      style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.grey.shade600),
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          CupertinoIcons.house_fill,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: _size.width / 1.5,
                          child: Text(
                            widget.ngoName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _otp,
                      keyboardType: TextInputType.number,
                      inputFormatters: [LengthLimitingTextInputFormatter(6)],
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          CupertinoIcons.phone,
                          color: Colors.black,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black)),
                        hintText: "OTP",
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                      ),
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    MaterialButton(
                      height: 40,
                      minWidth: double.infinity,
                      onPressed: () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        User? user =
                            await verifyotp(_otp, verificationIDReceived);
                        if (user != null) {
                          final _prefs = await SharedPreferences.getInstance();
                          final isSet =
                              await _prefs.setString('userType', 'NGO');
                          final ngoName =
                              await _prefs.setString('Ngo', widget.ngoName);
                          isSet
                              ? Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ShowBottomNavigationBar(
                                            userstate: userType.ngo,
                                            ngoName: widget.ngoName),
                                  ),
                                )
                              : ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor:
                                        Theme.of(context).errorColor,
                                    content: const Text(
                                        'Shared Preferences: UserType error'),
                                  ),
                                );
                        } else {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                      color: Colors.black,
                      child: const Text(
                        "Verify",
                        style: TextStyle(color: Colors.white),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
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
