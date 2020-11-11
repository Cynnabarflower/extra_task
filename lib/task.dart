import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Task extends StatefulWidget {

  @override
  State createState() => _TaskState();

  String name = '';
  String text = '';
  Map<String, String> tests = Map();
  int difficulty = 3;
  String id;
  String lab = '';
  String mail = '';

  Task({this.id});

  Task.fromJson(dynamic a) {
    this.name = a['name'];
    if (name != null && name.isEmpty) name = null;
    this.text = (a['text']);
    this.tests = ((a['test'] ?? {'': ''}) as Map).cast<String, String>();
  }

  Task.fromFirestoreDoc(dynamic a, {editable : false}) {
    this.name = a['name'];
    this.text = (a['description']);
    this.difficulty = a['difficulty'];
    this.tests = ((a['tests'] ?? Map()) as Map).cast<String, String>();
    this.lab = a['lab'];
    this.mail = a['mail'];
  }

  Map<String, dynamic> toFirebaseDoc() {
    Map<String, dynamic> m = new Map();
    m['name'] = this.name;
    m['description'] = text;
    m['difficulty'] = difficulty;
    m['tests'] = tests;
    m['lab'] = lab;
    m['mail'] = mail;
    return m;
  }

  String process(var str) {
    //there should be a better way
    if (str == null) return '';
    var s = '';
    if (str is List)
      s = str.join();
    else
      s = str;
    int from = 0;
    int to = 0;
    while (s.contains(r"${", from)) {
      from = s.indexOf(r"${", from);
      to = s.indexOf(r'}', from);
      var pattern = s.substring(from + 2, to);
      if (pattern.contains('|')) {
        var vals = pattern.split('|')
          ..removeWhere((element) => element.isEmpty)
          ..shuffle();
        s = s.replaceRange(from, to + 1, vals[0]);
      }
    }
    return s;
  }

  void save() {
    this.id ??= this.hashCode.toString();
  }

}

class _TaskState extends State<Task> {

  @override
  Widget build(BuildContext context) {

    var s = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 12, right: 12),
      child: Material(
      elevation: 10,
      borderRadius: BorderRadius.all(Radius.circular(16)),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 8.0),
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                        child: Text(
                          widget.name ?? ' ',
                          style:
                          TextStyle(fontSize: 24),
                          overflow: TextOverflow.clip,
                        ))),
              )
            ],
          ),
          Container(
            alignment: Alignment.center,
            child: Container(
                padding: EdgeInsets.all(8),
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                       widget.text.isEmpty
                            ? ' '
                            : (widget.text),
                        style:
                        TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                )),
          ),
        ],
      ),
    )
    );
  }


}