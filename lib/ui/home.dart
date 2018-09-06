import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';

class ElapsedTime {
  final int hundreds;
  final int seconds;
  final int minutes;

  ElapsedTime({
    this.hundreds,
    this.seconds,
    this.minutes,
  });
}

class Dependencies {
  final List<ValueChanged<ElapsedTime>> timerListeners =
      <ValueChanged<ElapsedTime>>[];
  final TextStyle textStyle = const TextStyle(
      fontSize: 55.0, color: Colors.white, fontWeight: FontWeight.w800);
  final Stopwatch stopwatch = new Stopwatch();
  final int timerMillisecondsRefreshRate = 30;
}

class Home extends StatefulWidget {
  @override
  HomeState createState() => new HomeState();
}

class HomeState extends State<Home> {
  List<String> itemsList = [];
  String listItem;
  int _currentIndex = 0;

  final Dependencies dependencies = new Dependencies();

  void stopWatchButtonPressed() {
    if (dependencies.stopwatch.elapsedMilliseconds > 0) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: new Text("End Game?"),
              content: new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[
                    new RaisedButton(
                        child: new Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                    new Padding(padding: EdgeInsets.all(10.0)),
                    new RaisedButton(
                        child: new Text("Yes"),
                        onPressed: () {
                          setState(() {
                            var currentDateTime = new DateTime.now();
                            var dateFormat =
                                new DateFormat('yyyy-MM-dd HH:mm:ss');
                            String formattedCurrentDate =
                                dateFormat.format(currentDateTime);
                            String timeElapsed =
                                dependencies.stopwatch.elapsed.toString();
                            timeElapsed = timeElapsed.substring(0, 7);
                            dependencies.stopwatch.stop();
                            dependencies.stopwatch.reset();
                            listItem =
                                "$timeElapsed\n Game Over at: $formattedCurrentDate";
                            writeData(listItem);
                            itemsList.add(listItem);
                          });
                          Navigator.of(context).pop();
                        })
                  ],
                ),
              ),
            );
          });
    } else {
      var teamController = TextEditingController();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: new Text("Team (VS) Team"),
              content: new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[
                    new TextField(controller: teamController),
                    new Padding(padding: new EdgeInsets.all(10.0)),
                    new RaisedButton(
                        child: new Text("Start"),
                        onPressed: () {
                          String teamsPlaying = teamController.text;
                          setState(() {
                            dependencies.stopwatch.reset();
                            dependencies.stopwatch.start();
                          });
                          var currentDateTime = new DateTime.now();
                          var dateFormat =
                              new DateFormat('yyyy-MM-dd HH:mm:ss');
                          String formattedCurrentDate =
                              dateFormat.format(currentDateTime);
                          listItem =
                              '$teamsPlaying\n Game started at: $formattedCurrentDate';
                          writeData(listItem);
                          itemsList.add(listItem);
                          Navigator.of(context).pop();
                        })
                  ],
                ),
              ),
            );
          });
    }
  }

  void pauseStopWatchButtonPressed() {
    var currentDateTime = new DateTime.now();
    var dateFormat = new DateFormat('yyyy-MM-dd HH:mm:ss');
    String formattedCurrentDate = dateFormat.format(currentDateTime);
    setState(() {
      if (dependencies.stopwatch.isRunning) {
        dependencies.stopwatch.stop();
        String timeElapsed = dependencies.stopwatch.elapsed.toString();
        timeElapsed = timeElapsed.substring(0, 7);
        listItem = '$timeElapsed\nGame paused at: $formattedCurrentDate';
      } else {
        dependencies.stopwatch.start();
        listItem = 'Game resumed at: $formattedCurrentDate';
      }
    });
    writeData(listItem);
    itemsList.add(listItem);
  }

  Widget buildTimerActionButton(VoidCallback callback) {
    return new IconButton(
        icon: new Icon(Icons.access_alarms), onPressed: callback);
  }

  Widget buildPauseActionButton(VoidCallback callback) {
    return new IconButton(icon: new Icon(Icons.flag), onPressed: callback);
  }

  @override
  Widget build(BuildContext context) {
    readData();
    return new Scaffold(
      appBar: new AppBar(
          title: new Text('Rugby Score'),
          centerTitle: true,
          backgroundColor: Colors.green,
          leading: buildPauseActionButton(pauseStopWatchButtonPressed),
          actions: <Widget>[buildTimerActionButton(stopWatchButtonPressed)]),
      body: new Stack(
        children: <Widget>[
          new Center(
            child: new Image.asset(
              'images/splash.jpg',
              width: 490.0,
              height: 1200.0,
              fit: BoxFit.fitHeight,
            ),
          ),
          new Container(
            child: new Column(
              children: <Widget>[
                new Padding(padding: EdgeInsets.all(10.0)),
                new Row(
                  children: <Widget>[
                    new Padding(padding: EdgeInsets.only(left: 100.0)),
                    new FloatingActionButton(
                        child: Icon(Icons.share),
                        onPressed: () {
                          final RenderBox box = context.findRenderObject();
                          Share.share(itemsList.toString(),
                              sharePositionOrigin:
                                  box.localToGlobal(Offset.zero) & box.size);
                        }),
                    new Padding(padding: EdgeInsets.only(left: 25.0, right: 25.0)),
                    new FloatingActionButton(
                        backgroundColor: Colors.red,
                        child: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            itemsList.clear();
                          });
                        }),
                  ],
                ),
                new Padding(padding: new EdgeInsets.all(15.5)),
                new Center(
                    child: new TimerText(
                  dependencies: dependencies,
                )),
                new Padding(padding: EdgeInsets.all(10.0)),
                new Expanded(
                    child: new ListView.builder(
                        itemCount: itemsList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return new Card(
                            child: new Column(
                              children: <Widget>[
                                new ListTile(
                                    title: new Text(itemsList[index]),
                                    leading: new CircleAvatar(
                                      backgroundColor: Colors.blue,
                                      child: new Text(itemsList[index]
                                          .substring(2, 4)
                                          .toUpperCase()),
                                    ))
                              ],
                            ),
                          );
                        })),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: new BottomNavigationBar(
          onTap: onTabTapped,
          currentIndex: _currentIndex,
          items: [
            new BottomNavigationBarItem(
                icon: new Icon(Icons.add), title: new Text("2 Points")),
            new BottomNavigationBarItem(
                icon: new Icon(Icons.add_box), title: new Text("3 Points")),
            new BottomNavigationBarItem(
                icon: new Icon(Icons.add_circle_outline),
                title: new Text("5 Points"))
          ]),
    );
  }

  void onTabTapped(int index) {
    var inputController = new TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: new Text("Scored By Player"),
              content: new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[
                    new TextField(
                        controller: inputController,
                        keyboardType: TextInputType.number),
                    new Padding(padding: new EdgeInsets.all(10.0)),
                    new RaisedButton(
                        child: new Text("Submit"),
                        onPressed: () {
                          String playerNumber = inputController.text;
                          setState(() {
                            _currentIndex = index;
                          });
                          String timeElapsed =
                              dependencies.stopwatch.elapsed.toString();
                          timeElapsed = timeElapsed.substring(0, 7);
                          if (_currentIndex == 0) {
                            listItem =
                                '$timeElapsed\n2 Points scored by Player Number $playerNumber';
                          } else if (_currentIndex == 1) {
                            listItem =
                                '$timeElapsed\n3 Points scored by Player Number $playerNumber';
                          } else if (_currentIndex == 2) {
                            listItem =
                                '$timeElapsed\n5 Points Scored by Player Number $playerNumber';
                          }
                          writeData(listItem);
                          itemsList.add(listItem);
                          Navigator.of(context).pop();
                        })
                  ],
                ),
              ));
        });
  }
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return new File('$path/data.txt');
}

