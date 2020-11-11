
import 'dart:async';
import 'package:extra_task/addTask.dart';
import 'package:extra_task/task.dart';
import 'package:flutter/material.dart';

import 'main.dart';
import 'myFrame.dart';
import 'theme.dart';

class AcceptTasks extends StatefulWidget {

  AcceptTasks() {}

  @override
  State createState() => _AcceptTasksState();
}

class _AcceptTasksState extends State<AcceptTasks> {


  List<Task> tasks = [];
  Timer goHome;

  Future<dynamic> loadTasks({force : false}) async {

      var tasksToAdd = await firestore.doc('labs/tasksToAdd').get();
        tasks =
            (tasksToAdd['tasks'].map((e) =>
                Task.fromFirestoreDoc(e, editable: true)).toList()).cast<Task>();
        return tasks.map((e) => InkWell(
          child: e,
          onTap: () {
            Route route = MaterialPageRoute(builder: (context) => AddTask(task: e, force: true));
            Navigator.push(context, route);
          },
        )).toList();
  }


  @override
  void dispose() {
    if (goHome != null)
      goHome.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (goHome != null)
      goHome.cancel();

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
                        Route route = MaterialPageRoute(builder: (context) => AddTask());
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
                if (snapshot.hasError) {
                  print(snapshot.error);
                  if (goHome != null)
                    goHome.cancel();
                  goHome = Timer(Duration(seconds: 5),() {
                    if (ModalRoute.of(context).isCurrent) {
                      Navigator.pop(context);
                    } } );
                  return Center(
                      child: Text('Тебе сюда нельзя', style: Theme.of(context).textTheme.headline2.copyWith(color: Colors.white.withOpacity(0.8)),)
                  );
                }
                if (snapshot.hasData) {
                  if (snapshot.data.isEmpty) {
                    return Center(
                        child: Text('На сходку никто не пришел', style: Theme.of(context).textTheme.headline2.copyWith(color: Colors.white.withOpacity(0.8)),)
                    );
                  }
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