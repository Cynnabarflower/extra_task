import 'dart:math';
import 'package:extra_task/task.dart';
import 'package:extra_task/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'acceptTasks.dart';
import 'addTask.dart';
import 'laba.dart';
import 'myFrame.dart';
import 'notFound.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void main() async {
  setUrlStrategy(PathUrlStrategy());
  await Firebase.initializeApp();
  firestore = FirebaseFirestore.instance;
  // auth = FirebaseAuth.instance;
  _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

FirebaseFirestore firestore;
// FirebaseAuth auth;
GoogleSignIn _googleSignIn;

bool lightTheme = true;

String signInEmail = '';
GoogleSignInAccount user;
List<Laba> labs = [];

class MyApp extends StatelessWidget {
  MyApp() {
    loadLabNames();
  }

  @override
  Widget build(BuildContext context) {
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
              if (settings.name.endsWith('acceptTasks')) {
                return MaterialPageRoute(
                    builder: (context) => AcceptTasks(),
                    settings: RouteSettings(name: 'acceptTasks'));
              }

              var uri = Uri.parse(settings.name);
              if (uri.pathSegments.length == 1 &&
                  uri.pathSegments.last.startsWith('lab')) {
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
    labs.clear();
    var labNames = (await firestore.doc('labs/names').get());
    for (var lab in labNames['names'].entries)
      labs.add(Laba(lab.key, name: lab.value));
    labs.sort((a, b) => a.num > b.num ? 1 : -1);
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
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FutureBuilder(
                future: () async {
                  if (FirebaseAuth.instance.currentUser == null || FirebaseAuth.instance.currentUser.isAnonymous)
                    return false;
                  var e = await FirebaseFirestore.instance.doc('users/${FirebaseAuth.instance.currentUser.uid}').get();
                  return e.exists;
                }(),
                builder: (context, snapshot) {
                  return Visibility(visible: snapshot.hasData && snapshot.data, child: IconButton(
                    icon: Icon(Icons.mail),
                    onPressed: () => setState(() {
                      Navigator.pushNamed(context, 'acceptTasks');
                    }),
                  ),);
                },
              ),
              IconButton(
                icon: FirebaseAuth.instance.currentUser == null ? Icon(Icons.login) : Icon(Icons.logout),
                onPressed: () async {
                  if (FirebaseAuth.instance.currentUser == null) {
                    await Firebase.initializeApp();

                    final GoogleSignInAccount googleSignInAccount =
                        await _googleSignIn.signIn();
                    final GoogleSignInAuthentication
                        googleSignInAuthentication =
                        await googleSignInAccount.authentication;

                    final AuthCredential credential =
                        GoogleAuthProvider.credential(
                      accessToken: googleSignInAuthentication.accessToken,
                      idToken: googleSignInAuthentication.idToken,
                    );

                    final UserCredential authResult = await FirebaseAuth
                        .instance
                        .signInWithCredential(credential);
                    final User user = authResult.user;

                    if (user != null) {
                      assert(!user.isAnonymous);
                      assert(await user.getIdToken() != null);

                      final User currentUser =
                          FirebaseAuth.instance.currentUser;
                      assert(user.uid == currentUser.uid);
                    }
                  } else {
                    _googleSignIn.signOut();
                    FirebaseAuth.instance.signOut();
                  }
                  setState(() {});
                },
              ),
              IconButton(
                icon: lightTheme
                    ? Icon(Icons.nightlight_round)
                    : Icon(
                        Icons.wb_sunny,
                      ),
                onPressed: () => setState(() {
                  applyTheme(Theme.of(context).brightness != Brightness.light);
                }),
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
              alignment: Alignment.topCenter,
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return FutureBuilder(
                        future: () async {
                          while (labs.isEmpty) {
                            await Future.delayed(Duration(milliseconds: 500));
                          }
                          return true;
                        }(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return SingleChildScrollView(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.start,
                                alignment: WrapAlignment.start,
                                runSpacing: constraints.maxWidth / 40,
                                spacing: constraints.maxWidth / 40,
                                key: GlobalKey(),
                                children: [
                                  ...labs.map((e) {
                                    return Container(
                                      width: s.aspectRatio < 0.8
                                          ? constraints.maxWidth
                                          : constraints.maxWidth / 4,
                                      child: e.button(context,
                                          mobile: s.aspectRatio < 0.8),
                                    );
                                  }).toList(),
                                  Container(
                                    height: constraints.maxWidth / 10,
                                  )
                                ],
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Column(
                              children: [
                                Text(
                                  'Что-то неработает',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline2
                                      .copyWith(
                                          color: Colors.white.withOpacity(0.8)),
                                ),
                                Text(
                                  snapshot.error,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .copyWith(
                                          color: Colors.white.withOpacity(0.6)),
                                ),
                              ],
                            ));
                          }
                          return Container(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.transparent,
                              strokeWidth: 5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          );
                        },
                      );
                    },
                  ))),
        ),
      ],
    ));
  }
}
