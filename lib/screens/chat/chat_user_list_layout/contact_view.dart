import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ngo/apptheme.dart';
import '../chat_screen.dart';
import 'custom_tile.dart';
import 'last_send_message.dart';

class ContactView extends StatelessWidget {
  final Map<String, dynamic> contact;
  final String currentUserUid;
  // final String contactId;
  ContactView(this.contact, this.currentUserUid);

  @override
  Widget build(BuildContext context) {
    // print("****--->>>>  ${contact['uid']}");
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('NGO')
          .doc(contact['uid'])
          .get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          const Center(
            child: Text(
                "There was some error in fetching details for this contact. Please try again"),
          );
        }

        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return Center(child: const CircularProgressIndicator());
        // }

        if (snapshot.hasData && snapshot.data!.exists) {
          Map<String, dynamic> ngoData = snapshot.data!.data() as Map<String,
              dynamic>; //TODO: To check here-- only ngo name is being fetched in futurebuilder
          print("^^^^--->>  $ngoData");
          return ViewLayout(
              ngoData: ngoData,
              currentUserUid: currentUserUid,
              contact: contact);
        }
        return SizedBox.shrink();
        // return const Center(
        //   child: Text("Looks like there is not data present for this NGO."),
        // );
      },
    );
  }
}

class ViewLayout extends StatelessWidget {
  final Map<String, dynamic> ngoData;
  final String currentUserUid;
  final Map<String, dynamic> contact;
  ViewLayout(
      {required this.ngoData,
      required this.currentUserUid,
      required this.contact});

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    // print("####--->>>  ${contact['uid']}");
    return CustomTile(
      mini: false,
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              ngoName: ngoData['name'],
              currentUserUid: currentUserUid,
              ngoUid: contact['uid'],
            ),
          )),
      title: SizedBox(
        width: _size.width / 1.4,
        child: Text(
          (ngoData != null ? ngoData['name'] : null) != null
              ? ngoData['name']
              : "..",
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.title,
        ),
      ),
      subtitle: LastMessageContainer(
        future: FirebaseFirestore.instance
            .collection('usersChats')
            .where('users',
                isEqualTo: {"donor": currentUserUid, "ngo": contact['uid']})
            .limit(1)
            .snapshots(),
      ),
      leading: Container(
        constraints: const BoxConstraints(maxHeight: 60, maxWidth: 60),
        child: Stack(
          children: <Widget>[
            // CircleAvatar(
            //     // child: Image.asset(),
            //     )
            // CachedImage(
            //   contact.profilePhoto,
            //   radius: 80,
            //   isRound: true,
            // ),
            // OnlineDotIndicator(
            //   uid: contact.uid,
            // ),
            Container(
              height: 80,
              width: 60,
              decoration: BoxDecoration(
                color: AppTheme.grey,
                border: Border.all(width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                CupertinoIcons.house_fill,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
