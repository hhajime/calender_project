import 'package:flutter/foundation.dart';

class EventDB {
  final int id;
  final String title;
  final String content;
  final String eventdate;

  EventDB({this.id, this.title, this.content, this.eventdate});

  factory EventDB.fromJson(Map<String, dynamic> json) => EventDB(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        eventdate: json['eventdate'],
      );

  Map<String, dynamic> toJson() =>
      {"id": id, "title": title, "content": content, "eventdate": eventdate};
}
