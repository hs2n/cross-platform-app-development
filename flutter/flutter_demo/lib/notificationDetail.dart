import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// If the app is opened through a notification, the notifications 'details' will be displayed here
/// For now, not much detail is present, so just a canvas is displayed

class NotificationDetail extends StatefulWidget {
  NotificationDetail(this.payload);

  final String payload;

  @override
  State<StatefulWidget> createState() => NotificationDetailState();
}

class NotificationDetailState extends State<NotificationDetail> {
  String _payload;
  @override
  void initState() {
    super.initState();
    _payload = widget.payload;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Showing notification: ${(_payload ?? '')}'),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}
