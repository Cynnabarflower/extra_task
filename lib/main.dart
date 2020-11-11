import 'dart:math';
import 'package:extra_task/task.dart';
import 'package:extra_task/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'addTask.dart';
import 'laba.dart';
import 'myFrame.dart';
import 'notFound.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void main() async {
  setUrlStrategy(PathUrlStrategy());
  await Firebase.initializeApp();
  firestore = FirebaseFirestore.instance;
  auth = FirebaseAuth.instance;
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

FirebaseFirestore firestore;
FirebaseAuth auth;

bool lightTheme = true;

String signInEmail = '';
User user;
List<Laba> labs = [];

class MyApp extends StatelessWidget {
  MyApp() {
    loadLabNames();
  }

  @override
  Widget build(BuildContext context) {
    print('MyAppp build');
    return StreamBuilder<AppTheme>(
        initialData: AppTheme.LIGHT_THEME,
        stream: bloc.themeData,
        builder: (context, AsyncSnapshot<AppTheme> snapshot) {
          return MaterialApp(
            title: 'Extra task',
            theme: snapshot.data.themeData,
            initialRoute: '/',
            onGenerateRoute: (settings) {
              if (settings.name == '/') {
                return MaterialPageRoute(
                    builder: (context) => MyHomePage(),
                    settings: RouteSettings(name: ''));
              }

              if (settings.name.endsWith('addTask')) {
                return MaterialPageRoute(
                    builder: (context) => AddTask(),
                    settings: RouteSettings(name: 'addTask'));
              }

              var uri = Uri.parse(settings.name);
              if (uri.pathSegments.length == 1 &&
                  uri.pathSegments.last.startsWith('lab')) {
                print(uri.pathSegments.last);
                var lab = labs.firstWhere(
                    (element) => element.path == uri.pathSegments.last,
                    orElse: () => null);
                if (lab == null) {
                  return MaterialPageRoute(
                      builder: (context) => Laba(uri.pathSegments.last),
                      settings:
                          RouteSettings(name: '/${uri.pathSegments.last}'));
                } else
                  return MaterialPageRoute(
                      builder: (context) => lab,
                      settings: RouteSettings(name: '/${lab.path}'));
              }

              return MaterialPageRoute(
                  builder: (context) => NotFound(),
                  settings: RouteSettings(name: '/404'));
            },
          );
        });
  }

  Future<void> loadLabNames() async {
    print('loading lab names...');
    labs.clear();
    var labNames = (await firestore.doc('labs/names').get());
    for (var lab in labNames['names'].entries)
      labs.add(Laba(lab.key, num: 0, name: lab.value));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var laba;
  Task task;
  bool showAll = false;

  Future<Task> getTask(int lab, {int num}) async {
    if (num != null) {
      var f = await firestore.doc('labs/lab$lab/tasks/task$num').get();
      if (f.exists) {
        return Task.fromFirestoreDoc(f);
      }
    } else {
      var tasks = await firestore.collection('labs/lab$lab/tasks').get();
      if (tasks.size > 0) {
        var n = Random().nextInt(tasks.size);
        return await getTask(lab, num: n);
      }
    }
    return null;
  }

  Future<List<Task>> getTasks(int lab) async {
    var tasks = List<Task>();
    var taskDocs =
        (await firestore.collection('labs/lab$lab/tasks').get()).docs;
    taskDocs.forEach((element) {
      tasks.add(Task.fromFirestoreDoc(element));
    });
    return tasks;
  }

  login() async {}

  @override
  void initState() {
    super.initState();
    applyTheme(true);
  }

  String taskStr(int task) {
    if (task == null || task == 0) return '-';
    if (task >= 5 && task <= 20) return '$task задач';
    if (task % 10 == 1) return '$task задача';
    if (task % 10 <= 4) return '$task задачи';
    if (task % 10 == 0 || task % 10 >= 5) return '$task задач';
  }

  GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var s = MediaQuery.of(context).size;

    return Scaffold(
        body: Wrap(
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(8)),
                  ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Visibility(
                    visible: false,
                    child: IconButton(
                      icon:
                          user == null ? Icon(Icons.login) : Icon(Icons.logout),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Stack(
                                  children: <Widget>[
                                    Form(
                                      key: _formKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: TextFormField(
                                                controller: _emailController,
                                                decoration:
                                                    const InputDecoration(
                                                  icon: Icon(Icons.mail),
                                                  labelText: 'Email',
                                                ),
                                                autovalidateMode:
                                                    AutovalidateMode.disabled,
                                                validator: (value) => (!value
                                                            .endsWith(
                                                                '@edu.hse.ru') &&
                                                        value.contains('@'))
                                                    ? 'Используйте почту @edu.hse.ru'
                                                    : null),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: RaisedButton(
                                              child: Text("Login"),
                                              onPressed: () async {
                                                var emailLink =
                                                    'http://localhost:63288/#/';
                                                /*         if (_formKey.currentState
                                                              .validate()) {
                                                            var users = await firestore.collection('users').where('email', isEqualTo: _emailController.text).get();
                                                            if (users.size == 1) {
                                                              signInEmail = _emailController.text;
                                                              await FirebaseAuth.instance.sendSignInLinkToEmail(email: _emailController.text, actionCodeSettings: ActionCodeSettings(url: emailLink, handleCodeInApp: true));
                                                              if (FirebaseAuth.instance.isSignInWithEmailLink(emailLink)) {
                                                                FirebaseAuth.instance.signInWithEmailLink(email: signInEmail, emailLink: emailLink).then((value) {
                                                                  user = value.user;
                                                                  setState(() {
                                                                  });
                                                                });
                                                              }
                                                            }
                                                          }*/
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                                'Если ваша почта есть в списке, туда придет письмо с ссылкой для авторизации.'),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            });
                      },
                    ),
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
                      Navigator.of(context).pushNamed('addTask');
                    },
                  ),
                ],
              ),
            ),
            MyFrame(
              color: Theme.of(context).backgroundColor,
              child: Container(
                  alignment: Alignment.center,
                  child: Column(mainAxisSize: MainAxisSize.max, children: [
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.bottomRight,
                              child: SelectableText(
                                'Задачи сюда: dipodbolotov@edu.hse.ru',
                              ),
                            ),
                            Container(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return FutureBuilder(
                                    future: () async {
                                      while (labs.isEmpty) {
                                        await Future.delayed(
                                            Duration(milliseconds: 500));
                                      }
                                      return true;
                                    }(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return SingleChildScrollView(
                                          child: Wrap(
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            alignment:
                                                WrapAlignment.spaceAround,
                                            runSpacing:
                                                constraints.maxWidth / 40,
                                            spacing: constraints.maxWidth / 40,
                                            key: GlobalKey(),
                                            children: labs.map((e) {
                                              return Container(
                                                width: s.aspectRatio < 0.8
                                                    ? constraints.maxWidth
                                                    : constraints.maxWidth / 4,
                                                child: e.button(context,
                                                    mobile:
                                                        s.aspectRatio < 0.8),
                                              );
                                            }).toList(),
                                          ),
                                        );
                                      } else if (snapshot.hasError) {
                                        print(snapshot.error);
                                      }
                                      return Align(
                                        alignment: Alignment.center,
                                        child: CircularProgressIndicator(
                                          backgroundColor: Colors.transparent,
                                          strokeWidth: 5,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            )
                          ],
                        ))
                  ])),
            ),
          ],
        ));
  }
}
