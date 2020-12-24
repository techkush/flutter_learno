import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learno/pages/subjects/lessons.dart';
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
    setState(() {
      isLoading = true;
    });
    Stream<QuerySnapshot> topics = FirebaseFirestore.instance
        .collection("app_settings")
        .doc('topics')
        .collection("topicsList")
        .snapshots();
    _topicList.clear();
    topics.forEach((field) {
      field.docs.asMap().forEach((index, data) {
        if (field.docs[index]['moduleId'] == widget.moduleId) {
          _topicList.add({
            'name': field.docs[index]['name'],
            'id': field.docs[index]['id'],
            'moduleId': field.docs[index]['moduleId'],
            'mediaUrl': field.docs[index]['mediaUrl']
          });
          print(_topicList);
          setState(() {});
        }
      });
    });
    setState(() {
      isLoading = false;
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
              title: Text(widget.moduleName,
                  style: TextStyle(color: Color(0xff615DFA))),
            ),
            body: ListView(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    ClipRRect(
                      child: Image(
                        image: NetworkImage(widget.mediaUrl),
                        fit: BoxFit.cover,
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                      ),
                    ),
                    Container(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                _topicList.isEmpty
                    ? Container(
                        child: Center(
                          child: Text('No Topics.'),
                        ),
                      )
                    : Container(
                        child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount:
                                _topicList != null ? _topicList.length : 0,
                            itemBuilder: (context, i) {
                              return Column(
                                children: <Widget>[
                                  FlatButton(
                                    child: ListTile(
                                      leading: Icon(Icons.donut_small),
                                      title: Text(
                                        _topicList[i]['name'],
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 18),
                                      ),
                                      trailing: Icon(Icons.arrow_forward_ios),
                                    ),
                                    onPressed: () {
                                      print(_topicList[i]['id']);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => LessonsScreen(
                                                    lessonId: _topicList[i]
                                                        ['id'],
                                                topicName: _topicList[i]
                                                ['name'],
                                                  )));
                                    },
                                  ),
                                  Divider()
                                ],
                              );
                            }),
                      )
              ],
            ));
  }
}
