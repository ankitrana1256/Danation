import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ngo/apptheme.dart';
import 'package:provider/provider.dart';

import '../providers/donation_requests_provder.dart';
import '../widgets/carddesign.dart';

class NewRequests extends StatefulWidget {
  const NewRequests(
      {Key? key,
      required this.timeOfInitialRequest,
      required this.controller,
      required this.callback})
      : super(key: key);
  final DateTime timeOfInitialRequest;
  final ScrollController controller;
  final VoidCallback callback;
  @override
  _NewRequestsState createState() => _NewRequestsState();
}

class _NewRequestsState extends State<NewRequests> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('donations')
            // TODO: To add this where clause
            // .where('accepted',isNotEqualTo: true)
            .where('createdOn', isGreaterThan: widget.timeOfInitialRequest)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.docs.isNotEmpty) {
              // return AnimatedPositioned(
              //   // height: 90,
              //   child: Align(
              //     alignment: Alignment.topCenter,
              //     child: TweenAnimationBuilder(
              //         tween: Tween<double>(begin: 0, end: 1),
              //         duration: Duration(milliseconds: 200),
              //         builder: (context, double value, Widget? child) {
              //           double offset = sin(value);
              //           return Transform.translate(
              //             offset: Offset(0,offset),
              return Align(
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onTap: () {
                    widget.controller
                        .animateTo(widget.controller.position.minScrollExtent,
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.easeInOut)
                        .then((value) {
                      widget.callback();
                    });
                  },
                  child: Material(
                    elevation: 10.0,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      // clipBehavior: Clip,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.white54),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 15.0,
                            color: Colors.green,
                            // fontWeight: FontWeight.w700
                          ),
                          children: [
                            TextSpan(
                                text: snapshot.data!.docs.length.toString()),
                            const TextSpan(
                              text: ' New Requests',
                              style: TextStyle(
                                // fontSize: 14.0,
                                color: Colors.black,
                                // fontWeight: FontWeight.w700
                              ),
                            ),
                            const WidgetSpan(
                              child: Icon(Icons.arrow_upward),
                              style: TextStyle(
                                  // fontSize: 14.0,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700),
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
          return const SizedBox.shrink();
        });
  }
}

class NgoDonationsRequests extends StatefulWidget {
  const NgoDonationsRequests({Key? key}) : super(key: key);

  @override
  _NgoDonationsRequestsState createState() => _NgoDonationsRequestsState();
}

class _NgoDonationsRequestsState extends State<NgoDonationsRequests> {
  final key = GlobalKey<AnimatedListState>();
  late ScrollController controller;
  bool scrollVisibility = false;
  late DonationRequestsCardProvider provider;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = ScrollController()..addListener(_scrollListener);
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      provider =
          Provider.of<DonationRequestsCardProvider>(context, listen: false);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.removeListener(_scrollListener);
    controller.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (controller.position.userScrollDirection == ScrollDirection.forward ||
        controller.position.userScrollDirection == ScrollDirection.idle) {
      provider.scrollVisibility = false;
    } else {
      provider.scrollVisibility = true;
    }
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
          .collection('donations')
          .doc(donationId)
          .snapshots(),
      donationId: donationId,
      donation: donation,
      // onAccept:()=>removeItem(index,docList,donationId,donation),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('donations')
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
                    'Requests',
                    style: AppTheme.title,
                  ),
                  centerTitle: true,
                ),
                body: SafeArea(
                  child: Stack(
                    children: [
                      AnimatedList(
                        // controller: controller,
                        padding: const EdgeInsets.all(10),
                        initialItemCount: docList.length,
                        itemBuilder: (context, index, animation) {
                          Map<String, dynamic> donation =
                              docList[index].data() as Map<String, dynamic>;
                          String donationId = docList[index].id;
                          return buildCard(
                              donationId, donation, index, animation, docList);
                        },
                      ),
                      Consumer<DonationRequestsCardProvider>(
                        builder: (context, value, child) {
                          return AnimatedPositioned(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.bounceInOut,
                            child: Visibility(
                              child: NewRequests(
                                timeOfInitialRequest: DateTime.now(),
                                controller: controller,
                                callback: () {
                                  setState(() {});
                                },
                              ),
                              visible: value.scrollVisibility,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const Center(
                child: Text(
                  'No requests have been generated yet!! Till then keep doing the good work',
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
