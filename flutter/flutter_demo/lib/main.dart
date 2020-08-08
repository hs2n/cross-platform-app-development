import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_demo/loginPage.dart';
import 'package:flutter_demo/registerPage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';

import 'deviceInfo.dart';

/// This is a simple flutter demo app which currently includes:
///  - QR Code scanning
///  - Notification handling
///  - Reading the device info
///
/// In flutter, classes usually are structured with a base class i.e. 'DemoHomepage'
/// which is inherited by a state i.e. 'DemoHomepageState'

final FlutterSecureStorage _secureStorage = new FlutterSecureStorage();

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
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  TextEditingController _qrTextController = new TextEditingController();
  TextEditingController _tokenTextController = new TextEditingController();

  @override
  void initState() {
    super.initState();

    _initPushNotification();
  }

  void _initPushNotification() {
    /// Configuring the callback handlers for notifications 'onMessage', 'onLaunch' and 'onResume'
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        dynamic notification = message["notification"];
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return _buildDialog(
                context, notification["title"], notification["body"]);
          },
        );
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );

    /// Requesting a token from the Firebase FCM service. The token is needed
    /// for notifications to work properly
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      print("Push Messaging token: $token");
    });

    /// Requesting permissions
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  Widget _buildDialog(BuildContext context, String title, String body) {
    return AlertDialog(
      title: Text("Notification: $title"),
      content: Text("$body"),
      actions: <Widget>[
        FlatButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  // void _displayUserPage() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => UserPage(),
  //     ),
  //   );
  // }

  /// Opens new page with device info
  void _displayDeviceInfo() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => DeviceInfoScreen()));
  }

  void _displayUsersPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => UserPage()));
  }

  void _displayRegisterPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => RegisterPage()));
  }

  /// Opens new screen with notifications manager
  void _openNotificationScreen() {
    print("Local notifications management is currently unavailable.");
    // Navigator.push(context,
    //    MaterialPageRoute(builder: (context) => NotificationManager()));
  }

  /// The QR Code scanning is handled by the 'qrscan' package. Just need to get result
  void _handleQRScan() async {
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
            Container(
              margin: const EdgeInsets.only(top: 10.0),
              child: Column(
                children: <Widget>[
                  Text("Notifications & Device Info"),
                  ButtonBar(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      RaisedButton(
                        onPressed: _openNotificationScreen,
                        child: Text("Manage notifications"),
                      ),
                      RaisedButton(
                        onPressed: _displayDeviceInfo,
                        child: Text("Show device info"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
                margin: const EdgeInsets.only(top: 6.0),
                child: Column(
                  children: <Widget>[
                    Text("Login & Register"),
                    ButtonBar(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        RaisedButton(
                          onPressed: _displayUsersPage,
                          child: Text("Go to login"),
                        ),
                        RaisedButton(
                          onPressed: _displayRegisterPage,
                          child: Text("Register new"),
                        ),
                        RaisedButton(
                          onPressed: _updateLoginToken,
                          child: Text("Refresh token"),
                        ),
                      ],
                    ),
                  ],
                )),
            TextField(
              controller: _tokenTextController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Login token will appear here.',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateLoginToken() async {
    String token = await _secureStorage.read(key: "firebaseToken");
    print("Token is $token");
    _tokenTextController.text = token == null ? "No token yet" : token;
  }
}
