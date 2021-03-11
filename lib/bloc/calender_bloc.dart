import 'dart:async';
import 'package:familia/tools/calender_database.dart'; //데이터 베이스
import 'package:familia/data/eventDB.dart';

class CalenderBloc {
  final _calendarBlockController = StreamController<List<EventDB>>.broadcast();
  get eventDBs => _calendarBlockController.stream;

  CalenderBloc() {
    getEvents();
  }

  dispose() {
    _calendarBlockController.close();
  }

  getEvents() async {
    _calendarBlockController.sink.add(await DBHelper().getAllEvents());
  }

  addEvents(EventDB eventDB) async {
    await DBHelper().createData(eventDB);
    getEvents();
  }

  deleteEvents(int id) async {
    await DBHelper().deleteEvent(id);
  }

  deleteAll() async {
    await DBHelper().deleteAllDiarys();
    getEvents();
  }
}
