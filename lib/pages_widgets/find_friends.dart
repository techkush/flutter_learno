import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_learno/models/user.dart';
import 'package:flutter_learno/pages_widgets/user_result.dart';
import 'package:flutter_learno/screens/home.dart';
import 'package:flutter_learno/widgets/progress.dart';

class FindFriends extends StatefulWidget {
  @override
  _FindFriendsState createState() => _FindFriendsState();
}

class _FindFriendsState extends State<FindFriends> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;

  handleSearch(String query) {
    Future<QuerySnapshot> users = usersRef
        .where('displayName', isGreaterThanOrEqualTo: query)
        .getDocuments();
    setState(() {
      searchResultsFuture = users;
    });
  }


  buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: TextFormField(
          controller: searchController,
          style: TextStyle(fontSize: 18),
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: "Search for a user..",
            filled: false,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            prefixIcon: Icon(FeatherIcons.search, size: 28),
            suffixIcon: IconButton(
              icon: Icon(FeatherIcons.x),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
          ),
          onFieldSubmitted: handleSearch),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildSearchField(),
      body: searchResultsFuture == null
          ? Center(
              child: Text('No users!'),
            )
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: buildSearchResults(),
            ),
    );
  }

  buildSearchResults() {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        } else {
          List<UserResult> searchResults = [];
          snapshot.data.documents.forEach((doc) {
            LearnoUser user = LearnoUser.fromDocument(doc);
            UserResult searchResult = UserResult(user);
            searchResults.add(searchResult);
          });
          return ListView(
            children: searchResults,
          );
        }
      },
    );
  }
}
