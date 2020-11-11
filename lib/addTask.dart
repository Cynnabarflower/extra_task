import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extra_task/task.dart';
import 'package:extra_task/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'myFrame.dart';

class AddTask extends StatefulWidget {
  @override
  State createState() => _AddTaskState();

  Task task;
  bool force;
  Task orig;

  AddTask({Task task, this.force: false}) {
    orig = task == null ? null : Task.fromFirestoreDoc(task.toFirebaseDoc());
    this.task = task ?? Task();
    this.force = force ?? false;
  }
}

class _AddTaskState extends State<AddTask> with SingleTickerProviderStateMixin {
  int step = 0;
  int addingTaskStatus = 0;
  List<List<String>> tests = [];
  ScrollController listController = ScrollController();
  String lab;

  @override
  void initState() {
    lab = widget.task.lab;
    tests = [];
    widget.task.tests.forEach((key, value) {
      tests.add([key, value]);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var s = MediaQuery.of(context).size;

    return Scaffold(
        body: Wrap(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
          ),
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Theme.of(context).brightness == Brightness.light
                        ? Icon(Icons.nightlight_round)
                        : Icon(
                            Icons.wb_sunny,
                          ),
                    onPressed: () => setState(() {
                      applyTheme(
                          Theme.of(context).brightness != Brightness.light);
                    }),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        MyFrame(
          color: Theme.of(context).backgroundColor,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                var iconColor = Theme.of(context).iconTheme.color;
                return Wrap(
                  children: [
                    SizedBox(
                      height: constraints.maxHeight * 0.8,
                      child: [
                        Material(
                          elevation: 10,
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Wrap(
                              children: [
                                TextField(
                                  decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.all(8),
                                      hintText: 'Имя задачи'),
                                  onChanged: (value) {
                                    widget.task.name = value;
                                  },
                                  controller: TextEditingController()..text = widget.task.name,
                                  maxLines: 1,
                                  minLines: 1,
                                ),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: constraints.maxHeight * 0.7,
                                    minHeight: constraints.maxHeight * 0.7,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: SingleChildScrollView(
                                      child: TextField(
                                        decoration: InputDecoration(
                                            hintText: 'Текст задачи'),
                                        onChanged: (value) {
                                          widget.task.text = value;
                                        },
                                        controller: TextEditingController()..text = widget.task.text,
                                        maxLines: 30,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        ListView(
                          children: [
                            ...tests
                                .map((e) => Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Material(
                                      elevation: 10,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(16)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                              maxHeight:
                                                  constraints.maxHeight * 0.25,
                                              minHeight:
                                                  constraints.maxHeight * 0.25,
                                              maxWidth: constraints.maxWidth,
                                              minWidth: constraints.maxWidth),
                                          child: Row(
                                            children: [
                                              Container(
                                                width:
                                                    constraints.maxWidth * 0.5 -
                                                        3 -
                                                        8,
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: SingleChildScrollView(
                                                  child: TextField(
                                                    controller:
                                                        TextEditingController()
                                                          ..text = e[0],
                                                    decoration: InputDecoration(
                                                        hintText: 'Input'),
                                                    onChanged: (value) {
                                                      e[0] = value;
                                                    },
                                                    maxLines: 30,
                                                  ),
                                                ),
                                              ),
                                              VerticalDivider(
                                                  thickness: 3, width: 6),
                                              Container(
                                                width:
                                                    constraints.maxWidth * 0.5 -
                                                        3 -
                                                        8,
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: SingleChildScrollView(
                                                  child: TextField(
                                                    controller:
                                                        TextEditingController()
                                                          ..text = e[1],
                                                    decoration: InputDecoration(
                                                      hintText: 'Output',
                                                    ),
                                                    onChanged: (value) {
                                                      e[1] = value;
                                                    },
                                                    maxLines: 30,
                                                  ),
                                                ),
                                              )
                                            ],
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.max,
                                          ),
                                        ),
                                      ),
                                    )))
                                .toList(),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: InkWell(
                                child: Container(
                                  height: constraints.maxHeight * 0.2,
                                  child: Column(
                                    children: [
                                      Flexible(
                                        child: FittedBox(
                                          child: Text(
                                            'Добавить тест',
                                            style: Theme.of(context)
                                                .textTheme
                                                .apply(
                                                    displayColor: Colors.white
                                                        .withOpacity(0.8))
                                                .headline2,
                                          ),
                                          fit: BoxFit.scaleDown,
                                        ),
                                      ),
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Icon(
                                            Icons.add_circle_outline_outlined,
                                            color:
                                                Colors.white.withOpacity(0.8),
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                      border: Border.all(
                                          color: Colors.white.withOpacity(0.8),
                                          width: 6)),
                                ),
                                onTap: () {
                                  tests.add(['', '']);
                                  listController.animateTo(
                                      tests.length *
                                          constraints.maxHeight *
                                          0.25,
                                      duration: Duration(milliseconds: 500),
                                      curve: Curves.bounceInOut);
                                  setState(() {});
                                },
                              ),
                            )
                          ],
                          controller: listController,
                        ),
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            Material(
                              elevation: 10,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: constraints.maxHeight * 0.6,
                                    minHeight: constraints.maxHeight * 0.6,
                                  ),
                                  child: Wrap(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                              padding: const EdgeInsets.all(8),
                                              child: Text('Сложность:',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .apply(
                                                          bodyColor:
                                                              Theme.of(context)
                                                                  .hintColor)
                                                      .subtitle1)),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.star,
                                                    color: iconColor.withOpacity(
                                                        widget.task.difficulty >=
                                                                1
                                                            ? 1
                                                            : 0.5)),
                                                onPressed: () => setState(() {
                                                  widget.task.difficulty = 1;
                                                }),
                                                hoverColor: Colors.transparent,
                                                splashColor: Colors.transparent,
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.star,
                                                    color: iconColor.withOpacity(
                                                        widget.task.difficulty >=
                                                                2
                                                            ? 1
                                                            : 0.5)),
                                                onPressed: () => setState(() {
                                                  widget.task.difficulty = 2;
                                                }),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.star,
                                                    color: iconColor.withOpacity(
                                                        widget.task.difficulty >=
                                                                3
                                                            ? 1
                                                            : 0.5)),
                                                onPressed: () => setState(() {
                                                  widget.task.difficulty = 3;
                                                }),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.star,
                                                    color: iconColor.withOpacity(
                                                        widget.task.difficulty >=
                                                                4
                                                            ? 1
                                                            : 0.5)),
                                                onPressed: () => setState(() {
                                                  widget.task.difficulty = 4;
                                                }),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.star,
                                                    color: iconColor.withOpacity(
                                                        widget.task.difficulty >=
                                                                5
                                                            ? 1
                                                            : 0.5)),
                                                onPressed: () => setState(() {
                                                  widget.task.difficulty = 5;
                                                }),
                                              )
                                            ],
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.max,
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                              padding: const EdgeInsets.all(8),
                                              child: Text('Номер лабы:',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .apply(
                                                          bodyColor:
                                                              Theme.of(context)
                                                                  .hintColor)
                                                      .subtitle1)),
                                          LimitedBox(
                                            child: TextField(
                                              controller:
                                                  TextEditingController()
                                                    ..text = widget.task.lab,
                                              onChanged: (value) {
                                                if (value != null) {
                                                  lab = value;
                                                }
                                                lab = '';
                                              },
                                              decoration: InputDecoration(
                                                counterText: "",
                                              ),
                                              maxLength: 10,
                                            ),
                                            maxWidth: 50,
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxHeight:
                                                constraints.maxHeight * 0.5,
                                          ),
                                          child: SingleChildScrollView(
                                            child: TextField(
                                              decoration: InputDecoration(
                                                  hintText:
                                                  'Комментарий\nТут можно оставить имя, почту для связи, способ решения'),
                                              onChanged: (value) {
                                                widget.task.mail = value;
                                              },
                                              controller: TextEditingController()..text = widget.task.mail,
                                              maxLines: 50,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: constraints.maxHeight * 0.2,
                              alignment: Alignment.center,
                              child: Wrap(
                                children: [
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight: constraints.maxHeight * 0.2,
                                      minHeight: constraints.maxHeight * 0.2,
                                      maxWidth: constraints.maxWidth * (widget.force && addingTaskStatus == 0 ? 0.5 : 1.0),
                                      minWidth: constraints.maxWidth * (widget.force && addingTaskStatus == 0 ? 0.5 : 1.0),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        if (widget.task.name.trim().isEmpty ||
                                            widget.task.text.trim().isEmpty) {
                                          step = 0;
                                          setState(() {});
                                        }
                                        widget.task.lab = lab;
                                        addingTaskStatus = 1;
                                        setState(() {});
                                        tests.forEach((element) {
                                          widget.task.tests[element[0]] = element[1];
                                        });
                                        tests.clear();
                                        var ttt = FirebaseFirestore.instance
                                            .collection('labs')
                                            .doc('tasksToAdd');
                                        ttt.update({
                                          'tasks': FieldValue.arrayUnion([
                                            widget.task.toFirebaseDoc()
                                              ..['mail'] = widget.task.mail,
                                          ])
                                        }).then((value) {
                                          addingTaskStatus = 2;
                                          Future.delayed(Duration(seconds: 1), () {
                                            widget.task = Task();
                                            addingTaskStatus = 0;
                                            step = 0;
                                            setState(() {});
                                          });
                                          setState(() {});
                                        }, onError: () {
                                          addingTaskStatus = 3;
                                          Future.delayed(
                                              Duration(seconds: 1),
                                              () => setState(() {
                                                    addingTaskStatus = 0;
                                                    step = 0;
                                                  }));
                                          setState(() {});
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.all(Radius.circular(8)),
                                            border: Border.all(
                                                color: Colors.white.withOpacity(0.8),
                                                width: 6)),
                                        margin: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Flexible(
                                              child: FittedBox(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(
                                                      [
                                                        'Загрузить задачу',
                                                        'Загрузка...',
                                                        'Готово',
                                                        'Ошибка'
                                                      ][addingTaskStatus],
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .apply(
                                                              displayColor: Colors.white
                                                                  .withOpacity(0.8))
                                                          .headline2),
                                                ),
                                                fit: BoxFit.scaleDown,
                                              ),
                                            ),
                                            Flexible(
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Icon(
                                                  Icons.done_rounded,
                                                  color:
                                                      Colors.white.withOpacity(0.8),
                                                  size: 40,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: widget.force && addingTaskStatus == 0,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight: constraints.maxHeight * 0.2,
                                        minHeight: constraints.maxHeight * 0.2,
                                        maxWidth: constraints.maxWidth * 0.5,
                                        minWidth: constraints.maxWidth * 0.5,
                                      ),
                                      child: InkWell(
                                        onTap: () async {
                                          if (widget.task.name.trim().isEmpty ||
                                              widget.task.text.trim().isEmpty) {
                                            step = 0;
                                            setState(() {});
                                          }
                                          widget.task.lab = lab;
                                          addingTaskStatus = 1;
                                          setState(() {});
                                          tests.forEach((element) {
                                            widget.task.tests[element[0]] = element[1];
                                          });
                                          tests.clear();
                                          var laba = FirebaseFirestore.instance.doc('labs/$lab');
                                          laba.update({
                                            'tasks': FieldValue.arrayUnion([
                                              widget.task.toFirebaseDoc()
                                            ])
                                          }).then((value) {
                                            addingTaskStatus = 2;
                                            FirebaseFirestore.instance.doc('labs/tasksToAdd').update({
                                              'tasks' : FieldValue.arrayRemove([widget.orig.toFirebaseDoc()])
                                            }).catchError((e){
                                              print(e);
                                            });
                                            Future.delayed(Duration(seconds: 1), () {
                                              widget.task = Task();
                                              addingTaskStatus = 0;
                                              step = 0;
                                              setState(() {});
                                            });
                                            setState(() {});
                                          }, onError: (e) {
                                            print(e);
                                            addingTaskStatus = 3;
                                            Future.delayed(
                                                Duration(seconds: 1),
                                                    () => setState(() {
                                                  addingTaskStatus = 0;
                                                  step = 0;
                                                }));
                                            setState(() {});
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.all(Radius.circular(8)),
                                              border: Border.all(
                                                  color: Colors.white.withOpacity(0.8),
                                                  width: 6)),
                                          margin: const EdgeInsets.all(8.0),
                                          child: FittedBox(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                  'Добавить сразу',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .apply(
                                                      displayColor: Colors.white
                                                          .withOpacity(0.8))
                                                      .headline2),
                                            ),
                                            fit: BoxFit.scaleDown,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        )
                      ][step],
                    ),
                    SizedBox(
                        height: constraints.maxHeight * 0.2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  step = max(0, step - 1);
                                });
                              },
                              icon: Icon(Icons.arrow_back_rounded,
                                  color: Colors.white),
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                      onPressed: () => setState(() {
                                            step = 0;
                                          }),
                                      icon: Icon(Icons.circle,
                                          color: step == 0
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.7))),
                                  IconButton(
                                      onPressed: () => setState(() {
                                            step = 1;
                                          }),
                                      icon: Icon(
                                        Icons.circle,
                                        color: step == 1
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.7),
                                      )),
                                  IconButton(
                                      onPressed: () => setState(() {
                                            step = 2;
                                          }),
                                      icon: Icon(
                                        Icons.circle,
                                        color: step == 2
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.7),
                                      ))
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  step = min(2, step + 1);
                                });
                              },
                              icon: Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ))
                  ],
                );
              },
            ),
          ),
        ),
      ],
    ));
  }
}
