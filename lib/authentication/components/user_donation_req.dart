import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ngo/apptheme.dart';
import 'package:ngo/providers/donation_requests_provder.dart';
import 'package:ngo/widgets/carddesign.dart';
import 'package:provider/provider.dart';

class AllDonationRequests extends StatefulWidget {
  const AllDonationRequests({Key? key}) : super(key: key);

  @override
  State<AllDonationRequests> createState() => _AllDonationRequestsState();
}

class _AllDonationRequestsState extends State<AllDonationRequests> {
  final key = GlobalKey<AnimatedListState>();
  // late ScrollController controller;
  bool scrollVisibility = false;
  late DonationRequestsCardProvider provider;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      provider =
          Provider.of<DonationRequestsCardProvider>(context, listen: false);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  removeItem(int index, List<QueryDocumentSnapshot<Object?>> docList,
      String donationId, Map<String, dynamic> donation) {
    final item = docList.removeAt(index);
    Map<String, dynamic> itemData = item.data() as Map<String, dynamic>;
    key.currentState?.removeItem(
        index,
        (context, animation) =>
            buildCard(donationId, itemData, index, animation, docList));
  }

  Widget buildCard(
      String donationId,
      Map<String, dynamic> donation,
      int index,
      Animation<double> animation,
      List<QueryDocumentSnapshot<Object?>> docList) {
    return RequestCardView(
      animation,
      donationStream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUID)
          .collection('donationRequests')
          .doc(donationId)
          .snapshots(),
      donationId: donationId,
      donation: donation,
      // onAccept: () => removeItem(index, docList, donationId, donation),
    );
  }

  String currentUID = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUID)
            .collection('donationRequests')
            .where('createdOn', isLessThanOrEqualTo: DateTime.now())
            .orderBy('createdOn', descending: true)
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
            if (snapshot.data!.docs.isNotEmpty) {
              var docList = snapshot.data!.docs;
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: AppTheme.background,
                  title: const Text(
                    'Your Donation Requests',
                    style: AppTheme.title,
                  ),
                  foregroundColor: Colors.black,
                ),
                body: AnimatedList(
                  // controller: controller,
                  padding: const EdgeInsets.all(10),
                  initialItemCount: docList.length,
                  itemBuilder: (context, index, animation) {
                    Map<String, dynamic> donation =
                        docList[index].data() as Map<String, dynamic>;
                    String donationId = docList[index].id;
                    // print("%%%%--->>>>   ${chatUserListData}");
                    return buildCard(
                        donationId, donation, index, animation, docList);
                  },
                ),
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
              child:
                  Text('Check your internet connection and Please try again!!'),
            );
          }
        });
  }
}
