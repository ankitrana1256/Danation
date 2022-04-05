import 'dart:math';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ngo/apptheme.dart';
import 'package:ngo/widgets/button.dart';

class RequestCardView extends StatefulWidget {
  RequestCardView(
    this.animation, {
    Key? key,
    required this.donationStream,
    required this.donationId,
    required this.donation,
    // required this.onAccept,
  }) : super(key: key);
  final Stream<DocumentSnapshot<Map<String, dynamic>>> donationStream;
  final String donationId;
  final Map<String, dynamic> donation;
  // final VoidCallback onAccept;
  Animation<double> animation;
  @override
  State<RequestCardView> createState() => _RequestCardViewState(donation);
}

class _RequestCardViewState extends State<RequestCardView> {
  // late Map<String,dynamic> widget.donation;
  final Map<String, dynamic> donation;
  _RequestCardViewState(this.donation);

  @override
  Widget build(BuildContext context) {
    // var _stream = FirebaseFirestore.instance.collection('donations').doc(widget.donationId).snapshots().listen((event) {
    //   widget.donation = event.data() as Map<String,dynamic>;
    // });

    DateTime pickupDateTime =
        (widget.donation['pickupDateTime'] as Timestamp).toDate();
    int pickupHour = pickupDateTime.hour;
    int pickupMinute = pickupDateTime.minute;
    int pickupYear = pickupDateTime.year;
    int pickupMonth = pickupDateTime.month;
    int pickupDay = pickupDateTime.day;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: widget.donationStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            const Center(
              child: Text("Couldn't fetch this request"),
            );
          }

