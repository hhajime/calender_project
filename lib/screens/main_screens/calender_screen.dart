import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:familia/constants/constants.dart';
import 'package:familia/presentation/weather_icons_icons.dart'; // velog 업데이트
import 'package:time_range_picker/time_range_picker.dart';
import 'package:geolocator/geolocator.dart'; //ios 추가 설정 확인(pub참고)
import 'package:weather/weather.dart'; //android X support 확인(pub참고)
import 'package:familia/data/eventDB.dart';
import 'package:familia/bloc/calender_bloc.dart';
import 'package:intl/intl.dart';

import 'package:familia/screens/main_screens/scheduler_screen.dart';

// Example holidays
final Map<DateTime, List> _holidays = {
  DateTime(2020, 1, 1): ['New Year\'s Day'],
  DateTime(2020, 1, 6): ['Epiphany'],
  DateTime(2020, 2, 14): ['Valentine\'s Day'],
  DateTime(2020, 4, 21): ['Easter Sunday'],
  DateTime(2020, 4, 22): ['Easter Monday'],
};

String strt;
String edd;

void main() {
  initializeDateFormatting().then((_) => runApp(calender_screen()));
}

// ignore: camel_case_types
class calender_screen extends StatefulWidget {
  @override
  TestState2 createState() {
    return new TestState2(); // there is no need of new here, we are already using Dart 2.0 +
  }
}

final bloc = CalenderBloc();

