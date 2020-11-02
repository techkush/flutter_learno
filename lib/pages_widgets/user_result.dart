import 'package:flutter/material.dart';
import 'package:flutter_learno/models/user.dart';
import 'package:flutter_learno/pages/notifications.dart';

class UserResult extends StatelessWidget {
  final LearnoUser user;

  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white60,
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: ListTile(
              leading: user.photoUrl == null
                  ? CircleAvatar(
                      radius: 30,
                      child: Text(
                        '${user.displayName[0]}',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      backgroundColor: Color(0xff615DFA),
                    )
                  : CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(user.photoUrl),
                    ),
              title: Text(
                user.displayName,
                style:
                    TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                user.school,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          SizedBox(height: 3,),
          Divider(
            height: 2.0,
            color: Colors.white54,
          )
        ],
      ),
    );
  }
}
