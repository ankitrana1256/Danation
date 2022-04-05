import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ngo/models/donation_modal.dart';
import 'package:ngo/providers/submit_page_provider.dart';
import 'package:provider/provider.dart';

class SubmitLoadingScreen extends StatefulWidget {
  const SubmitLoadingScreen({Key? key, required this.donation})
      : super(key: key);
  final Donation donation;
  @override
  State<SubmitLoadingScreen> createState() => _SubmitLoadingScreenState();
}

class _SubmitLoadingScreenState extends State<SubmitLoadingScreen> {
  final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  late Reference _storageReference;
  List<String> imageUrls = [];

  Future<String?> uploadImageToDatabase(File image) async {
    print('-------@@@@@@@@@   In uploadImageToDatabase');
    try {
      _storageReference = FirebaseStorage.instance
          .ref()
          .child('Donations')
          .child('${DateTime.now().microsecondsSinceEpoch}');
      print(
          '-------@@@@@@@@@##### #####   After instance --- In uploadImageToDatabase');
      UploadTask _storageUploadTask = _storageReference.putFile(image);
      print('-------@@@@@@@@@##################   In uploadImageToDatabase');
      TaskSnapshot snapshot = await _storageUploadTask;
      String imageURL = await snapshot.ref.getDownloadURL();
      print(
          '-------@@@@@@@@@################^^^^^^^^^^^^^^^^^##   In uploadImageToDatabase');
      return imageURL;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Sorry! We were unable send your image'),
        backgroundColor: Theme.of(context).errorColor,
      ));
      return null;
    }
  }

