import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

const BACK_COLOR = Colors.lightBlue;

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Extra task',
      theme: ThemeData(
        primarySwatch: BACK_COLOR,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var LABS = [
    Laba(1, 1, '''Массив, удаление сдвигом'''),
    Laba(1, 2, '''Досрочный выход из цикла, целые числа'''),
    Laba(2, 3, '''Использование процедур и функций'''),
    Laba(2, 4, '''Обработка символьных строк'''),
    Laba(2, 5, '''Файлы, множества, записи'''),
  ];

  var laba;
  Task task;
  bool showAll = false;

  Future<Task> getTask({int num}) async {
    //Ради этого придется проект на хероку создавать, да ну нафиг
    /*    var a = fb.storage().refFromURL('gs://extra-task.appspot.com');
    print(a.child('lab1/lab1/txt'));

*/ /*    a.child('lab1/lab1.txt').getDownloadURL().then((value) {
      print(value.toString());
      http.get(value).then((value) {
        print(value.statusCode);
        task = Task();
        setState(() {});
        print(value.body);});
    });*/
    var f = await rootBundle.loadString('assets/laba$laba.txt');
    var a = json.decode(f) as List<dynamic>;
    if (a.isEmpty)
      return null;
    if (num == null || num < 0 || num >= a.length) {
      num = Random().nextInt(a.length);
    }
    return Task.fromJson(a[num] as Map<String, dynamic>);
  }

  loadLabQuans() async {

    for (var lab in LABS) {
      var f = await rootBundle.loadString('assets/laba${lab.num}.txt');
      var a = json.decode(f) as List<dynamic>;
      lab.taskQuan = a.length;
    }
    setState(() {});
  }

  @override
  void initState() {
    loadLabQuans();
    super.initState();
  }

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
  }

  Widget taskWrapper(Task task) {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.all(Radius.circular(16)),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showAll = false;
                        laba = null;
                        task = null;
                      });
                    },
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.lightBlue,
                      size: 50,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0),
                    child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                            child: Text(
                              task.name ?? ' ',
                              style:
                              TextStyle(fontSize: 24),
                              overflow: TextOverflow.clip,
                            ))),
                  )
                ],
              ),
              showAll ? Container() : GestureDetector(onTap: () {
                setState(() {
                  showAll = true;
                });
              }, child: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Icon(Icons.format_list_bulleted_rounded, color: BACK_COLOR, size: 50),
              ))
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
                        task == null ||
                            task.text.isEmpty
                            ? ' '
                            : task.text,
                        style:
                        TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var s = MediaQuery.of(context).size;
    var cellW = 0.0;
    var cellH = 0.0;
    var scroll = false;

    return Scaffold(
        body: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(left: 12, right: 12, top: 16, bottom: 0),
            color: BACK_COLOR,
            child: Column(mainAxisSize: MainAxisSize.max, children: [
              Flexible(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: laba == null
                      ? LayoutBuilder(
                          builder: (context, constraints) {
                            var wrapSpacing = 8.0;
                            var wrapRunSpacing = 8.0;
                            if (s.aspectRatio < 0.9 || s.width < 250) {
                              cellW = s.width * 0.8;
                              cellH = cellW * 1 / 3;
                              scroll = true;
                            } else {
                              var w = constraints.maxWidth;
                              var h = constraints.maxHeight;
                              var columns = max(w / h, w / 250).round();
                              var rows = LABS.length ~/ columns +
                                  (LABS.length % columns > 0 ? 1 : 0);
                              cellW = min((w - wrapSpacing * columns) / columns,
                                  (h - wrapRunSpacing * rows) / rows);
                              cellH = cellW;
                            }

                            var wp = Wrap(
                              clipBehavior: Clip.none,
                              alignment: WrapAlignment.start,
                              spacing: wrapSpacing,
                              runSpacing: wrapRunSpacing,
                              children: LABS
                                  .map((e) => InkWell(
                                        onTap: () {
                                          laba = e.num;
                                          setState(() {});
                                          getTask().then((value) {
                                            if (value == null) {
                                              laba = null;
                                            } else {
                                              task = value;
                                            }
                                            setState(() {});
                                          });
                                        },
                                        child: Material(
                                          elevation: 10,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                          child: Container(
                                            height: cellH,
                                            width: cellW,
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
                                                          e.num.toString(),
                                                          style: TextStyle(
                                                              fontSize: 200,
                                                              color:
                                                                  BACK_COLOR),
                                                        ))),
                                                Flexible(
                                                    flex: 10 + (scroll ? 5 : 0),
                                                    child: Container(
                                                      alignment: Alignment.topCenter,
                                                        child: FittedBox(
                                                            fit: BoxFit.fitWidth,
                                                            child: Text(
                                                              taskStr(e.taskQuan),
                                                              style: TextStyle(
                                                                  fontSize: 200,
                                                                  color: BACK_COLOR
                                                              ),
                                                            )))),
                                                Flexible(
                                                    flex: 20,
                                                    child: Container(
                                                        child: FittedBox(
                                                        fit: BoxFit.fitHeight,
                                                        child: Text(
                                                          e.name,
                                                          style: TextStyle(
                                                              fontSize: 200,
                                                              color: BACK_COLOR
                                                          ),
                                                        ))))
                                              ],
                                            ),
                                            padding: EdgeInsets.all(8),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            );

                            return Stack(
                              children: [
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: SelectableText('Задачи сюда: dipodbolotov@edu.hse.ru', style: TextStyle(color: Colors.white),),
                                ),
                                scroll
                                    ? SingleChildScrollView(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: wp,
                                        ),
                                      )
                                    : wp,
                              ],
                            );
                          },
                        )
                      : Container(
                      width: s.width > 750 && s.aspectRatio > 1.4
                          ? s.width * 3 / 5: s.width,
                      child: showAll ?
                  ListView.builder(itemBuilder: (context, index) {
                    return FutureBuilder(
                        future: getTask(num: index),
                        builder: (context, snapshot) => snapshot.hasData ? Padding(
                          padding: const EdgeInsets.only(top: 16.0, left: 12, right: 12),
                          child: taskWrapper(snapshot.data),
                        ) : Container());
                  }, itemCount: LABS[laba].taskQuan,)
                      :
                  Container(
                    child: task == null
                        ? Container(
                      alignment: Alignment.center,
                          child:
                            SizedBox(
                              width: s.shortestSide/5,
                              height: s.shortestSide/5,
                              child: CircularProgressIndicator(
                                  backgroundColor: Colors.transparent,
                                  strokeWidth: 8,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      BACK_COLOR),
                                ),
                            ),
                        )
                        :
                        taskWrapper(task),
                  )),
                ),
              )
            ])));
  }
}

class Laba {
  final int module;
  final int num;
  final String name;
  int taskQuan = 0;

  Laba(this.module, this.num, this.name, {this.taskQuan});
}

class Task {
  String name = '';
  String text = '';
  Map<String, String> tests;
  Image image;

  Task({this.name, this.text, this.tests});

  Task.fromJson(dynamic a) {
    this.name = a['name'];
    if (name != null && name.isEmpty) name = null;
    this.text = proceed(a['text']);
    this.tests = ((a['test'] ?? {'': ''}) as Map).cast<String, String>();
  }

  String proceed(var str) {
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
}
