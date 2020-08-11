import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_50mb_demo/dashboard.dart';
import 'package:flutter_50mb_demo/inventory.dart';
import 'package:flutter_50mb_demo/settings.dart';

import 'package:qrscan/qrscan.dart' as scanner;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app_properties_bloc.dart';

final _secureStorage = new FlutterSecureStorage();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  @override
  _DemoPageState createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> with TickerProviderStateMixin {
  TabController _tabController;

  final List<String> _tabTitles = ["Dashboard", "Inventory", "Settings"];
  final String _defaultTitle = "Demo 2 - Flutter Boogaloo";

  bool _authenticated = false;

  void _scanQrCode() async {
    try {
      String credentials = await scanner.scan();

      if (_validateAndAuthenticate(credentials)) {
        _secureStorage.write(key: 'credentials', value: credentials);
      } else {
        if (credentials == null)
          throw "Scan was not successful.";
        else
          throw "Could not validate credentials: '$credentials'";
      }
      print("Credentials are $credentials");
    } catch (err) {
      print("Caught an error while attempting to scan: ${err.toString()}");
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "The scan was not successful. Please try again.",
              style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontWeight: FontWeight.normal),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  SimpleDialogOption(
                    child: Text(
                      "Ok",
                      style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 16),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          );
        },
      );
    }
  }

  void _deAuthenticate() {
    appBloc.updateTitle(_defaultTitle);

    _secureStorage.delete(key: 'credentials');
    appBloc.user = null;
    appBloc.token = null;

    setState(() {
      _authenticated = false;
    });
  }

  bool _validateAndAuthenticate(String credentials) {
    print("Verifying: $credentials");

    Map<String, dynamic> creds = jsonDecode(credentials);
    String user = creds['user'];
    String token = creds['token'];

    if (user == null || token == null) {
      print("Could not verify credentials: $credentials");
      return false;
    } else {
      print("Successfully verified credentials: $credentials");

      appBloc.user = user;
      appBloc.token = token;

      setState(() {
        _authenticated = true;
      });
      // Tab update listener is not called on first login
      appBloc.updateTitle(_tabTitles[0]);
      return true;
    }
  }

  void _logoutButtonPressed() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            "Do you want to logout?",
            style: TextStyle(fontWeight: FontWeight.normal),
          ),
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SimpleDialogOption(
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Theme.of(context).errorColor,
                    ),
                  ),
                  onPressed: () => {Navigator.pop(context)},
                ),
                SimpleDialogOption(
                  child: Text("Logout"),
                  onPressed: () {
                    _deAuthenticate();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    _secureStorage.read(key: 'credentials').then(_validateAndAuthenticate,
        onError: (err) => print("Error while retrieving credentials: $err"));

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      appBloc.updateTitle(_tabTitles[_tabController.index]);
    });

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<Object>(
          stream: appBloc.titleStream,
          initialData: _defaultTitle,
          builder: (context, snapshot) {
            return Text(snapshot.data);
          },
        ),
        actions: _authenticated == true
            ? <Widget>[
                Builder(builder: (BuildContext context) {
                  return FlatButton(
                    child: Icon(Icons.exit_to_app),
                    textColor: Theme.of(context).buttonColor,
                    onPressed: _logoutButtonPressed,
                  );
                })
              ]
            : null,
      ),
      body: _authenticated == false
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Hello!',
                    style: TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).primaryColorDark),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 56, right: 56, top: 10),
                    child: Text(
                      "Start by pressing the button below and authorizing yourself.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.w300),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 52),
                    child: FlatButton(
                      padding: EdgeInsets.only(
                          bottom: 20, top: 20, left: 32, right: 32),
                      child: Text(
                        "Scan access code",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w300,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                            color: Theme.of(context).primaryColorDark),
                      ),
                      onPressed: _scanQrCode,
                    ),
                  ),
                ],
              ),
            )
          : DefaultTabController(
              length: 3,
              child: Scaffold(
                body: Column(
                  children: <Widget>[
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: <Widget>[
                          Tab(
                            child: Dashboard(),
                          ),
                          Tab(
                            child: Inventory(),
                          ),
                          Tab(
                            child: SettingsPage(),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: Theme.of(context).accentColor,
                      child: TabBar(
                        controller: _tabController,
                        tabs: <Widget>[
                          Tab(
                            icon: Icon(Icons.dashboard),
                          ),
                          Tab(
                            icon: Icon(Icons.info),
                          ),
                          Tab(
                            icon: Icon(Icons.settings),
                          ),
                        ],
                        indicatorColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

//   Builder(
//   builder: (BuildContext context) {
//     return FlatButton(
//       child: Text('Sign out'),
//       textColor: Theme.of(context).buttonColor,
//       onPressed: () async {
//         await _secureStorage.delete(key: 'credentials');
//         setState(() {
//           _authenticated = false;
//           _user = null;
//           _token = null;
//         });
//       },
//     );
