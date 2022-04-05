import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ngo/apptheme.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ngo/screens/chat/chat_screen.dart';

enum mode { edit, read }

class NgoProfile extends StatefulWidget {
  final String name;
  final String address;
  final String email;
  final String mobile;
  final String worksIn;
  final String ngoDocumentId;
  final mode permission;
  const NgoProfile(
      {Key? key,
      required this.name,
      required this.address,
      required this.email,
      required this.mobile,
      required this.worksIn,
      required this.ngoDocumentId,
      required this.permission})
      : super(key: key);

  @override
  State<NgoProfile> createState() => _NgoProfileState();
}

class _NgoProfileState extends State<NgoProfile> {
  late mode _viewstate;
  final String bio =
      'Education & Literacy Health & Family Welfare Women\'s Development & Empowerment';

  File? profilePic;
  final List<File> workImages = [];
  late List<String> workin;

  @override
  void initState() {
    workin = widget.worksIn.split(',');
  }

  // late Reference _storageReference;
  // List<String> imageUrls = [];

  // Future<String?> uploadImageToDatabase(File image) async {
  //   print('-------@@@@@@@@@   In uploadImageToDatabase');
  //   try {
  //     _storageReference = FirebaseStorage.instance
  //         .ref()
  //         .child('Ngo')
  //         .child('${DateTime.now().microsecondsSinceEpoch}');
  //     print(
  //         '-------@@@@@@@@@##### #####   After instance --- In uploadImageToDatabase');
  //     UploadTask _storageUploadTask = _storageReference.putFile(image);
  //     print('-------@@@@@@@@@##################   In uploadImageToDatabase');
  //     TaskSnapshot snapshot = await _storageUploadTask;
  //     String imageURL = await snapshot.ref.getDownloadURL();
  //     print(
  //         '-------@@@@@@@@@################^^^^^^^^^^^^^^^^^##   In uploadImageToDatabase');
  //     return imageURL;
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: const Text('Sorry! We were unable send your image'),
  //       backgroundColor: Theme.of(context).errorColor,
  //     ));
  //     return null;
  //   }
  // }

  // void uploadImage(File image) async {
  //   String? url = await uploadImageToDatabase(image);
  //   if (url == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: const Text("Sorry! We were unable send your image"),
  //       backgroundColor: Theme.of(context).errorColor,
  //     ));
  //     return;
  //   } else {
  //     sendImageMessage(url);
  //   }
  // }

