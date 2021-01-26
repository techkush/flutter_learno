import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  String lessonId;
  String topicName;

  QuizScreen({this.lessonId, this.topicName});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool isLoading = false;
  List<Map> _quizList = [];
  double totalMarks = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getQuizList();
  }

  Future<void> getQuizList() async {
    setState(() {
      isLoading = true;
    });

    FirebaseFirestore.instance
        .collection("app_settings")
        .doc('quiz')
        .collection("quizList")
        .doc(widget.lessonId)
        .get()
        .then((DocumentSnapshot snapshot) {
      QuestionModel _school = QuestionModel.fromDocument(snapshot);
      for (final e in _school.questionList) {
        _quizList.add(e);
      }
      print(_quizList);

      setState(() {
        isLoading = false;
      });
    });
  }

  var _questionIndex = 0;
  var _totalScore = 0;

  void _resetQuiz() {
    setState(() {
      _questionIndex = 0;
      _totalScore = 0;
    });
  }

  void _answerQuestion(int score) {
    _totalScore += score;

    setState(() {
      _questionIndex = _questionIndex + 1;
    });
    print(_questionIndex);
    if (_questionIndex < _quizList.length) {
      print('We have more questions!');
    } else {
      setTotalMarks();
      print('No more questions!');
    }
  }

  void setTotalMarks() {
    setState(() {
      totalMarks = (100 * _totalScore) / (_quizList.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            body: Center(child: CircularProgressIndicator()),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(
                color: Color(0xff615DFA), //change your color here
              ),
              title: _questionIndex < _quizList.length
                  ? Text(
                      '${widget.topicName} Quiz - ${_questionIndex + 1}/${_quizList.length}',
                      style: TextStyle(color: Color(0xff615DFA)))
                  : Text('${widget.topicName} Quiz - Results',
                      style: TextStyle(color: Color(0xff615DFA))),
            ),
            body: _questionIndex < _quizList.length
                ? Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.all(10),
                          child: Text(
                            _quizList[_questionIndex]['question'],
                            style:
                                TextStyle(fontSize: 28, color: Colors.purple),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount:
                              _quizList[_questionIndex]['answers'].length,
                          itemBuilder: (context, i) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              child: Column(
                                children: [
                                  FlatButton(
                                    child: Text(
                                      '${i + 1}. ${_quizList[_questionIndex]['answers'][i]['answer']}',
                                      style: TextStyle(fontSize: 25),
                                      textAlign: TextAlign.center,
                                    ),
                                    onPressed: () {
                                      _quizList[_questionIndex]['answers'][i]
                                                  ['correct'] ==
                                              true
                                          ? _answerQuestion(1)
                                          : _answerQuestion(0);
                                    },
                                  ),
                                  SizedBox(
                                    height: 12,
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Total Marks',
                          style: TextStyle(fontSize: 25, color: Colors.purple),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          '${totalMarks.truncate()}',
                          style: TextStyle(fontSize: 85, color: Colors.purple),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        RaisedButton(
                          onPressed: _resetQuiz,
                          child: Text('Reset Quiz', style: TextStyle(color: Colors.white),),
                          color: Colors.purple,
                        )
                      ],
                    ),
                  ),
          );
  }
}

class QuestionModel {
  List questionList;

  QuestionModel({this.questionList});

  factory QuestionModel.fromDocument(DocumentSnapshot doc) {
    return QuestionModel(questionList: doc['questionList']);
  }
}
