import 'dart:io';
import 'dart:ui';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reads the device info for android and ios phones and displays it in a simple list
class DeviceInfoScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DeviceInfo();
}

class DeviceInfo extends State<DeviceInfoScreen> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  Map<String, dynamic> _deviceData = <String, dynamic>{};

  void _getDeviceInfo() async {
    Map<String, dynamic> deviceData;

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      print(
          "Received an PlatformException while attempting to read device info!");
      deviceData = <String, dynamic>{
        'Error': 'Failed to read device data',
      };
    }

    if (!mounted) return print("Not mounted, aborting!");

    print("Successfully read device info!");
    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  @override
  void initState() {
    super.initState();
    print("Getting device info");
    _getDeviceInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
              Platform.isAndroid ? 'Android Device Info' : 'iOS Device Info'),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: _deviceData.keys.map((String property) {
                  return Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          property,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                          child: Container(
                        padding:
                            const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                        child: Text(
                          '${_deviceData[property]}',
                          maxLines: 10,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
            RaisedButton(
              padding: EdgeInsets.all(8.0),
              onPressed: () => {Navigator.pop(context)},
              child: Text("Done"),
            ),
          ],
        ));
  }
}