// TODO: alert, circularprogressindicator, navigator
  Future<bool> uploadImage(List<File> images) async {
    print('----------#xyzabc333333333333');
    for (int i = 0; i < images.length; i++) {
      print('----------#xyzabc44444444444$i');
      String? url = await uploadImageToDatabase(images[i]);
      if (url == null) {
        print('----------#xyzabc555555555     <<<<<<<--------------------');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Sorry! We were unable send your image'),
          backgroundColor: Theme.of(context).errorColor,
        ));
        return false;
      } else {
        print(
            '----------#xyzabc66666666     <<<<<<<<<<<<<------------------------');
        imageUrls.add(url);
      }
    }
    return true;
  }

  imagesUploader() {}
  //TODO: Delete images in case any of the image url returns null
  Future<void> submitRequest(SubmitPageProvider manager) async {
    print('----------Starting submit');
    DocumentReference<Map<String, dynamic>>
        donationCollectionDocumentReference =
        FirebaseFirestore.instance.collection('donations').doc();
    DocumentReference<Map<String, dynamic>>
        userDonationRequestsCollectionDocumentReference = FirebaseFirestore
            .instance
            .collection('users')
            .doc(widget.donation.donorID)
            .collection('donationRequests')
            .doc();
    Reference picturesUploadFirebaseStorageCollection =
        FirebaseStorage.instance.ref().child('Donations');
    List<File> images = widget.donation.images;

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      for (int i = 0; i < images.length; i++) {
        Reference _storageReference = picturesUploadFirebaseStorageCollection
            .child('${DateTime.now().microsecondsSinceEpoch}');
        print(
            '-------@@@@@@@@@##### #####   After instance --- In uploadImageToDatabase');
        UploadTask _storageUploadTask = _storageReference.putFile(images[i]);
        print('-------@@@@@@@@@##################   In uploadImageToDatabase');
        TaskSnapshot snapshot = await _storageUploadTask;
        String imageURL = await snapshot.ref.getDownloadURL().catchError((err) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text(
                'There was some problem in uploading the images! Please try again'),
            backgroundColor: Theme.of(context).errorColor,
          ));
          return err.toString();
        });
        print(
            '-------@@@@@@@@@################^^^^^^^^^^^^^^^^^##   In uploadImageToDatabase');
        imageUrls.add(imageURL);
      }

      transaction.set(donationCollectionDocumentReference, {
        'donationCollectionDocumentId': donationCollectionDocumentReference.id,
        'donatedItems': widget.donation.items,
        'accepted': widget.donation.accepted,
        'createdOn': widget.donation.createdON,
        'pickupDateTime': widget.donation.pickupDateTime,
        'pickupCoordinates': widget.donation.pickupCoordinates,
        'images': imageUrls,
        'donorId': widget.donation.donorID,
        'donorEmail': widget.donation.donorEmail,
        'donorPhone': widget.donation.donorPhone,
        'donorName': widget.donation.donorName,
        'donationCategory': widget.donation.donationCategory.index,
        'donorRequestId': userDonationRequestsCollectionDocumentReference.id
      });

      print('In transaction ---starting other');
      transaction.set(userDonationRequestsCollectionDocumentReference, {
        'donationCollectionDocumentId': donationCollectionDocumentReference.id,
        'donatedItems': widget.donation.items,
        'accepted': widget.donation.accepted,
        'createdOn': widget.donation.createdON,
        'pickupDateTime': widget.donation.pickupDateTime,
        'pickupCoordinates': widget.donation.pickupCoordinates,
        'images': imageUrls,
        'donorId': widget.donation.donorID,
        'donorEmail': widget.donation.donorEmail,
        'donorPhone': widget.donation.donorPhone,
        'donorName': widget.donation.donorName,
        'donationCategory': 'Food',
        'donorRequestId': userDonationRequestsCollectionDocumentReference.id
      });
    }).then((value) {
      // ignore: avoid_print
      print('In then of transaction -----------------------');
      manager.removeAllItemFromImageList();
      manager.deleteAll();
      manager.removeAllTypeFoodControllerFromControllerList();
      manager.removeAllQuantityControllerFromControllerList();
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, '/category');
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${err.toString()}'),
        // content: Text('There was some error in submitting your request'),
        backgroundColor: Theme.of(context).errorColor,
      ));
    });

    // bool uploadStatus = await uploadImage(widget.donation.images);
    // if (uploadStatus == true) {
    //   await FirebaseFirestore.instance.collection('donations').add({
    //     'donatedItems': widget.donation.items,
    //     'accepted': widget.donation.accepted,
    //     'createdOn': widget.donation.createdON,
    //     'pickupDateTime':widget.donation.pickupDateTime,
    //     'pickupCoordinates':widget.donation.pickupCoordinates,
    //     'images':imageUrls,
    //     'donorId': widget.donation.donorID,
    //     'donorEmail':widget.donation.donorEmail,
    //     'donorPhone':widget.donation.donorPhone,
    //     'donorName': widget.donation.donorName,
    //     'donationCategory':widget.donation.donationCategory.index,
    //   }).then((value) async {
    //     print('----------#xyzabc11111111 --------------@@@@@@@@@@@@@@@@');
    //     await FirebaseFirestore.instance
    //         .collection('users')
    //         .doc(widget.donation.donorID)
    //         .collection('donationRequests')
    //         .add({
    //       'donatedItems': widget.donation.items,
    //       'accepted': widget.donation.accepted,
    //       'createdOn': widget.donation.createdON,
    //       'pickupDateTime':widget.donation.pickupDateTime,
    //       'pickupCoordinates':widget.donation.pickupCoordinates,
    //       'images':imageUrls,
    //       'donorId': widget.donation.donorID,
    //       'donorEmail':widget.donation.donorEmail,
    //       'donorPhone':widget.donation.donorPhone,
    //       'donorName': widget.donation.donorName,
    //       'donationCategory':widget.donation.donationCategory.name
    //     }).then((value) {
    //       print('----------#xyzabc2222222');
    //       manager.removeAllItemFromImageList();
    //       manager.deleteAll();
    //       manager.removeAllTypeFoodControllerFromControllerList();
    //       manager.removeAllQuantityControllerFromControllerList();
    //       Navigator.pushReplacementNamed(context, '/hello');
    //     }).catchError((err) {
    //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //         content: Text(err.toString()),
    //         backgroundColor: Theme.of(context).errorColor,
    //       ));
    //       Navigator.pop(context);
    //     });
    //   }).catchError((err) {
    //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //       content: Text(err.toString()),
    //       backgroundColor: Theme.of(context).errorColor,
    //     ));
    //     Navigator.pop(context);
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    final manager = Provider.of<SubmitPageProvider>(context, listen: false);
    submitRequest(manager);
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SvgPicture.asset(
              'assets/homepage/waiting.svg',
              height: _size.height / 3,
              width: _size.width,
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: LinearProgressIndicator(),
            ),
            InkWell(
              child: const Text('Cancel'),
              onTap: () {
                Navigator.popUntil(context, ModalRoute.withName('/category'));
              },
            )
          ],
        ),
      ),
    );
  }
}
