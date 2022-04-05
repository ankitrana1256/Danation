import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ngo/apptheme.dart';

class LastMessageContainer extends StatelessWidget {
  final future;

  LastMessageContainer({
    @required this.future,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: future,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          print("@@@@!!!!-->>>  ${snapshot.data!.docs}");
          if (snapshot.data!.docs.isNotEmpty) {
            var docId = snapshot.data!.docs.single.id;
            print("@@@@-->>>  $docId");
            // if (docId.isNotEmpty) {
            // Message message = Message.fromMap(docList.last.data);
            // Map<String, dynamic> lastMessage = docList.last.data as Map<String,dynamic>;
            return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('usersChats')
                    .doc(docId)
                    .collection('messages')
                    .orderBy("createdOn")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    const Center(
                      child: Text(
                          "There was some error in fetching the last messages!"),
                    );
                  }
                  //TODO: Commented Code
                  //
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  }

                  var lastMessage =
                      snapshot.data!.docs.last.data() as Map<String, dynamic>;
                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text(lastMessage['msg'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.caption),
                  );
                });
          }

          return const Text(
            "No message to show",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          );
        }
        return const Text(
          "..",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        );
      },
    );
  }
}