  // CollectionReference chats = FirebaseFirestore.instance.collection('NGO');
  // String? profileImgUrl;
  // sendImageMessage(String url) {
  //   chats
  //       .doc(FirebaseAuth.instance.currentUser!.uid)
  //       .update({'profileImg': url}).then(
  //     (value) {
  //       profileImgUrl = url;
  //     },
  //   ).catchError((error) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text(error.toString()),
  //       backgroundColor: Theme.of(context).errorColor,
  //     ));
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    _viewstate = widget.permission;
    // String currentUID = Provider.of<String>(context);
    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    final _size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Profile'),
        backgroundColor: AppTheme.nearlyWhite,
        foregroundColor: AppTheme.nearlyBlack,
        centerTitle: true,
        elevation: 0,
        actions: _viewstate == mode.edit
            ? [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      submitRequest();
                    },
                    child: const Icon(Icons.save),
                  ),
                )
              ]
            : null,
      ),
      body: Container(
        color: AppTheme.nearlyWhite,
        child: ListView(
          primary: true,
          padding: const EdgeInsets.all(20.0),
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: _viewstate == mode.edit
                      ? () {
                          modalProfilePicker(context);
                        }
                      : null,
                  child: profilePic == null
                      ? CircleAvatar(
                          backgroundColor: AppTheme.background,
                          child: Icon(
                            _viewstate == mode.edit
                                ? Icons.add_a_photo_outlined
                                : Icons.person,
                            color: AppTheme.grey,
                            size: 40,
                          ),
                          radius: 40,
                        )
                      : _viewstate == mode.edit
                          ? Stack(
                              children: [
                                CircleAvatar(
                                  backgroundImage:
                                      Image.file(profilePic!).image,
                                  radius: 40,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: AppTheme.nearlyBlack,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : CircleAvatar(
                              backgroundImage: Image.file(profilePic!).image,
                              radius: 40,
                            ),
                ),
                const SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: _size.width / 1.5,
                      child: Text(
                        widget.name.toUpperCase(),
                        style: AppTheme.body1.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(CupertinoIcons.mail),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          widget.email,
                          style: AppTheme.body1,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(CupertinoIcons.phone),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          widget.mobile,
                          style: AppTheme.body1,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Address:\n', style: AppTheme.title),
                  TextSpan(text: widget.address, style: AppTheme.body2),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Works In:',
              style: AppTheme.title,
            ),
            ...workin.map((item) => Text(item, style: AppTheme.body2)).toList(),
            const SizedBox(height: 10),
            const Text(
              'Bio:',
              style: AppTheme.title,
            ),
            TextFormField(
              maxLines: 3,
              readOnly: _viewstate == mode.read ? true : false,
              cursorColor: AppTheme.nearlyBlack,
              initialValue: bio,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Tell something about your NGO...'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Images',
              style: AppTheme.title,
            ),
            const Divider(
              thickness: 1,
              color: AppTheme.nearlyBlack,
            ),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              children: _viewstate == mode.edit
                  ? [
                      GestureDetector(
                        onTap: () => modalImagesPicker(context),
                        child: Container(
                          color: AppTheme.background,
                          child: const Icon(
                            Icons.add,
                            size: 50,
                            color: AppTheme.grey,
                          ),
                        ),
                      ),
                      ...workImages
                          .map(
                            (image) => Image.file(
                              image,
                              fit: BoxFit.cover,
                            ),
                          )
                          .toList(),
                    ]
                  : workImages
                      .map(
                        (image) => Image.file(
                          image,
                          fit: BoxFit.cover,
                        ),
                      )
                      .toList(),
            )
          ],
        ),
      ),
      floatingActionButton: _viewstate == mode.read
          ? FloatingActionButton(
              backgroundColor: AppTheme.nearlyBlack,
              foregroundColor: AppTheme.background,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      currentUserUid: currentUID,
                      ngoName: widget.name,
                      ngoUid: widget.ngoDocumentId,
                    ),
                  ),
                );
              },
              child: const Icon(Icons.message_rounded),
            )
          : null,
    );
  }

  final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  late Reference _storageReference;
  List<String> imageUrls = [];

  Future<void> submitRequest() async {
    print('----------Starting submit');
    // CollectionReference<Map<String, dynamic>>
    //     donationCollectionDocumentReference = FirebaseFirestore.instance
    //         .collection('NGO')
    //         .doc(widget.ngoDocumentId)
    //         .collection('WorkImage');

    DocumentReference<Map<String, dynamic>>
        userDonationRequestsCollectionDocumentReference =
        FirebaseFirestore.instance.collection('NGO').doc(widget.ngoDocumentId);

    Reference picturesUploadFirebaseStorageCollection =
        FirebaseStorage.instance.ref().child('NGO');

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      for (int i = 0; i < workImages.length; i++) {
        Reference _storageReference = picturesUploadFirebaseStorageCollection
            .child('${DateTime.now().microsecondsSinceEpoch}');
        print(
            '-------@@@@@@@@@##### #####   After instance --- In uploadImageToDatabase');
        UploadTask _storageUploadTask =
            _storageReference.putFile(workImages[i]);
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

      String? imageURL;
      if (profilePic != null) {
        Reference _storageReference = picturesUploadFirebaseStorageCollection
            .child('${DateTime.now().microsecondsSinceEpoch}');
        print(
            '-------@@@@@@@@@##### #####   After instance --- In uploadImageToDatabase');
        TaskSnapshot _storageUploadTask =
            await _storageReference.putFile(profilePic!).catchError((err) {
          print('****** ------------->>>>>>>      ${err.toString()}');
        });
        print('-------@@@@@@@@@##################   In uploadImageToDatabase');
        // TaskSnapshot snapshot = await _storageUploadTask.catchError((err) {
        // print("!!!!!---------->>.     ${err.toString()}");
        // });
        imageURL =
            await _storageUploadTask.ref.getDownloadURL().catchError((err) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text(
                'There was some problem in uploading the images! Please try again'),
            backgroundColor: Theme.of(context).errorColor,
          ));
          return err.toString();
        });
      }

      // transaction.set(donationCollectionDocumentReference, {
      //   'donationCollectionDocumentId': donationCollectionDocumentReference.id,
      //   'donatedItems': widget.donation.items,
      //   'accepted': widget.donation.accepted,
      //   'createdOn': widget.donation.createdON,
      //   'pickupDateTime': widget.donation.pickupDateTime,
      //   'pickupCoordinates': widget.donation.pickupCoordinates,
      //   'images': imageUrls,
      //   'donorId': widget.donation.donorID,
      //   'donorEmail': widget.donation.donorEmail,
      //   'donorPhone': widget.donation.donorPhone,
      //   'donorName': widget.donation.donorName,
      //   'donationCategory': widget.donation.donationCategory.index,
      //   'donorRequestId': userDonationRequestsCollectionDocumentReference.id
      // });

      print('In transaction ---starting other');
      transaction.update(userDonationRequestsCollectionDocumentReference,
          {'profileImage': imageURL, 'images': imageUrls});
    }).then((value) {
      Navigator.pop(context);
      print('In then of transaction -----------------------');
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('There was some in updating your data'),
        backgroundColor: Theme.of(context).errorColor,
      ));
    });
  }

  modalProfilePicker(BuildContext context) => showModalBottomSheet(
        context: context,
        builder: (_) {
          return SizedBox(
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  child: Row(
                    children: const [
                      Icon(
                        Icons.photo,
                        size: 40,
                      ),
                      Text(
                        'Pick from Gallery',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  onTap: () => pickProfileImage(ImageSource.gallery),
                ),
                InkWell(
                  child: Row(
                    children: const [
                      Icon(
                        Icons.photo_camera,
                        size: 40,
                      ),
                      Text(
                        'Capture a Photo',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  onTap: () => pickProfileImage(ImageSource.camera),
                ),
              ],
            ),
          );
        },
      );

  modalImagesPicker(BuildContext context) => showModalBottomSheet(
        context: context,
        builder: (_) {
          return SizedBox(
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  child: Row(
                    children: const [
                      Icon(
                        Icons.photo,
                        size: 40,
                      ),
                      Text(
                        'Pick from Gallery',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  onTap: () => pickWorkImage(ImageSource.gallery),
                ),
                InkWell(
                  child: Row(
                    children: const [
                      Icon(
                        Icons.photo_camera,
                        size: 40,
                      ),
                      Text(
                        'Capture a Photo',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  onTap: () => pickWorkImage(ImageSource.camera),
                ),
              ],
            ),
          );
        },
      );

  void cropImage(XFile file) async {
    File? croppedImage = await ImageCropper().cropImage(sourcePath: file.path);

    if (croppedImage != null) {
      setState(() {
        profilePic = croppedImage;
      });
    }
    return;
    //
  }

  void cropWorkImage(XFile file) async {
    File? croppedImage = await ImageCropper().cropImage(sourcePath: file.path);

    if (croppedImage != null) {
      setState(() {
        workImages.add(File(croppedImage.path));
      });
    }
    return;
    //
  }

  Future pickProfileImage(ImageSource imageSource) async {
    try {
      final image = await ImagePicker().pickImage(source: imageSource);
      if (image == null) return;
      cropImage(image);
    } on PlatformException catch (e) {
      Fluttertoast.showToast(msg: 'Failed to pick image: $e');
    }
  }

  Future pickWorkImage(ImageSource imageSource) async {
    try {
      final image = await ImagePicker().pickImage(source: imageSource);
      if (image == null) return;
      cropWorkImage(image);
      // setState(() {
      //   workImages.add(File(image.path));
      // });
      Navigator.pop(context);
    } on PlatformException catch (e) {
      Fluttertoast.showToast(msg: 'Failed to pick image: $e');
    }
  }
}
