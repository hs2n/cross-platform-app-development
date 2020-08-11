import 'package:flutter/material.dart';

import 'app_properties_bloc.dart';

enum Setting { setting1, setting2, setting3 }

class SettingsPage extends StatefulWidget {
  State<StatefulWidget> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  DateTime _dateTimeSelected = DateTime.now();
  Setting _currentSetting = Setting.setting1;

  TextEditingController _subredditNameController = TextEditingController();

  void _onTFSubredditNameEdited(String newText) {
    print("New subreddit is: " + newText);
    appBloc.fullSubredditName = newText;
  }

  void _updateDateTimeSelected(DateTime newDateTime) {
    setState(() {
      _dateTimeSelected = newDateTime;
    });
  }

  String getSettingsText(Setting setting) {
    String toString;
    switch (setting) {
      case Setting.setting1:
        toString = 'The first setting';
        break;
      case Setting.setting2:
        toString = 'The setting in the middle';
        break;
      case Setting.setting3:
        toString = 'The third setting';
        break;
    }
    return toString;
  }

  @override
  void initState() {
    _subredditNameController.text = appBloc.fullSubredditName;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 14, right: 14, bottom: 20, top: 8),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.account_box),
                title: Text(appBloc.user),
              ),
              ListTile(
                leading: Icon(Icons.perm_device_information),
                title: Text(appBloc.token),
              ),
              ListTile(
                  leading: Text(
                    "Subreddit to browse: ",
                    style: TextStyle(fontSize: 15),
                  ),
                  subtitle: TextField(
                    controller: _subredditNameController,
                    onChanged: _onTFSubredditNameEdited,
                  )),
            ],
          ),
        ),
        ListTile(
            title: Row(
          children: <Widget>[
            Text("Selected date: "),
            Text("${_dateTimeSelected.toIso8601String().substring(0, 10)}"),
          ],
        )),
        ListTile(
          title: Container(
            child: CalendarDatePicker(
              currentDate: DateTime.now(),
              firstDate: DateTime(2000, 1, 1),
              lastDate: DateTime(2099, 12, 31),
              initialDate: _dateTimeSelected,
              onDateChanged: _updateDateTimeSelected,
            ),
          ),
        ),
        ListTile(
          title: Text('You selected "${getSettingsText(_currentSetting)}"'),
        ),
        ListTile(
            title: Text(getSettingsText(Setting.setting1)),
            leading: Radio(
                value: Setting.setting1,
                groupValue: _currentSetting,
                onChanged: (Setting value) {
                  setState(() {
                    _currentSetting = value;
                  });
                })),
        ListTile(
            title: Text(getSettingsText(Setting.setting2)),
            leading: Radio(
                value: Setting.setting2,
                groupValue: _currentSetting,
                onChanged: (Setting value) {
                  setState(() {
                    _currentSetting = value;
                  });
                })),
        ListTile(
            title: Text(getSettingsText(Setting.setting3)),
            leading: Radio(
                value: Setting.setting3,
                groupValue: _currentSetting,
                onChanged: (Setting value) {
                  setState(() {
                    _currentSetting = value;
                  });
                })),
      ],
    );
  }

  @override
  void dispose() {
    _subredditNameController.dispose();

    super.dispose();
  }
}
