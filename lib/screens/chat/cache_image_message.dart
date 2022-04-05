// import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// import 'package:ngo_chat_page/providers/chat_screen_provider.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_screen_provider.dart';

class CacheImageMessage extends StatelessWidget {
  const CacheImageMessage({Key? key, required this.msg, required this.isMe})
      : super(key: key);

  final String msg;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatScreenProvider>(
      builder: (BuildContext context, value, Widget? child) {
        return InteractiveViewer(
          panEnabled: false, // Set it to false
          boundaryMargin: const EdgeInsets.all(100),
          minScale: 0.5,
          maxScale: 2,
          child: Container(
            decoration: BoxDecoration(
              color: isMe ? Colors.black : Colors.blueAccent,
              borderRadius: isMe
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12))
                  : const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12)),
            ),
            // width: 140, //TODO: Need to check for long messages
            padding: const EdgeInsets.all(10),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
                maxHeight: 200),
            clipBehavior: Clip.hardEdge,
            child: CachedNetworkImage(
              imageUrl: msg,
              placeholder: (context, msg) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, string, dynamic) {
                value.imageOnTapAvailability = ImageOnTapAvailability
                    .no; //TODO: Check the zooming capability
                return const Text(
                    "There was some error in fetching the image! ☹️");
              },
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}
