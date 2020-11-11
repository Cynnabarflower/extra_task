
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extra_task/addTask.dart';
import 'package:extra_task/task.dart';
import 'package:flutter/material.dart';

import 'main.dart';
import 'myFrame.dart';
import 'theme.dart';

class Laba extends StatefulWidget {
  String path;
  int num = 0;
  String name = 'name';
  List<Task> tasks = [];

  Laba(this.path, {this.num, this.name}) {}

  String taskStr(int task) {
    if (task == null || task == 0)
      return '-';
    if (task >= 5 && task <= 20)
      return '$task задач';
    if (task % 10 == 1)
      return '$task задача';
    if (task % 10 <= 4)
      return '$task задачи';
    if (task % 10 == 0 || task % 10 >= 5)
      return '$task задач';
    return '$task';
  }


  Widget button(context, {mobile = false}) {
    return InkWell(
      onTap: () async {
        Navigator.of(context).pushNamed('${path}');
      },
      child: Container(
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.all(
              Radius.circular(8)),
          child: AspectRatio(
            aspectRatio: mobile ? 3 : 1,
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
              children: [
                Flexible(
                    flex: 70,
                    child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          num.toString(),
                          style: TextStyle(
                              fontSize: 200),
                        ))),
                Flexible(
                    flex: 10,
                    child: Container(
                        alignment: Alignment.topCenter,
                        child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              taskStr(0),
                              style: TextStyle(
                                  fontSize: 200,

                              ),
                            )))),
                Flexible(
                    flex: 20,
                    child: Container(
                        child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: Text(
                              '$name',
                              style: TextStyle(
                                  fontSize: 200,

                              ),
                            ))))
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  State createState() => _LabaState();
}

class _LabaState extends State<Laba> {

  Future<List<dynamic>> loadTasks({force : false}) async {

    if (!force && widget.tasks.isNotEmpty) {
      return widget.tasks;
    }
    print('loading ${widget.path} from firebase...');
    var lab = (await firestore.doc('labs/'+widget.path).get()).data();
    widget.tasks = (lab['tasks'].map((e) => Task.fromFirestoreDoc(e)).toList()).cast<Task>();
    return widget.tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Wrap(
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_rounded),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.shuffle_rounded),
                      onPressed: () {
                        widget.tasks.shuffle();
                        setState(() {});
                      },
                    ),
                    IconButton(
                      icon: lightTheme
                          ? Icon(Icons.nightlight_round)
                          : Icon(
                        Icons.wb_sunny,
                      ),
                      onPressed: () => setState((){applyTheme(Theme.of(context).brightness != Brightness.light);}),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        Route route = MaterialPageRoute(builder: (context) => AddTask(task: (Task()..lab = widget.path)));
                        Navigator.push(context, route);
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
          MyFrame(
            color: Theme.of(context).backgroundColor,
            child: FutureBuilder(
              future: loadTasks(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView( shrinkWrap: true, children: (snapshot.data as List<Widget>));
                } else if (snapshot.hasError) {
                  print(snapshot.error);
                }
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.transparent,
                    strokeWidth: 5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}