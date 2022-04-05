import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ngo/apptheme.dart';
import 'messages.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen(
      {required this.ngoUid,
      required this.ngoName,
      required this.currentUserUid});

  final String ngoUid;
  final String ngoName;
  final String currentUserUid;
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  CollectionReference chats =
      FirebaseFirestore.instance.collection('usersChats');
  // final currentUserUid = FirebaseAuth.instance.currentUser!.uid; // TODO: To make a new class to store the current user uid and other details
  var chatDocumentId;
  final _textController = TextEditingController();
  late Reference _storageReference;
  late File imageFile;

  @override
  void initState() {
    super.initState();
  }

  Future<String?> uploadImageToDatabase(File image) async {
    try {
      _storageReference = FirebaseStorage.instance
          .ref()
          .child('Chat')
          .child('${DateTime.now().microsecondsSinceEpoch}');
      UploadTask _storageUploadTask = _storageReference.putFile(image);

      TaskSnapshot snapshot = await _storageUploadTask;
      String imageURL = await snapshot.ref.getDownloadURL();
      return imageURL;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Sorry! We were unable send your image"),
        backgroundColor: Theme.of(context).errorColor,
      ));
      return null;
    }
  }

  sendImageMessage(String url) {
    // FocusScope.of(context).unfocus();
    chats.doc(chatDocumentId).collection('messages').add({
      'createdOn': DateTime.now(), //FieldValue.serverTimestamp()
      'msg': url,
      'uid': widget.currentUserUid,
      'type': 'image'
    }).then((value) {
      _textController.text = '';
      addToContacts(senderId: widget.currentUserUid, receiverId: widget.ngoUid);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.toString()),
        backgroundColor: Theme.of(context).errorColor,
      ));
    });
  }

  void uploadImage(File image) async {
    String? url = await uploadImageToDatabase(image);
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Sorry! We were unable send your image"),
        backgroundColor: Theme.of(context).errorColor,
      ));
      return;
    } else {
      sendImageMessage(url);
    }
  }

  void sendMessage(String msg) {
    // FocusScope.of(context).unfocus();
    chats.doc(chatDocumentId).collection('messages').add({
      'createdOn': DateTime.now(), //FieldValue.serverTimestamp()
      'msg': msg,
      'uid': widget.currentUserUid,
      'type': 'text',
    }).then((value) {
      _textController.text = '';
      addToContacts(senderId: widget.currentUserUid, receiverId: widget.ngoUid);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.toString()),
        backgroundColor: Theme.of(context).errorColor,
      ));
    });
  }

  Future<void> addToSenderContacts(
      String senderId, String receiverId, Timestamp currentTime) async {
    DocumentSnapshot<Map<String, dynamic>> senderSnapshot =
        await FirebaseFirestore.instance
            .collection("users")
            .doc(senderId)
            .collection('chatContacts')
            .doc(receiverId)
            .get();

    if (!senderSnapshot.exists) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(senderId)
          .collection('chatContacts')
          .doc(receiverId)
          .set({
        'uid': receiverId,
        'addedOn': currentTime,
      });
    }
  }

  Future<void> addToReceiverContacts(
      String senderId, String receiverId, Timestamp currentTime) async {
    DocumentSnapshot<Map<String, dynamic>> senderSnapshot =
        await FirebaseFirestore.instance
            .collection("NGO")
            .doc(receiverId)
            .collection('chatContacts')
            .doc(senderId)
            .get();

    if (!senderSnapshot.exists) {
      await FirebaseFirestore.instance
          .collection("NGO")
          .doc(receiverId)
          .collection('chatContacts')
          .doc(senderId)
          .set({
        'uid': senderId,
        'addedOn': currentTime,
      });
    }
  }

  addToContacts({required String senderId, required String receiverId}) async {
    Timestamp currentTime = Timestamp.now();

    await addToSenderContacts(senderId, receiverId, currentTime);
    await addToReceiverContacts(senderId, receiverId, currentTime);
  }

  Future pickImageFromGallery() async {
    try {
      var image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        cropImage(image);
      }

      return;
    } on PlatformException {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("There was some error in fetching your image"),
        backgroundColor: Theme.of(context).errorColor,
      ));
    }
  }

  void cropImage(XFile file) async {
    File? croppedImage = await ImageCropper().cropImage(sourcePath: file.path);

    if (croppedImage != null) {
      uploadImage(croppedImage);
      // setState(() {
      //   imageFile = croppedImage;
      // });
    }
    return;
    //
  }

  Future getImageFromCamera() async {
    try {
      XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) {
        return;
      }
      final imageTemp = XFile(image.path);
      setState(() {
        image = imageTemp;
      });
    } on PlatformException {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("There was some error in fetching your image"),
        backgroundColor: Theme.of(context).errorColor,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: chats
            .where('users', isEqualTo: {
              "donor": widget.currentUserUid,
              "ngo": widget.ngoUid
            })
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            const Center(
              child: Text(
                  "There was some error in fetching the chat. Please try again"),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasData) {
            if (snapshot.data!.docs.isNotEmpty) {
              //TODO: SEE an error is occurring in terminal
              chatDocumentId = snapshot.data!.docs.single.id;
            } else {
              chats.add({
                'users': {"donor": widget.currentUserUid, "ngo": widget.ngoUid}
              }).then((value) {
                chatDocumentId = value.id;
              });
            }

            return Scaffold(
              appBar: AppBar(
                backgroundColor: AppTheme.button,
                title: Text(
                  widget.ngoName,
                  softWrap: true,
                ),
              ),
              body: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                          child:
                              Messages(chatDocumentId, widget.currentUserUid)),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // FloatBoxPanel(
                            // onTapDown: (details){
                            //   var box = (context.findRenderObject() as RenderBox).globalToLocal(details.globalPosition);
                            //   // final Offset localOffset = box.globalToLocal(details.globalPosition);
                            //   // final RenderBox containerBox = key.currentContext.findRenderObject();
                            //   // final Offset containerOffset = containerBox.localToGlobal(localOffset);
                            //   // final onTap = containerBox.paintBounds.contains(containerOffset);
                            //   var tophalf = box.dy < 250;
                            //   var topright = box.dx <250;
                            //   if (tophalf && topright){
                            //     print("DO YOUR STUFF...");
                            //   }
                            // },

                            // buttons:
                            // ExpandableImages(
                            //   distance: 90.0,
                            //   // children: [

                            // ActionButton(
                            //     onPressed: () => getImageFromCamera(),
                            //     icon: const Icon(Icons.camera),
                            //   ),
                            //   // ActionButton(
                            //   //   onPressed: ()=>pickImageFromGallery(),
                            //   //   icon: const Icon(Icons.add_photo_alternate),
                            //   // ),
                            //   // ],
                            // ),
                            IconButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (_) {
                                    return SizedBox(
                                      height: 100,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                              ],
                                            ),
                                            onTap: () => pickImageFromGallery(),
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
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                              ],
                                            ),
                                            onTap: () => getImageFromCamera(),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.camera),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _textController,
                                decoration: const InputDecoration(
                                    labelText: 'Send a message..'),
                              ),
                            ),
                            InkWell(
                              child: const Icon(Icons.send),
                              onTap: () {
                                return _textController.text.trim().isEmpty
                                    ? null
                                    : sendMessage(_textController.text);
                              },
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text("Fetching your data..."),
            );
          }
        });
  }
}
