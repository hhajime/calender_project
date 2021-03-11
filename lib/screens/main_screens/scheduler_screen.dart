import 'package:flutter/material.dart';

// ignore: camel_case_types
class scheduler_screen extends StatefulWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: Text('scheduler_screen'),
        ),
        body: Center(
          child: Text('scheduler screen'),
        ),
      ),
    );
  }

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