Future<File> writeData(String message) async {
  final file = await _localFile;
  return file.writeAsString('$message\r\n', mode: FileMode.append);
}

Future<File> clearFile() async {
  final file = await _localFile;
  return file.writeAsStringSync('');
}

Future<String> readData() async {
  try {
    final file = await _localFile;
    String data = await file.readAsString();
    print(data);
    return data;
  } catch ($e) {
    return "error";
  }
}

class TimerText extends StatefulWidget {
  TimerText({this.dependencies});
  final Dependencies dependencies;
  TimerTextState createState() =>
      new TimerTextState(dependencies: dependencies);
}

class TimerTextState extends State<TimerText> {
  TimerTextState({this.dependencies});
  final Dependencies dependencies;
  Timer timer;
  int milliseconds;

  @override
  void initState() {
    timer = new Timer.periodic(
        new Duration(milliseconds: dependencies.timerMillisecondsRefreshRate),
        callback);
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  void callback(Timer timer) {
    if (milliseconds != dependencies.stopwatch.elapsedMilliseconds) {
      milliseconds = dependencies.stopwatch.elapsedMilliseconds;
      final int hundreds = (milliseconds / 10).truncate();
      final int seconds = (hundreds / 100).truncate();
      final int minutes = (seconds / 60).truncate();
      final ElapsedTime elapsedTime = new ElapsedTime(
        hundreds: hundreds,
        seconds: seconds,
        minutes: minutes,
      );
      for (final listener in dependencies.timerListeners) {
        listener(elapsedTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new RepaintBoundary(
          child: new MinutesAndSeconds(dependencies: dependencies),
        ),
        new RepaintBoundary(
          child: new Hundreds(dependencies: dependencies),
        )
      ],
    );
  }
}

class MinutesAndSeconds extends StatefulWidget {
  MinutesAndSeconds({this.dependencies});
  final Dependencies dependencies;
  MinutesAndSecondsState createState() =>
      new MinutesAndSecondsState(dependencies: dependencies);
}

class MinutesAndSecondsState extends State<MinutesAndSeconds> {
  MinutesAndSecondsState({this.dependencies});
  final Dependencies dependencies;

  int minutes = 0;
  int seconds = 0;

  @override
  void initState() {
    dependencies.timerListeners.add(onTick);
    super.initState();
  }

  void onTick(ElapsedTime elapsed) {
    if (elapsed.minutes != minutes || elapsed.seconds != seconds) {
      setState(() {
        minutes = elapsed.minutes;
        seconds = elapsed.seconds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String minutesStr = (minutes % 60).toString();
    String secondsStr = (seconds % 60).toString();
    return new Text('$minutesStr:$secondsStr:', style: dependencies.textStyle);
  }
}

class Hundreds extends StatefulWidget {
  Hundreds({this.dependencies});
  final Dependencies dependencies;

  HundredsState createState() => new HundredsState(dependencies: dependencies);
}

class HundredsState extends State<Hundreds> {
  HundredsState({this.dependencies});
  final Dependencies dependencies;

  int hundreds = 0;

  @override
  void initState() {
    dependencies.timerListeners.add(onTick);
    super.initState();
  }

  void onTick(ElapsedTime elapsed) {
    if (elapsed.hundreds != hundreds) {
      setState(() {
        hundreds = elapsed.hundreds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String hundredsStr = (hundreds % 100).toString().padLeft(2, '0');
    return new Text(hundredsStr, style: dependencies.textStyle);
  }
}
