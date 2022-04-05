import 'package:flutter/material.dart';
import 'package:ngo/apptheme.dart';

import 'cache_image_message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble(this.msg, this.isMe, this.type
      // this.key
      );
  final String msg;
  final bool isMe;
  final String type;

  // final Key key;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          type == 'image'
              ? CacheImageMessage(
                  msg: msg,
                  isMe: isMe,
                )
              : Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blueAccent : Colors.purple,
                    borderRadius: isMe
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          )
                        : const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    msg,
                    style: AppTheme.body3,
                  ),
                ),
        ],
      ),
    );
  }
}
