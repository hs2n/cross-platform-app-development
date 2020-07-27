import 'dart:async';

import 'package:qrscan/qrscan.dart' as scanner;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';

import 'deviceInfo.dart';
import 'notifications.dart';
import 'notificationDetail.dart';

/// This is a simple flutter demo app which currently includes:
///  - QR Code scanning
///  - Notification handling
///  - Reading the device info
///
/// In flutter, classes usually are structured with a base class i.e. 'DemoHomepage'
/// which is inherited by a state i.e. 'DemoHomepageState'

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Streams are created so that app can respond to notification-related events since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}

Future<void> main() async {
  // The flutter notifications plugin needs this for proper initialization in main
  WidgetsFlutterBinding.ensureInitialized();

  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  // Note: permissions aren't requested here just to demonstrate that can be done later using the `requestPermissions()` method
  // of the `IOSFlutterLocalNotificationsPlugin` class
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {
        didReceiveLocalNotificationSubject.add(ReceivedNotification(
            id: id, title: title, body: body, payload: payload));
      });
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    selectNotificationSubject.add(payload);
  });

  runApp(
    MaterialApp(
      home: FlutterDemo(),
    ),
  );
}

class FlutterDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DemoHomepage(title: 'Flutter demo app'),
    );
  }
}

/// The demo currently shows 3 buttons and a textfield.
/// The buttons take the user to their respective functionalities.
/// Once a QR Code is successfully scanned, the QR Code's text will appear in the text field
class DemoHomepage extends StatefulWidget {
  DemoHomepage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  DemoHomepageState createState() => DemoHomepageState();
}

class DemoHomepageState extends State<DemoHomepage> {
  TextEditingController _qrTextController = new TextEditingController();

  @override
  void initState() {
    super.initState();

    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
  }

  /// Configures the listener for notifications
  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body)
              : null,
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Ok'),
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NotificationDetail(receivedNotification.payload),
                  ),
                );
              },
            )
          ],
        ),
      );
    });
  }

  /// If the app is opened through a notification, the app opens the 'NotificationDetail' dialog
  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NotificationDetail(payload)),
      );
    });
  }

  /// Opens new page with device info
  void _displayDeviceInfo() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => DeviceInfoScreen()));
  }

  /// Opens new screen with notifications manager
  void _openNotificationScreen() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => NotificationManager()));
  }

  /// The QR Code scanning is handled by the 'qrscan' package. Just need to get result
  void _handleQRScan() async {
    print("Starting QR scan");

    String scanResult = "";
    scanResult = await scanner.scan();
    _qrTextController.text = scanResult;
  }

  @override
  void dispose() {
    // Closing the notification listener streams
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              padding: EdgeInsets.all(8.0),
              onPressed: _handleQRScan,
              child: Text("Scan QR-Code"),
            ),
            TextField(
              controller: _qrTextController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'QR Scan results will appear here.',
                border: OutlineInputBorder(),
              ),
            ),
            RaisedButton(
              padding: EdgeInsets.all(8.0),
              onPressed: _displayDeviceInfo,
              child: Text("Show device info"),
            ),
            RaisedButton(
              padding: EdgeInsets.all(8.0),
              onPressed: _openNotificationScreen,
              child: Text("Manage notifications"),
            ),
          ],
        ),
      ),
    );
  }
}
