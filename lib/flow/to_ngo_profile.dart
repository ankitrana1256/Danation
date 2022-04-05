import 'package:after_layout/after_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ngo/homepage/components/ngo_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToNgoProfile extends StatefulWidget {
  const ToNgoProfile({Key? key}) : super(key: key);

  @override
  State<ToNgoProfile> createState() => _ToNgoProfileState();
}

class _ToNgoProfileState extends State<ToNgoProfile> with AfterLayoutMixin {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> getdetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('Ngo');

    var ngodoc = await FirebaseFirestore.instance
        .collection('NGO')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();

    var docRef = ngodoc.docs.single.data();
    var docid = ngodoc.docs.single.id;
    print(
        '-------------------------------------------------------------------');
    print(docRef['name']);
    print(docRef["address"]);
    print(docRef["email"]);
    print(docRef["mobile"]);
    print(docRef["worksIn"]);
    print(docid);
    print('------------------------------------------------------------------');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NgoProfile(
          permission: mode.edit,
          name: docRef['name'],
          address: docRef["address"],
          email: docRef["email"],
          mobile: docRef["mobile"].toString(),
          worksIn: docRef["workingIn"],
          ngoDocumentId: docid,
        ),
      ),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) => getdetails();
}
