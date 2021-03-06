import 'package:flutter/material.dart';
import 'package:flutter_learno/pages_widgets/post.dart';
import 'package:flutter_learno/pages_widgets/post_screen.dart';
import 'package:flutter_learno/widgets/custom_image.dart';


class PostTile extends StatelessWidget {
  final Post post;

  PostTile(this.post);

  showPost(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: post.postId,
          userId: post.ownerId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPost(context),
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}