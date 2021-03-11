import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:familia/screens/main_screens/calender_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  TestState createState() {
    return new TestState();
  }
}

class TestState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController(
      initialPage: 0,
    );
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Color(0xFF4A5767)));
    var deviceSize = MediaQuery.of(context).size;
    return Scaffold(
        resizeToAvoidBottomInset: false, //리사이징 금지
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.6, 1],
                  colors: [Color(0xFF4c546c), Color(0xFF30343c)])),
          child: PageView(controller: pageController, children: [
            Column(
              children: [
                Container(
                    padding: EdgeInsets.only(
                        top: deviceSize.height * 0.3,
                        left: deviceSize.width * 0.25,
                        right: deviceSize.width * 0.25),
                    child: Icon(
                      Icons.calendar_today_outlined,
                      size: deviceSize.width * 0.5,
                      color: Color(0xFFFFFFFF),
                    )),
                Container(
                    child: Text(
                  "Effective Calender",
                  style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: deviceSize.width * 0.07),
                )),
                Container(
                    child: Text(
                  "Manage all of your Agenda",
                  style: TextStyle(
                      color: Color(0xFF999999),
                      fontSize: deviceSize.width * 0.04),
                )),
                Container(
                  padding: EdgeInsets.only(top: deviceSize.height * 0.3),
                  child: DotsIndicator(
                    dotsCount: 3,
                    position: 0,
                    decorator: DotsDecorator(
                        color: Colors.black87, activeColor: Colors.white),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Container(
                    padding: EdgeInsets.only(
                        top: deviceSize.height * 0.3,
                        left: deviceSize.width * 0.25,
                        right: deviceSize.width * 0.25),
                    child: Icon(
                      Icons.check_circle_outline,
                      size: deviceSize.width * 0.5,
                      color: Color(0xFFFFFFFF),
                    )),
                Container(
                    child: Text(
                  "Effiecient To-Do List",
                  style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: deviceSize.width * 0.07),
                )),
                Container(
                    child: Text(
                  "Check your daily To-Do list",
                  style: TextStyle(
                      color: Color(0xFF999999),
                      fontSize: deviceSize.width * 0.04),
                )),
                Container(
                  padding: EdgeInsets.only(top: deviceSize.height * 0.3),
                  child: DotsIndicator(
                    dotsCount: 3,
                    position: 1,
                    decorator: DotsDecorator(
                        color: Colors.black87, activeColor: Colors.white),
                  ),
                )
              ],
            ),
            Column(
              children: [
                Container(
                    padding: EdgeInsets.only(
                        top: deviceSize.height * 0.3,
                        left: deviceSize.width * 0.25,
                        right: deviceSize.width * 0.25),
                    child: Icon(
                      Icons.schedule,
                      size: deviceSize.width * 0.5,
                      color: Color(0xFFFFFFFF),
                    )),
                Container(
                    child: Text(
                  "Great Scheduler",
                  style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: deviceSize.width * 0.07),
                )),
                Container(
                    child: Text(
                  "Check your Schedule at a glance",
                  style: TextStyle(
                      color: Color(0xFF999999),
                      fontSize: deviceSize.width * 0.04),
                )),
                Container(
                    padding: EdgeInsets.only(top: deviceSize.height * 0.09),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(20.0)),
                          primary: Color(0xFFFFFFFF),
                          onPrimary: Color(0xFF111111)),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute<void>(
                            builder: (BuildContext context) {
                          return calender_screen();
                        }));
                      },
                      child: Text("start now"),
                    )),
                Container(
                  padding: EdgeInsets.only(top: deviceSize.height * 0.15),
                  child: DotsIndicator(
                    dotsCount: 3,
                    position: 2,
                    decorator: DotsDecorator(
                        color: Colors.black87, activeColor: Colors.white),
                  ),
                ),
              ],
            )
          ]),
        ));
  }
}
