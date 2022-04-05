import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ngo/apptheme.dart';
import 'package:ngo/authentication/components/user_donation_req.dart';
import 'package:ngo/authentication/functions/firebase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String currentUID = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "UserProfile",
          style: TextStyle(
              fontSize: 20, color: Colors.black, fontFamily: "Poppins"),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUID)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              const Center(
                child: Text(
                    'There was some error in fetching the requests. Please try again!'),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: Padding(
                    padding: EdgeInsets.all(14.0),
                    child: LinearProgressIndicator(),
                  ),
                ),
              );
            }
            if (snapshot.hasData) {
              if (snapshot.data!.exists) {
                Map<String, dynamic> userData =
                    snapshot.data!.data() as Map<String, dynamic>;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: _size.width,
                      height: _size.height,
                      color: const Color(0xffF7EBE1),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundImage:
                                          AssetImage('assets/extra/user.jpg'),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 80,
                                  left: 80,
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        color: Colors.blueAccent),
                                    child: IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                          Icons.camera_alt_outlined,
                                          color: Colors.white),
                                      iconSize: 20,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                '${userData['username']}',
                                style: const TextStyle(
                                    fontSize: 23,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                '${userData['email']}',
                                style: const TextStyle(
                                    fontSize: 15, fontFamily: "Poppins"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: _size.height / 3.5,
                      child: Container(
                        width: _size.width,
                        height: _size.height,
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40))),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 10),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AllDonationRequests())),
                                child: const MenuListTile(
                                  text: "Donation Requests",
                                  icon: Icon(
                                    Icons.request_page_outlined,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Divider(color: Colors.grey[500]),
                              const MenuListTile(
                                  text: "User Managment",
                                  icon: Icon(
                                    Icons.person_outline,
                                    color: Colors.black,
                                  )),
                              Divider(
                                color: Colors.grey[500],
                              ),
                              const MenuListTile(
                                  text: "About Us",
                                  icon: Icon(
                                    Icons.help_outline,
                                    color: Colors.black,
                                  )),
                              Divider(color: Colors.grey[500]),
                              GestureDetector(
                                onTap: () async {
                                  logout();
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.remove('Ngo');
                                  prefs.remove('userType');
                                  Navigator.pushReplacementNamed(
                                      context, '/wrapper');
                                },
                                child: const MenuListTile(
                                    text: "Log Out",
                                    icon: Icon(
                                      Icons.logout_outlined,
                                      color: Colors.black,
                                    )),
                              ),
                              Divider(color: Colors.grey[500]),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return const Center(
                  child: Text(
                    'No requests have been generated yet!!',
                    maxLines: 3,
                  ),
                );
              }
            } else {
              return const Center(
                child: Text(
                  'There was some issue in fetching your detsils',
                  maxLines: 3,
                ),
              );
            }
          }),
    );
  }
}

class MenuListTile extends StatelessWidget {
  const MenuListTile({Key? key, required this.text, required this.icon})
      : super(key: key);
  final String text;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: icon,
        title: Text(
          text,
          style: const TextStyle(fontFamily: "Poppins", fontSize: 16),
        ),
        trailing: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.black,
          ),
        ));
  }
}
