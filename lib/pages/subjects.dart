import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learno/models/levels.dart';
import 'package:flutter_learno/pages/subjects/modules.dart';
import 'package:flutter_learno/widgets/progress.dart';

class Subjects extends StatefulWidget {
  @override
  _SubjectsState createState() => _SubjectsState();
}

class _SubjectsState extends State<Subjects> {
  bool isLoading = false;
  List<String> _levelList = [];
  List<Map<String, dynamic>> _subjectList = [];
  String selectedValue;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLevelList();
  }

  Future<void> getLevelList() async {
    setState(() {
      isLoading = true;
    });
    final DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('app_settings')
        .doc('levels')
        .get();
    if (doc.exists) {
      Levels _levels = Levels.fromDocument(doc);
      for (final e in _levels.levelList) {
        _levelList.add(e);
      }
      print(_levelList);
      getModuleList(_levelList[0]);
    }
    setState(() {
      isLoading = false;
      selectedValue = _levelList[0];
    });

  }

  // ignore: missing_return
  Future<void> getModuleList(String item) async {
    Stream<QuerySnapshot> modules = FirebaseFirestore.instance
        .collection("app_settings")
        .doc('subjects')
        .collection("subjectList")
        .snapshots();
    _subjectList.clear();
    modules.forEach((field) {
      field.docs.asMap().forEach((index, data) {
        if (field.docs[index]['level'] == item) {
          _subjectList.add({
            'name': field.docs[index]['name'],
            'id': field.docs[index]['id'],
            'level': field.docs[index]['level'],
            'mediaUrl': field.docs[index]['mediaUrl']
          });
          print(field.docs[index]['name']);
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
        : _levelList.isEmpty
            ? Center(
                child: Text('No Values.'),
              )
            : Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  iconTheme: IconThemeData(
                    color: Color(0xff615DFA), //change your color here
                  ),
                  title: Text("Subjects",
                      style: TextStyle(color: Color(0xff615DFA))),
                ),
                body: SingleChildScrollView(
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 20,
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _levelList
                                  .map((item) => levelListWidget(item))
                                  .toList(),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Container(
                            child: Text(
                              'Subjects',
                              style: TextStyle(
                                  color: Color(0xff615DFA), fontSize: 25),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Column(
                            children: _subjectList
                                .map((item) => moduleListWidget(item))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
  }

  Widget levelListWidget(String item) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: InkWell(
          onTap: () {
            setState(() {
              selectedValue = item;
            });
            getModuleList(item);
          },
          child: Container(
              height: 40,
              decoration: BoxDecoration(
                  border: Border.all(color: Color(0xff615DFA), width: 3.0),
                  color:
                      selectedValue == item ? Color(0xff615DFA) : Colors.white,
                  borderRadius: BorderRadius.circular(20)),
              child: Center(
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  item,
                  style: TextStyle(
                      fontSize: 18,
                      color:
                          selectedValue == item ? Colors.white : Colors.black),
                ),
              ))),
        ),
      ),
    );
  }

  Widget moduleListWidget(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ModuleList(item['id'], item['name'])));
        },
        child: Container(
          height: 150,
          width: MediaQuery.of(context).size.width - 40,
          decoration: BoxDecoration(
              color: Color(0xff615DFA),
              borderRadius: BorderRadius.circular(10)),
          child: Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image(
                  image: NetworkImage(item['mediaUrl']),
                  fit: BoxFit.cover,
                  height: 150,
                  width: MediaQuery.of(context).size.width - 40,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      item['name'],
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
        ),
      ),
    );
  }
}
