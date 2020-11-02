import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learno/screens/home.dart';
import 'package:flutter_learno/widgets/progress.dart';

import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  Comments({
    this.postId,
    this.postOwnerId,
    this.postMediaUrl,
  });

  @override
  CommentsState createState() => CommentsState(
        postId: this.postId,
        postOwnerId: this.postOwnerId,
        postMediaUrl: this.postMediaUrl,
      );
}

class CommentsState extends State<Comments> {
  TextEditingController commentController = TextEditingController();
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  CommentsState({
    this.postId,
    this.postOwnerId,
    this.postMediaUrl,
  });

  bool buttonVisible = false;

  buildComments() {
    return StreamBuilder(
        stream: commentsRef
            .doc(postId)
            .collection('comments')
            .orderBy("timestamp", descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<Comment> comments = [];
          snapshot.data.documents.forEach((doc) {
            comments.add(Comment.fromDocument(doc));
          });
          return ListView(
            children: comments,
          );
        });
  }

  addComment() {
    commentsRef.doc(postId).collection("comments").add({
      "username": currentUser.displayName,
      "comment": commentController.text,
      "timestamp": DateTime.now(),
      "avatarUrl": currentUser.photoUrl,
      "userId": currentUser.id,
    });
    bool isNotPostOwner = postOwnerId != currentUser.id;
    if (isNotPostOwner) {
      notificationRef
          .doc(postOwnerId)
          .collection('notificationItems')
          .add({
        "type": "comment",
        "commentData": commentController.text,
        "timestamp": DateTime.now(),
        "postId": postId,
        "userId": currentUser.id,
        "username": currentUser.displayName,
        "userProfileImg": currentUser.photoUrl,
        "mediaUrl": postMediaUrl,
      });
    }
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            "Comments",
            style: TextStyle(color: Color(0xff615DFA)),
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(
            color: Color(0xff615DFA), //change your color here
          )),
      body: Column(
        children: <Widget>[
          Expanded(child: buildComments()),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              onChanged: (val) {
                if (val.length >= 1) {
                  setState(() {
                    buttonVisible = true;
                  });
                } else {
                  setState(() {
                    buttonVisible = false;
                  });
                }
              },
              cursorColor: Color(0xff615DFA),
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(
                  labelText: "Write a comment...",
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  labelStyle: TextStyle(color: Color(0xff615DFA))),
            ),
            trailing: OutlineButton(
              onPressed: buttonVisible ? addComment : null,
              borderSide: BorderSide.none,
              child: Text("Post"),
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;

  Comment({
    this.username,
    this.userId,
    this.avatarUrl,
    this.comment,
    this.timestamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc['username'],
      userId: doc['userId'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
      avatarUrl: doc['avatarUrl'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(comment),
          leading: avatarUrl == null
              ? CircleAvatar(
                  child: Text(
                    '${username[0]}',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  backgroundColor: Color(0xff615DFA),
                )
              : CircleAvatar(
                  backgroundColor: Colors.grey,
                  backgroundImage: NetworkImage(avatarUrl),
                ),
          subtitle: Text(timeago.format(timestamp.toDate())),
        ),
        Divider(),
      ],
    );
  }
}
