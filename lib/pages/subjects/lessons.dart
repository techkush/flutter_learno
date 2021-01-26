import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learno/pages/subjects/quiz.dart';
import 'package:flutter_learno/widgets/auth_button.dart';

// ignore: must_be_immutable
class LessonsScreen extends StatefulWidget {
  String lessonId;
  String topicName;

  LessonsScreen({this.lessonId, this.topicName});

  @override
  _LessonsScreenState createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  bool isLoading = false;
  List<dynamic> _lessons = [];
  final controller = PageController(initialPage: 0);
  int pageNumber = 1;

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
    final lessons = FirebaseFirestore.instance
        .collection("app_settings")
        .doc('lessons')
        .collection("lessonsList")
        .snapshots();
    _lessons.clear();
    lessons.forEach((field) {
      field.docs.asMap().forEach((index, data) {
        if (field.docs[index].id == widget.lessonId) {
          //print(data['lessonsList']);
          _lessons.addAll(data['lessonsList']);
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
    print(_lessons);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Color(0xff615DFA), //change your color here
          ),
          title: Text('${widget.topicName}  $pageNumber/${_lessons.length}',
              style: TextStyle(color: Color(0xff615DFA))),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 5,
            child: Center(
                child: PageView.builder(
                    controller: controller,
                    itemCount: _lessons.length + 1,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (value) {
                      if (_lessons.length == value) {
                        setState(() {});
                      } else {
                        setState(() {
                          pageNumber = value + 1;
                        });
                      }
                    },
                    itemBuilder: (context, index) {
                      if (_lessons.length == index) {
                        return Container(
                          height: MediaQuery.of(context).size.height - 50,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  'Thank you.!',
                                  style: TextStyle(
                                      fontSize: 30, color: Color(0xff615DFA)),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Container(
                                width: 200,
                                child: AuthButton(
                                    handleFunction: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  QuizScreen(lessonId: widget.lessonId, topicName: widget.topicName,)));
                                    },
                                    name: 'Quiz'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Container(
                          height: MediaQuery.of(context).size.height - 50,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  '${_lessons[index]['description']}',
                                  style: TextStyle(fontSize: 30),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    })),
          ),
        ));
  }
}
