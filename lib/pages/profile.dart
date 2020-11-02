import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_learno/models/user.dart';
import 'package:flutter_learno/pages_widgets/find_friends.dart';
import 'package:flutter_learno/pages_widgets/post.dart';
import 'package:flutter_learno/pages_widgets/upload.dart';
import 'package:flutter_learno/screens/home.dart';
import 'package:flutter_learno/widgets/post_tile.dart';
import 'package:flutter_learno/widgets/progress.dart';

class Profile extends StatefulWidget {
  final String profileId;
  final bool backButton;

  Profile({this.profileId, @required this.backButton});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isFollowing = false;
  bool isLoading = false;
  int postCount = 0;
  String postOrientation = "grid";
  List<Post> posts = [];
  String backPostsUpload;
  LearnoUser profileData;
  int followerCount = 0;
  int followingCount = 0;

  @override
  void initState() {
    super.initState();
    getProfilePost(false);
    getProfileData();
    checkIfFollowing();
    getFollowers();
    getFollowing();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .get();
    setState(() {
      followerCount = snapshot.docs.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(widget.profileId)
        .collection('userFollowing')
        .get();
    setState(() {
      followingCount = snapshot.docs.length;
    });
  }


  getProfilePost(bool uploadTime) async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .doc(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
    if (uploadTime) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getProfileData() async {
    DocumentSnapshot doc = await usersRef.doc(widget.profileId).get();
    setState(() {
      profileData = LearnoUser.fromDocument(doc);
      isLoading = false;
    });
  }

  buildProfileHeader() {
    return Padding(
      padding: EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 10),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            CircleAvatar(
              radius: 42.0,
              backgroundColor: Colors.blueGrey,
              child: profileData.photoUrl == null
                  ? CircleAvatar(
                      radius: 40.0,
                      child: Text(
                        '${profileData.firstName[0]}',
                        style: TextStyle(fontSize: 40, color: Colors.white),
                      ),
                      backgroundColor: Color(0xff615DFA),
                    )
                  : CircleAvatar(
                      radius: 40.0,
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(profileData.photoUrl),
                    ),
            ),
            SizedBox(
              width: 20,
            ),
            buildCountColumn('Posts', postCount),
            SizedBox(
              width: 5,
            ),
            buildCountColumn('Followers', followerCount),
            SizedBox(
              width: 5,
            ),
            buildCountColumn('Following', followingCount),
            SizedBox(
              width: 5,
            ),
          ],
        ),
      ),
    );
  }

  buildProfileDetails() {
    return Padding(
        padding: EdgeInsets.only(top: 5, left: 30, right: 40, bottom: 10),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              userDetails(),
              buildLeftIconButton(),
            ],
          ),
        ));
  }

  // ignore: missing_return
  Widget buildProfileButtons() {
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildCurrentButtons();
    } else if (isFollowing) {
      return buildVisitButtons("Unfollow", handleUnFollowUser);
    } else if (!isFollowing) {
      return buildVisitButtons("Follow", handleFollowUser);
    }
  }

  handleUnFollowUser() {
    setState(() {
      isFollowing = false;
    });
    // remove follower
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // remove following
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // delete activity feed item for them
    notificationRef
        .doc(widget.profileId)
        .collection('notificationItems')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollowUser(){
    setState(() {
      isFollowing = true;
    });
    // Make auth user follower of THAT user (update THEIR followers collection)
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .set({});
    // Put THAT user on YOUR following collection (update your following collection)
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({});
    // add activity feed item for that user to notify about new follower (us)
    notificationRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .set({
      "type": "follow",
      "ownerId": widget.profileId,
      "username": currentUser.displayName,
      "userId": currentUserId,
      "userProfileImg": currentUser.photoUrl,
      "timestamp": DateTime.now(),
    });
  }

  Widget buildLeftIconButton() {
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return IconButton(
        icon: Icon(
          FeatherIcons.camera,
          color: Color(0xff615DFA),
        ),
        onPressed: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Upload(
                        currentUser: currentUser,
                      )));
          getProfilePost(true);
        },
      );
    } else {
      return Container();
    }
  }

  buildCurrentButtons() {
    return Padding(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                height: 30,
                width: MediaQuery.of(context).size.width / 2 - 30,
                child: RaisedButton(
                  child: Text('Edit Profile'),
                  onPressed: () {
                    //getProfilePost();
                  },
                ),
              ),
              Container(
                height: 30,
                width: MediaQuery.of(context).size.width / 2 - 30,
                child: RaisedButton(
                  child: Text('Find Friends'),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => FindFriends()));
                  },
                ),
              )
            ],
          ),
        ));
  }

  buildVisitButtons(String text, Function function) {
    return Padding(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                height: 30,
                width: MediaQuery.of(context).size.width / 2 - 30,
                child: RaisedButton(
                  child: Text(text, style: TextStyle(color: isFollowing ? Colors.black : Color(0xff615DFA)),),
                  onPressed: function,
                ),
              ),
              Container(
                height: 30,
                width: MediaQuery.of(context).size.width / 2 - 30,
                child: RaisedButton(
                  child: Text('Contact'),
                  onPressed: () {},
                ),
              )
            ],
          ),
        ));
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 60.0),
              child: Text(
                "No Posts",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 40.0,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (postOrientation == "grid") {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(GridTile(child: PostTile(post)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    } else if (postOrientation == "list") {
      return Column(
        children: posts,
      );
    }
  }

  setPostOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: () => setPostOrientation("grid"),
          icon: Icon(Icons.grid_on),
          color: postOrientation == 'grid' ? Color(0xff615DFA) : Colors.grey,
        ),
        IconButton(
          onPressed: () => setPostOrientation("list"),
          icon: Icon(Icons.list),
          color: postOrientation == 'list' ? Color(0xff615DFA) : Colors.grey,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            body: Center(
              child: circularProgress(),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              automaticallyImplyLeading: widget.backButton,
              iconTheme: IconThemeData(
                color: Color(0xff615DFA), //change your color here
              ),
              title: Text("${profileData.displayName}",
                  style: TextStyle(color: Color(0xff615DFA))),
            ),
            body: ListView(
              children: <Widget>[
                buildProfileHeader(),
                buildProfileDetails(),
                buildProfileButtons(),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Divider(
                    height: 0,
                  ),
                ),
                buildTogglePostOrientation(),
                Divider(
                  height: 0.0,
                ),
                buildProfilePosts(),
                SizedBox(
                  height: 10,
                )
              ],
            ),
          );
  }

  Column userDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          '${profileData.firstName} ${profileData.lastName}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 2,
        ),
        Text('${profileData.school} | ${profileData.userRole}')
      ],
    );
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
                color: Colors.grey,
                fontSize: 15.0,
                fontWeight: FontWeight.w400),
          ),
        )
      ],
    );
  }
}