          if (snapshot.hasData) {
            if (snapshot.data!.exists) {
              Map<String, dynamic> listData =
                  snapshot.data!.data() as Map<String, dynamic>;
              return SizeTransition(
                sizeFactor: widget.animation,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 8),
                  child: Card(
                    key: Key('${Random().nextDouble()}'),
                    margin: const EdgeInsets.only(),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                            color: Colors.deepPurpleAccent.withOpacity(0.3))),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: listData['accepted']
                                ? const Text(
                                    '● Request is Closed',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: 'Poppins',
                                        fontSize: 14),
                                  )
                                : const Text(
                                    '● Request is Open',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: 'Poppins',
                                        fontSize: 14),
                                  ),
                            subtitle: Text(
                              'Pickup Time: $pickupDay/$pickupMonth/$pickupYear at ${DateFormat().add_jm().format(
                                    DateTime(
                                        DateTime.now().year,
                                        DateTime.now().month,
                                        DateTime.now().day,
                                        pickupHour,
                                        pickupMinute),
                                  )}',
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontFamily: 'Poppins',
                                  fontSize: 12),
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.fade,
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.food_bank,
                                    color: Colors.black,
                                  ),
                                  radius: 10,
                                  // backgroundColor: Colors.grey,
                                ),
                                Text(
                                    listData['donationCategory'] == 0
                                        ? 'Food'
                                        : 'Health',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurpleAccent))
                              ],
                            ),
                          ),
                          ListTile(
                              leading: const CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                    AssetImage('assets/extra/user.jpg'),
                              ),
                              title: Text(
                                listData['donorName'],
                                style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                              subtitle: Text(
                                listData['donorPhone'].toString(),
                                style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.grey,
                                    fontSize: 13),
                              ),
                              trailing: listData['accepted']
                                  ? const SizedBox.shrink()
                                  : Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: InkWell(
                                        onTap: () {
                                          buildBottomDetailsSheet(listData);
                                        },
                                        child: Container(
                                          width: 120,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: Colors.deepPurpleAccent,
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'More Info',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )),
                        ],
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

  Future<void> sendAcceptRequest(BuildContext context) async {
    DocumentReference donationDocumentReference = FirebaseFirestore.instance
        .collection('donations')
        .doc(widget.donationId);
    DocumentReference userRequestsCollectionDocumentReference =
        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.donation['donorId'])
            .collection('donationRequests')
            .doc(widget.donation['donorRequestId']);
    DocumentReference ngoDonationRequestsDocumentReference = FirebaseFirestore
        .instance
        .collection('NGO')
        .doc('0ZgWI1WDz9jSnbaan9rd')
        .collection('donationRequests')
        .doc();

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(donationDocumentReference, {
        'accepted': true,
        'ngoId': '0ZgWI1WDz9jSnbaan9rd',
      });

      transaction.update(userRequestsCollectionDocumentReference, {
        'accepted': true,
        'ngoId': '0ZgWI1WDz9jSnbaan9rd',
      });

      transaction.set(ngoDonationRequestsDocumentReference, {
        'accepted': true,
        'ngoId': '0ZgWI1WDz9jSnbaan9rd',
        'donatedItems': widget.donation['donatedItems'],
        'createdOn': DateTime.now(),
        'pickupDateTime': widget.donation['pickupDateTime'],
        'pickupCoordinates': widget.donation['pickupCoordinates'],
        'images': widget.donation['images'],
        'donorId': widget.donation['donorId'],
        'donorEmail': widget.donation['donorEmail'],
        'donorPhone': widget.donation['donorPhone'],
        'donorName': widget.donation['donorName'],
        'donationCategory': widget.donation['donationCategory'],
        'donorRequestId': widget.donation['donorRequestId'],
        'ngoDonationAcceptId': ngoDonationRequestsDocumentReference.id
      });
    }).then((value) {
      Navigator.pop(context);
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Dialog(
                elevation: 15.0,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Image.asset('assets/images/check.gif'),
                      ),
                      const Text('Your request was successfully submitted!!'),
                      // InkWell(
                      //   onTap: ()=>onAccept,
                      //   child: Container(
                      //     // width: 120,
                      //     // height: 50,
                      //     decoration: BoxDecoration(
                      //       border:
                      //       Border.all(color: Colors.grey),
                      //       color: Colors.white,
                      //       borderRadius:
                      //       BorderRadius.circular(30),
                      //     ),
                      //     child: const Center(
                      //       child: Text(
                      //         'Cancel',
                      //         style: TextStyle(
                      //             color: Colors.black,
                      //             fontFamily: 'Poppins',
                      //             fontWeight: FontWeight.bold),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            );
          });
      // Navigator.pop(context);
    }).catchError((err) {
      print('...... ${err.toString()} %^^^^^^^_____________}');
      Navigator.pop(context);
      print("@@@@...............");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(milliseconds: 1300),
        content: const Text('There was some error in submitting your request'),
        backgroundColor: Theme.of(context).errorColor,
      ));
      // showDialog(barrierDismissible:false,context: context, builder: (BuildContext context){
      //   return BackdropFilter(
      //     filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      //     child: Padding(
      //       padding: const EdgeInsets.only(bottom:14.0),
      //       child: Dialog(
      //         elevation: 15.0,
      //         clipBehavior: Clip.antiAliasWithSaveLayer,
      //         child: Column(
      //           mainAxisSize: MainAxisSize.min,
      //           children: [
      //             //TODO: Attribute: <a href="https://www.flaticon.com/free-icons/sad" title="sad icons">Sad icons created by Md Tanvirul Haque - Flaticon</a>
      //               Padding(
      //                 padding: const EdgeInsets.all(20.0),
      //                 child: Image.asset('assets/images/sad2.png'),
      //               ),
      //             Text('Looks like there was some error in processing your request!'),
      //           ],
      //         ),
      //       ),
      //     ),
      //   );
      // });
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text(err.toString()),
      //   backgroundColor: Theme.of(context).errorColor,
      // ));
    });

    // return FirebaseFirestore.instance.runTransaction((transaction) async{
    //   DocumentSnapshot snapshot
    // });
    // .update({
    //   'accepted':true,
    //   'ngoId':'7JEuQK0MXjF0RGKe1V6z',
    // }).then((value) => );
  }

  late List<Widget> list = [
    fieldLabel('Donor Name'),
    fieldValue(donation['donorName']),
    const SizedBox(height: 25),
    fieldLabel('Email'),
    fieldValue(donation['donorEmail']),
    const SizedBox(height: 25),
    fieldLabel('Mobile Number'),
    fieldValue(donation['donorPhone'].toString()),
    const SizedBox(height: 25),
    fieldLabel('Address'),
    fieldValue(donation['pickupCoordinates']),
    const SizedBox(height: 25),
    fieldLabel('Date & Time'),
    fieldValue(donation['pickupDateTime'].toString()),
    const SizedBox(height: 25),
    fieldLabel('Donation Items'),
    fieldChipValue(donation['donatedItems']),
    const SizedBox(height: 25),
    donation['images'].length != 0
        ? fieldLabel('Images')
        : const SizedBox.shrink(),
    donation['images'].length != 0
        ? fieldImages(donation['images'])
        : const SizedBox.shrink(),
    const SizedBox(height: 40),
    Expanded(
      child: Flexible(
          child: Button('Accept', () {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: Dialog(
                    elevation: 15.0,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Image.asset('assets/images/Infinity.gif'),
                        ),
                        const Text('Processing your request'),
                      ],
                    ),
                  ),
                ),
              );
            });
        sendAcceptRequest(context);
      })),
    )
  ];

  buildBottomDetailsSheet(Map<String, dynamic> donation) async {
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.5,
            minChildSize: 0.4,
            maxChildSize: 0.9,

            // initialChildSize: 2,
            builder: (BuildContext context, ScrollController scrollController) {
              return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return list[index];
                    },
                  )
                  // ListView(
                  //   controller: scrollController,
                  //   // primary: true,
                  //   shrinkWrap: true,
                  //   children: [
                  //     fieldLabel('Donor Name'),
                  //     fieldValue(donation['donorName']),
                  //     SizedBox(height: 25),
                  //     fieldLabel('Email'),
                  //     fieldValue(donation['donorEmail']),
                  //     SizedBox(height: 25),
                  //     fieldLabel('Mobile Number'),
                  //     fieldValue(donation['donorPhone'].toString()),
                  //     SizedBox(height: 25),
                  //     fieldLabel('Address'),
                  //     fieldValue(donation['pickupCoordinates']),
                  //     SizedBox(height: 25),
                  //     fieldLabel('Date & Time'),
                  //     fieldValue(donation['pickupDateTime'].toString()),
                  //     SizedBox(height: 25),
                  //     fieldLabel('Donation Items'),
                  //     fieldChipValue(donation['donatedItems']),
                  //     SizedBox(height: 25),
                  //     fieldLabel('Images'),
                  //     fieldImages(donation['images']),
                  //     SizedBox(height: 40),
                  //     Expanded(
                  //       child: Row(
                  //         children: [
                  //           Flexible(child: Button('Reject', () {})),
                  //           SizedBox(width: 10),
                  //           Flexible(child: Button('Accept', () {})),
                  //         ],
                  //       ),
                  //     )
                  //   ],
                  // ),
                  );
            },
          ),
        );
      },
    );
  }

  Text fieldLabel(String field) {
    return Text(
      field,
      style: GoogleFonts.roboto(
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Container fieldValue(String value) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 1),
          ),
        ],
        color: AppTheme.nearlyWhite,
      ),
      child: Text(
        value,
      ),
    );
  }

  Widget fieldChipValue(List<dynamic> donationItems) {
    return SizedBox(
      height: donationItems.length * 50,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: ListView.builder(
          itemBuilder: (context, index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                fieldValue(
                  donationItems[index]['foodType'],
                ),
                fieldValue(
                  donationItems[index]['foodQuantity'].toString(),
                ),
                fieldValue(
                  donationItems[index]['quantityType'],
                ),
              ],
            );
          },
          itemCount: donationItems.length,
        ),
      ),
    );
  }

  Widget fieldImages(List<dynamic> images) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        primary: false,
        itemBuilder: (context, index) => SizedBox(
          height: 150,
          width: 150,
          child: Image.network(
            images[index],
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
        ),
        itemCount: images.length,
      ),
    );
  }
}

