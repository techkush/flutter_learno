import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learno/widgets/progress.dart';

class TopicScreen extends StatefulWidget {
  String moduleId;
  String moduleName;
  String mediaUrl;

  TopicScreen({this.moduleId, this.moduleName, this.mediaUrl});

  @override
  _TopicScreenState createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  bool isLoading = false;
  List<Map<String, dynamic>> _topicList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getModuleList();
  }

  Future<void> getModuleList() async {
    Stream<QuerySnapshot> modules = FirebaseFirestore.instance
        .collection("app_settings")
        .doc('topics')
        .collection("topicsList")
        .snapshots();
    _topicList.clear();
    modules.forEach((field) {
      field.docs.asMap().forEach((index, data) {
        if (field.docs[index]['moduleId'] == widget.moduleId) {
          _topicList.add({
            'name': field.docs[index]['name'],
            'id': field.docs[index]['id'],
            'subjectId': field.docs[index]['subjectId'],
            'mediaUrl': field.docs[index]['mediaUrl']
          });
          print(_topicList);
          setState(() {
            isLoading = false;
          });
        }
      });
    });
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
              elevation: 0,
              iconTheme: IconThemeData(
                color: Color(0xff615DFA), //change your color here
              ),
              title: Text("Topics", style: TextStyle(color: Color(0xff615DFA))),
            ),
            body: ListView(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                      child: Image(
                        image: NetworkImage(widget.mediaUrl),
                        fit: BoxFit.cover,
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                           widget.moduleName,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                _topicList.isEmpty
                    ? Container(
                        child: Center(
                          child: Text('No data found.'),
                        ),
                      )
                    : Container()
              ],
            ));
  }
}
