import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'message_bubble.dart';

class Messages extends StatefulWidget {
  // const Messages({Key? key}) : super(key: key);
  Messages(this.chatDocumentId, this.currentUserUid);
  final chatDocumentId;
  final currentUserUid;
  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usersChats')
          .doc(widget.chatDocumentId)
          .collection('messages')
          .orderBy('createdOn', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("${snapshot.error.toString()}. Retrying..."),
            backgroundColor: Theme.of(context).errorColor,
          ));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Map<String, dynamic> data;
        final chatDocs = snapshot.data!.docs;
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          //TODO: To check in what case there would be no data in snapshot
          return const Padding(
            padding: EdgeInsets.all(10.0),
            child: Center(
              child: Text(
                  "No Conversations here!! Start a conversation to see your chat"),
            ),
          );
        } else {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                    reverse: true,
                    itemCount: chatDocs.length,
                    itemBuilder: (ctx, index) {
                      return MessageBubble(
                        chatDocs[index]['msg'],
                        chatDocs[index]['uid'] == widget.currentUserUid,
                        chatDocs[index]['type'],
                      );
                    }),
              ),
            ],
          );
        }
        //   ListView(
        //   reverse: true,
        //   children: snapshot.data!.docs.map((DocumentSnapshot document) {
        //     // data = document.data() as Map<String, dynamic>;
        //     return MessageBubble(
        //       document['msg'],
        //       document['uid'] == widget.currentUserUid,
        //       // key:ValueKey(chatDocs.) // TODO: suggest to add key
        //     );
        //   }).toList(),
        // );

        // else {
        //   return Container();
        // }
      },
    );
  }
}
