import 'package:flutter/material.dart';
import 'package:flutter_learno/pages_widgets/post.dart';
import 'package:flutter_learno/screens/home.dart';
import 'package:flutter_learno/widgets/progress.dart';


class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;

  PostScreen({this.userId, this.postId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsRef
          .doc(userId)
          .collection('userPosts')
          .doc(postId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        print(snapshot.data['postId']);
        Post post = Post.fromDocument(snapshot.data);
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
              iconTheme: IconThemeData(
                color: Color(0xff615DFA), //change your color here
              ),
            title: Text(
                "Post",
                style: TextStyle(color: Color(0xff615DFA))
            ),
          ),
          body: SafeArea(
            child: ListView(
              children: <Widget>[
                Container(
                  child: post,
                ),
                SizedBox(height: 30,),
              ],
            ),
          ),
        );
      },
    );
  }
}