class TestState2 extends State<calender_screen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  Map<DateTime, List> _events;
  Map<DateTime, List> _2;
  Map<DateTime, Map> _1;
  List _selectedEvents;
  AnimationController _animationController;
  CalendarController _calendarController;
  PageController _pages = PageController(initialPage: 0);
  DateTime eventDate;
  WeatherFactory wf = WeatherFactory('ab4cd5fcd709e410d40715a6afe7247f');
  Weather w; // 같은 클래스 내 다른 메소드 안의 변수를 불러오기 위해 미리 선언
  int weatherCode;
  IconData iconData = Icons.refresh;
  double celsious;

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  void getLocation() async {
    print('click');
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );

    print('click');
    double lat = position.latitude;
    double lon = position.longitude;
    w = await wf.currentWeatherByLocation(
        lat, lon); // get weather by geolocator
    if (celsious != null) {
      celsious = 0;
    } else {
      celsious = w.temperature.celsius;
    }
    double kelvin = w.temperature.kelvin;
    weatherCode = w.weatherConditionCode;
    print(
        'in ${w.areaName}, weather is ${w.weatherDescription}, $weatherCode and temperature is ${celsious}');
  }

  @override
  void initState() {
    // 초기 상태_ 비어있게 -> 추후 저장된 캘린더 내용으로 설정
    super.initState();
    final _selectedDay = DateTime.now();
    _events = {};

    _selectedEvents = _events[_selectedDay] ?? [];
    _calendarController = CalendarController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  void _addEvents() {
    // 캘린더에 추가
    final day = _calendarController.selectedDay;
    final title = titleTextController.text;
    final details = contentTextController.text;

    setState(() {
      _events.update(day, (existingEvents) => existingEvents..add(title),
          ifAbsent: () => [title]);
      _events.update(day, (existingEvents) => existingEvents..add(details),
          ifAbsent: () => [details]);
    }); // title(textcontroller)-> _events List 입력 -> eventlist builder에 의해 출력
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    print('CALLBACK: _onDaySelected is $day');
    setState(() {
      _selectedEvents = events;
      eventDate = day;
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onCalendarCreated');
  }

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;
    PageController _pages = PageController(initialPage: 0);
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Color(0xFF4c546c)));
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.6, 1],
                colors: [Color(0xFF4c546c), Color(0xFF30343c)])),
        child: PageView(
          controller: _pages,
          onPageChanged: (int) {
            print('Page Changes to index $int');
          },
          children: <Widget>[
            Container(
                child: Column(children: [
              const SizedBox(height: 46.0),

              Stack(
                children: [
                  _buildTableCalendar(),
                  Positioned(
                      bottom: 330,
                      right: 20,
                      child: Column(
                        children: [
                          Container(
                            child: IconButton(
                              icon: Icon(
                                iconData,
                                color: Colors.white,
                                size: 40,
                              ),
                              onPressed: () {
                                setState(() {
                                  _setIconData();
                                  print('hi2');
                                });
                              },
                            ),
                          ),
                          Container(
                            child: Text(
                              '$celsious ℃',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      )),

                  // _buildTableCalendarWithBuilders(),//아이콘 추가
                ],
              ),
              Expanded(
                  child: _buildEventList()) // check_ 여기서 불러오기 때문에 초기화 안되는지?
            ])),
            Container(
              child: Text('Empty Body 1'),
            ),
            Container(
              child: Text('Empty Body 2'),
            ),
            Container(
              child: Text('Empty Body 3'),
            )
            // Switch out 2 lines below to play with TableCalendar's settings
            //-----------------------
          ],
          physics:
              NeverScrollableScrollPhysics(), // Comment this if you need to use Swipe.
        ),
      ),
      bottomNavigationBar: _bottomBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _floatBtn(),
    );
  }

  // Simple TableCalendar configuration (using Styles)
  _buildTableCalendar() {
    return TableCalendar(
      calendarController: _calendarController,
      events: _events,
      holidays: _holidays,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      calendarStyle: CalendarStyle(
        weekdayStyle:
            TextStyle(color: Colors.white, fontSize: deviceWidth * 0.032),
        weekendStyle:
            TextStyle(color: Color(0xFFEF9A9A), fontSize: deviceWidth * 0.032),
        holidayStyle:
            TextStyle(color: Colors.white, fontSize: deviceWidth * 0.032),
        selectedStyle:
            TextStyle(color: Colors.white, fontSize: deviceWidth * 0.032),
        todayStyle:
            TextStyle(color: Colors.white, fontSize: deviceWidth * 0.032),
        outsideStyle:
            TextStyle(color: Colors.grey, fontSize: deviceWidth * 0.032),
        eventDayStyle:
            TextStyle(color: Colors.white, fontSize: deviceWidth * 0.032),
        outsideWeekendStyle:
            TextStyle(color: Colors.grey, fontSize: deviceWidth * 0.032),
        selectedColor: Colors.blueGrey[400],
        todayColor: Color(0xFF33a9b2),
        markersColor: Colors.blue[300],
        markersPositionBottom: 6,
        outsideDaysVisible: true,
      ),
      headerStyle: HeaderStyle(
          formatButtonVisible: false,
          headerPadding: EdgeInsets.only(
              left: deviceWidth * 0.05,
              top: deviceHeight * 0.01,
              bottom: deviceHeight * 0.069),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          //2week / month settings style
          formatButtonTextStyle:
              TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
          formatButtonDecoration: BoxDecoration(
            color: Colors.deepOrange[400],
            borderRadius: BorderRadius.circular(16.0),
          ),
          leftChevronVisible: false,
          rightChevronVisible: false),
      onDaySelected: _onDaySelected,
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
    );
  }

  _buildEventList() {
    // _events로 관리하는 동시에 sqlite 데이터 불러오기. 업데이트 추가,
    return ListView(
        padding: const EdgeInsets.only(
            top: 0.0, bottom: 50.0, left: 0.0, right: 0.0),
        children: _selectedEvents
            .map((event) => Dismissible(
                  key: UniqueKey(),
                  background: Container(color: Color(0xFF33a9b2)),
                  onDismissed: (direction) {
                    final day = _calendarController.selectedDay;
                    _events.update(
                        day, (existingEvents) => existingEvents..remove(event));
                    setState(() {});
                  },
                  child: Container(
                      decoration: BoxDecoration(
                        border:
                            Border.all(width: 1.1, color: Color(0xFFF5F5F5)),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3.0),
                      child: ListTile(
                          title: Row(children: <Widget>[
                            // Event color
                            Container(
                                // 이벤트 색상 변경 버튼(태그 대용)
                                child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  padding: (EdgeInsets.symmetric(
                                      horizontal: deviceWidth * 0.03,
                                      vertical: deviceHeight * 0.028)),
                                  shape: new CircleBorder(),
                                  primary: Color(0xFFFFFFFF),
                                  onPrimary: Color(0xFF111111)),
                              onPressed: () {
                                setState(() {
                                  //이벤트 세부내용 확정시키기
                                });
                              },
                              child: Text(
                                'Event tag',
                                style: TextStyle(fontSize: deviceWidth * 0.02),
                              ),
                            )),
                            Spacer(),
                            // Event name
                            Column(
                              children: <Widget>[
                                Container(
                                    child: Text(
                                  event.toString(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: deviceWidth * 0.04),
                                )),
                                Container(
                                    child: Text(
                                  event.toString(), //titlecontroller이용, 설정
                                  style: TextStyle(
                                      color: Color(0x8FFFFFFF),
                                      fontSize: deviceWidth * 0.035),
                                )),
                                Container(
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        child: Text(
                                          '${DateTime.now().month}/${DateTime.now().day} ',
                                          style: TextStyle(
                                              color: Color(0xFF6FFFFF),
                                              fontSize: deviceWidth * 0.028),
                                        ),
                                      ),
                                      Container(
                                          child: Text(
                                              '  ')), //need replace to spacer
                                      Container(
                                          child: Text(
                                        //일정 시간
                                        '$strt - $edd',
                                        style: TextStyle(
                                            color: Color(0xFF6FFFFF),
                                            fontSize: deviceWidth * 0.028),
                                      )),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Spacer(
                              flex: 6,
                            ),
                          ]),
                          onTap: () {})),
                ))
            .toList());
  }

  Widget _bottomBar() {
    return BottomAppBar(
        shape: CircularNotchedRectangle(),
        color: Color(0xFF4c546c),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox.fromSize(
              size: Size(deviceWidth * 0.17,
                  deviceHeight * 0.0625), // button width and height
              child: ClipOval(
                child: Material(
                  color: Color(0xFF4c546c), // button color
                  child: InkWell(
                    splashColor: Color(0xFF33a9b2), // splash color
                    onTap: () {
                      setState(() {
                        _pages.jumpToPage(0);
                      });
                    }, // button pressed
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.calendar_today_outlined,
                          color: Color(0x8FFFFFFF),
                        ), // icon
                        Text(
                          "Calender",
                          style: TextStyle(
                              color: Color(0x8FFFFFFF),
                              fontSize: deviceWidth * 0.023),
                        ), // text
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Spacer(),
            SizedBox.fromSize(
              size: Size(70, 50), // button width and height
              child: ClipOval(
                child: Material(
                  color: Color(0xFF4c546c), // button color
                  child: InkWell(
                    splashColor: Color(0xFF33a9b2), // splash color
                    onTap: () {
                      setState(() {
                        Navigator.push(context, MaterialPageRoute<void>(
                            builder: (BuildContext context) {
                          return scheduler_screen();
                        }));
                      });
                    }, // button pressed
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.schedule,
                          color: Color(0x8FFFFFFF),
                        ), // icon
                        Text(
                          "Schedule",
                          style: TextStyle(
                              color: Color(0x8FFFFFFF),
                              fontSize: deviceWidth * 0.023),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Spacer(),
            Spacer(),
            Spacer(),
            SizedBox.fromSize(
              size: Size(70, 50), // button width and height
              child: ClipOval(
                child: Material(
                  color: Color(0xFF4c546c), // button color
                  child: InkWell(
                    splashColor: Color(0xFF33a9b2), // splash color
                    onTap: () {
                      setState(() {
                        _pages.jumpToPage(2);
                      });
                    }, // button pressed
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.check_circle_outline,
                          color: Color(0x8FFFFFFF),
                        ), // icon
                        Text(
                          "To-Do",
                          style: TextStyle(
                              color: Color(0x8FFFFFFF),
                              fontSize: deviceWidth * 0.023),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Spacer(),
            SizedBox.fromSize(
              size: Size(deviceWidth * 0.175,
                  deviceHeight * 0.0625), // button width and height
              child: ClipOval(
                child: Material(
                  color: Color(0xFF4c546c), // button color
                  child: InkWell(
                    splashColor: Color(0xFF33a9b2), // splash color
                    onTap: () {
                      setState(() {
                        _pages.jumpToPage(3);
                      });
                    }, // button pressed
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.settings,
                          color: Color(0x8FFFFFFF),
                        ), // icon
                        Text(
                          "Settings",
                          style: TextStyle(
                              color: Color(0x8FFFFFFF),
                              fontSize: deviceWidth * 0.023),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget _floatBtn() {
    return FloatingActionButton(
      onPressed: () {
        setState(() {
          showModalBottomSheet(
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(40),
                ),
              ),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              context: context,
              builder: _buildBottomSheet);
        });
      }, // default event list에 생성
      backgroundColor: Color(0xFF4c546c),
      focusColor: Color(0xFF111111),
      hoverColor: Color(0xFF111111),
      splashColor: Color(0xFF33a9b2),
      child: Icon(
        Icons.add,
        color: Color(0x9FFFFFFF),
        size: deviceWidth * 0.075,
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    final _valueList = ['first', 'second', 'third'];
    var _selectedValue = 'first';
    return SingleChildScrollView(
        reverse: true,
        child: Container(
            color: Color(0xffffffff),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.only(
                        top: deviceHeight * 0.05,
                        left: deviceWidth * 0.05,
                        right: deviceWidth * 0.05,
                        bottom: deviceHeight * 0.03),
                    child: TextField(
                      controller: titleTextController,
                      decoration: new InputDecoration(
                        suffixIcon: IconButton(
                            onPressed: () => titleTextController.clear(),
                            icon: Icon(
                              Icons.clear,
                              color: Colors.white,
                            )),
                        enabledBorder: const OutlineInputBorder(
                            // width: 0.0 produces a thin "hairline" border
                            borderSide: const BorderSide(
                                color: Color(0xFF4c546c), width: 3.0),
                            borderRadius: const BorderRadius.all(
                                const Radius.circular(10.0))),
                        fillColor: Colors.white,
                        focusedBorder: new OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFF4c546c), width: 3.0),
                            borderRadius: const BorderRadius.all(
                                const Radius.circular(10.0))),
                        border: const OutlineInputBorder(),
                        filled: true,
                        labelText: ('Event Name'),
                        labelStyle: TextStyle(
                            color: Color(0xFF4c546c),
                            fontSize: deviceWidth * 0.05,
                            fontWeight: FontWeight.w300),
                      ),
                      style: TextStyle(color: Colors.black),
                    )),
                Container(
                    margin: EdgeInsets.only(
                        left: deviceWidth * 0.05,
                        right: deviceWidth * 0.05,
                        bottom: deviceHeight * 0.03),
                    child: TextField(
                      controller: contentTextController,
                      decoration: new InputDecoration(
                        suffixIcon: IconButton(
                            onPressed: () => contentTextController.clear(),
                            icon: Icon(
                              Icons.clear,
                              color: Colors.white,
                            )),
                        enabledBorder: const OutlineInputBorder(
                            // width: 0.0 produces a thin "hairline" border
                            borderSide: const BorderSide(
                                color: Color(0xFF4c546c), width: 3.0),
                            borderRadius: const BorderRadius.all(
                                const Radius.circular(10.0))),
                        fillColor: Colors.white,
                        focusedBorder: new OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFF4c546c), width: 3.0),
                            borderRadius: const BorderRadius.all(
                                const Radius.circular(10.0))),
                        border: const OutlineInputBorder(),
                        filled: true,
                        labelText: ('Details'),
                        labelStyle: TextStyle(
                            color: Color(0xFF4c546c),
                            fontSize: deviceWidth * 0.05,
                            fontWeight: FontWeight.w300),
                      ),
                      style: TextStyle(color: Colors.black),
                    )),
                Stack(
                  children: <Widget>[
                    Container(
                      height: 80,
                    ),
                    Positioned(
                      bottom: 10,
                      left: deviceWidth * 0.05,
                      child: Container(
                        width: deviceWidth * 0.9,
                        height: deviceHeight * 0.08,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          border:
                              Border.all(color: Color(0xFF4c546c), width: 3.0),
                        ),
                      ),
                    ),
                    Positioned(
                      left: deviceWidth * 0.07,
                      bottom: 40,
                      child: Container(
                          padding: const EdgeInsets.only(
                              left: 5.0,
                              right: 5.0,
                              bottom: 23.0,
                              top: 20), // add
                          color: Colors.white,
                          child: Text(
                            'Select Time',
                            style: TextStyle(
                                color: Color(0xFF4c546c),
                                fontSize: deviceWidth * 0.034,
                                fontWeight: FontWeight.w300),
                          )),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          top: 15.0, left: 5.0, right: 5.0, bottom: 1.0),
                      child: Row(
                        children: [
                          Spacer(flex: 1),
                          Container(child: Text('from:')),
                          Container(child: Text(' $strt')),
                          Spacer(),
                          Container(child: Text('to:')),
                          Container(child: Text(' $edd')),
                          Spacer(
                            flex: 3,
                          ),
                          Container(
                            child: IconButton(
                              icon: Icon(
                                Icons.watch_later_outlined,
                                color: Colors.black,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showTimeRangePicker(context);
                                });
                              },
                            ),
                          ),
                          Spacer()
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: deviceHeight * 0.01),
                Stack(
                  children: <Widget>[
                    Container(
                      height: 90,
                    ),
                    Positioned(
                      bottom: 0,
                      left: deviceWidth * 0.05,
                      child: Container(
                        width: deviceWidth * 0.9,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          border:
                              Border.all(color: Color(0xFF4c546c), width: 3.0),
                        ),
                      ),
                    ),
                    Positioned(
                      left: deviceWidth * 0.07,
                      bottom: 40,
                      child: Container(
                          padding: const EdgeInsets.only(
                              top: 5.0,
                              left: 5.0,
                              right: 5.0,
                              bottom: 28.0), // add
                          color: Colors.white,
                          child: Text(
                            'Select Tag',
                            style: TextStyle(
                                color: Color(0xFF4c546c),
                                fontSize: deviceWidth * 0.034,
                                fontWeight: FontWeight.w300),
                          )),
                    ),
                    Container(
                        padding: const EdgeInsets.only(
                            top: 30.0, left: 40.0, right: 5.0, bottom: 1.0),
                        child: Row(
                          children: [
                            Text('category: '),
                            DropdownButton(
                              value: _selectedValue,
                              items: _valueList.map(
                                (value) {
                                  return DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  );
                                },
                              ).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedValue = value;
                                });
                              },
                            ),
                            Text('color: '),
                            IconButton(
                              icon: Icon(
                                Icons.circle,
                                color: Colors.red[200],
                                size: deviceHeight * 0.04,
                              ),
                              onPressed: () {
                                setState(() {
                                  //add color picker
                                });
                              },
                            ),
                          ],
                        )),
                  ],
                ),
                Container(
                  child: SizedBox(
                    height: 30,
                  ),
                ),
                Row(
                  children: [
                    Container(
                        child: TextButton(
                      style: TextButton.styleFrom(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(20.0)),
                          primary: Colors.transparent),
                      onPressed: () {
                        setState(() {
                          Navigator.pop(context);
                        });
                      },
                      child: Text(
                        '   CANCEL',
                        style: TextStyle(
                            color: Color(0x6F4c546c),
                            fontSize: deviceWidth * 0.042),
                      ),
                    )),
                    Spacer(),
                    Container(
                        child: TextButton(
                      style: TextButton.styleFrom(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(20.0)),
                          primary: Colors.transparent),
                      onPressed: () {
                        // 입력 없으면 경고 메세지 alert dialog 사용하기
                        writeCalender(
                          titleTextController.text,
                          contentTextController.text,
                        );
                        _addEvents(); // calender에 추가됨
                        setState(() {
                          Navigator.pop(context);
                        });
                      },
                      child: Text(
                        'SAVE',
                        style: TextStyle(
                            color: Color(0xFF4c546c),
                            fontSize: deviceWidth * 0.042),
                      ),
                    )),
                  ],
                ),
              ],
            )));
  }

  void _setIconData() {
    getLocation();

    if ((weatherCode == 200) ||
        (weatherCode == 201) ||
        (weatherCode == 202) ||
        (weatherCode == 230) ||
        (weatherCode == 231) ||
        (weatherCode == 232)) //==range between
      iconData = WeatherIcons.rainstorm;
    else if ((weatherCode == 210) || (weatherCode == 211))
      iconData = WeatherIcons.storm;
    else if ((weatherCode == 300) ||
        (weatherCode == 301) ||
        (weatherCode == 302) ||
        (weatherCode == 310) ||
        (weatherCode == 311) ||
        (weatherCode == 312) ||
        (weatherCode == 313) ||
        (weatherCode == 314) ||
        (weatherCode == 321))
      iconData = WeatherIcons.drizzle;
    else if ((weatherCode == 500) ||
        (weatherCode == 501) ||
        (weatherCode == 520))
      iconData = WeatherIcons.rain;
    else if ((weatherCode == 502) ||
        (weatherCode == 503) ||
        (weatherCode == 504))
      iconData = WeatherIcons.heavyrain;
    else if ((weatherCode == 511))
      iconData = WeatherIcons.snowrain;
    else if ((weatherCode == 521) ||
        (weatherCode == 521) ||
        (weatherCode == 531))
      iconData = WeatherIcons.showerrain;
    else if ((weatherCode == 600) ||
        (weatherCode == 601) ||
        (weatherCode == 602))
      iconData = WeatherIcons.snow;
    else if ((weatherCode == 611) ||
        (weatherCode == 612) ||
        (weatherCode == 613) ||
        (weatherCode == 614) ||
        (weatherCode == 615) ||
        (weatherCode == 616))
      iconData = WeatherIcons.sleet;
    else if ((weatherCode == 620) ||
        (weatherCode == 621) ||
        (weatherCode == 622))
      iconData = WeatherIcons.lightsnow;
    else if ((701 == weatherCode) ||
        (weatherCode == 711) ||
        (weatherCode == 721) ||
        (weatherCode == 731) ||
        (weatherCode == 741) ||
        (weatherCode == 751) ||
        (weatherCode == 761) ||
        (weatherCode == 762) ||
        (weatherCode == 771))
      iconData = WeatherIcons.fog;
    else if ((weatherCode == 781))
      iconData = WeatherIcons.tornado;
    else if ((weatherCode == 800))
      iconData = WeatherIcons.clear;
    else if ((weatherCode == 801) || (weatherCode == 802))
      iconData = WeatherIcons.lightclouds;
    else if ((weatherCode == 803) || (weatherCode == 804))
      iconData = WeatherIcons.clouds;
  }

  void writeCalender(String title, String content) {
    String nowDate = DateFormat('yy-MM-dd').format(DateTime.now());
    EventDB eventDB = EventDB(
        title: title,
        content: content,
        eventdate: nowDate); //nowDate->selecteddate
    bloc.addEvents(eventDB);
  }
}

Widget _showTimeRangePicker(BuildContext context) {
  return showTimeRangePicker(
    context: context,
    onStartChange: (start) {
      strt = "${start.format(context)}";
      print("start time : ${start.format(context)}");
    },
    onEndChange: (end) {
      edd = "${end.format(context)}";
      print("end time : ${end.format(context)}");
    },
    padding: 30,
    interval: Duration(minutes: 30),
    strokeWidth: 20,
    handlerRadius: 14,
    strokeColor: Color(0xFF4c546c),
    handlerColor: Color(0x8F4c546c),
    selectedColor: Color(0x5F4c546c),
    backgroundColor: Colors.black.withOpacity(0.2),
    ticksColor: Colors.white,
    ticks: 12,
    labels: ["12 pm", "3 am", "6 am", "9 am", "12 am", "3 pm", "6 pm", "9 pm"]
        .asMap()
        .entries
        .map((e) {
      return ClockLabel.fromIndex(idx: e.key, length: 8, text: e.value);
    }).toList(),
  );
}