//
// import 'package:google_fonts/google_fonts.dart';
// import 'package:ngo/constants.dart';
// import 'package:ngo/models/donor_request.dart';
// import 'package:ngo/widgets/button.dart';
//
// class DonationRequest extends StatelessWidget {
//   DonationRequest({Key? key}) : super(key: key);
//   final DonorRequest donorRequest = DonorRequest(
//     coordinates: '29.6923',
//     dateTime: '28 March 2022 at 18:39:00 UTC+5:30',
//     email: 'gautamgoyal6553@gmail.com',
//     images: [
//       'https://firebasestorage.googleapis.com/v0/b/ngo-community.appspot.com/o/Donations%2F1648372222882020?alt=media&token=36bd2c59-7777-4b10-8eca-20327bdd904f',
//       'https://firebasestorage.googleapis.com/v0/b/ngo-community.appspot.com/o/Donations%2F1648372231468361?alt=media&token=a5c41a3b-48a8-4c48-85a0-da368c0cc329'
//     ],
//     items: [
//       {'foodQuantity': 6, 'foodType': 'Packet Food', 'quantityType': 'Per'},
//       {'foodQuantity': 6, 'foodType': 'Packet Food', 'quantityType': 'Per'},
//     ],
//     name: 'gg',
//     number: '1234567890',
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Request Details'),
//         toolbarHeight: 50,
//         backgroundColor: primaryColor,
//         foregroundColor: Colors.white,
//         centerTitle: true,
//       ),
//       body: SizedBox(
//         height: 700,
//         child: Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: ListView(
//             primary: true,
//             shrinkWrap: true,
//             children: [
//               fieldLabel('Name'),
//               fieldValue(donorRequest.name),
//               SizedBox(height: 25),
//               fieldLabel('Email'),
//               fieldValue(donorRequest.email),
//               SizedBox(height: 25),
//               fieldLabel('Mobile Number'),
//               fieldValue(donorRequest.number),
//               SizedBox(height: 25),
//               fieldLabel('Address'),
//               fieldValue(donorRequest.coordinates),
//               SizedBox(height: 25),
//               fieldLabel('Date & Time'),
//               fieldValue(donorRequest.dateTime),
//               SizedBox(height: 25),
//               fieldLabel('Donation Items'),
//               fieldChipValue(donorRequest.items),
//               SizedBox(height: 25),
//               fieldLabel('Images'),
//               // fieldImages(donorRequest.images),
//               SizedBox(height: 40),
//               Expanded(
//                 child: Row(
//                   children: [
//                     Flexible(child: Button('Reject', () {})),
//                     SizedBox(width: 10),
//                     Flexible(child: Button('Accept', () {})),
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Text fieldLabel(String field) {
//     return Text(
//       field,
//       style: GoogleFonts.roboto(
//         fontSize: 18,
//         fontWeight: FontWeight.w500,
//       ),
//     );
//   }
//
//   Container fieldValue(String value) {
//     return Container(
//       margin: EdgeInsets.only(top: 8.0),
//       padding: EdgeInsets.all(10.0),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(borderRadius),
//         boxShadow: [
//           primaryBoxShadow,
//         ],
//         color: secondaryColor,
//       ),
//       child: Text(
//         value,
//       ),
//     );
//   }
//
//   Widget fieldChipValue(List<Map> donationItems) {
//     return SizedBox(
//       height: donationItems.length * 50,
//       child: ListView.builder(
//         itemBuilder: (context, index) {
//           return Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               fieldValue(
//                 donationItems[index]['foodType'],
//               ),
//               fieldValue(
//                 donationItems[index]['foodQuantity'].toString(),
//               ),
//               fieldValue(
//                 donationItems[index]['quantityType'],
//               ),
//             ],
//           );
//         },
//         itemCount: donationItems.length,
//       ),
//     );
//   }
//
//   Widget fieldImages(List<String> images) {
//     return Expanded(
//       child: ListView.builder(
//         shrinkWrap: true,
//         scrollDirection: Axis.horizontal,
//         primary: false,
//         itemBuilder: (context, index) => SizedBox(
//           height: 150,
//           width: 150,
//           child: Image.network(images[index]),
//         ),
//         itemCount: images.length,
//       ),
//     );
//   }
// }
