import 'package:cloud_firestore/cloud_firestore.dart';

class Levels {
  List levelList;

  Levels({this.levelList});

  factory Levels.fromDocument(DocumentSnapshot doc) {
    return Levels(levelList: doc['levels']);
  }
}
