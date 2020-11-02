import 'package:flutter/material.dart';

Widget profileImage(String photo, String name) {
  return photo == null
      ? CircleAvatar(
          child: Text(
            '${name[0]}',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          backgroundColor: Color(0xff615DFA),
        )
      : CircleAvatar(
          backgroundColor: Colors.grey,
          backgroundImage: NetworkImage(photo),
        );
}
