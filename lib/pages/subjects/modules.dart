import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learno/pages/subjects/topics.dart';
import 'package:flutter_learno/widgets/progress.dart';

// ignore: must_be_immutable
class ModuleList extends StatefulWidget {
  String subjectId;
  String subjectName;

  ModuleList(this.subjectId, this.subjectName);

  @override
  _ModuleListState createState() => _ModuleListState();
}

class _ModuleListState extends State<ModuleList> {
  bool isLoading = false;
  List<Map<String, dynamic>> _moduleList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getModuleList();
  }

  Future<void> getModuleList() async {
    Stream<QuerySnapshot> modules = FirebaseFirestore.instance
        .collection("app_settings")
        .doc('modules')
        .collection("moduleList")
        .snapshots();
    _moduleList.clear();
    modules.forEach((field) {
      field.docs.asMap().forEach((index, data) {
        if (field.docs[index]['subjectId'] == widget.subjectId) {
          _moduleList.add({
            'name': field.docs[index]['name'],
            'id': field.docs[index]['id'],
            'subjectId': field.docs[index]['subjectId'],
            'mediaUrl': field.docs[index]['mediaUrl']
          });
          print(_moduleList);
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
              title: Text("Modules - ${widget.subjectName}",
                  style: TextStyle(color: Color(0xff615DFA))),
            ),
            body: _moduleList.isEmpty
                ? Container(
                    child: Center(
                      child: Text('No data found.'),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _moduleList.length,
                        gridDelegate:
                            new SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2),
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            width: MediaQuery.of(context).size.width / 2,
                            height: MediaQuery.of(context).size.width / 2,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: InkWell(
                                onTap: () {},
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => TopicScreen(
                                                  moduleId: _moduleList[index]
                                                      ['id'], moduleName: _moduleList[index]
                                            ['name'], mediaUrl: _moduleList[index]
                                            ['mediaUrl'],
                                                )));
                                  },
                                  child: Card(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        ClipRRect(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10)),
                                          child: Image(
                                            image: NetworkImage(
                                                _moduleList[index]['mediaUrl']),
                                            fit: BoxFit.cover,
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2 -
                                                70,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                40,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                              '${_moduleList[index]['name']}'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
          );
  }
}
