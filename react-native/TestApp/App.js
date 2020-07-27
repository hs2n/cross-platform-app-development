import React, { Component } from 'react';
import {
  StyleSheet,
  View,
  Text,
  Button,
} from 'react-native';

import { getDeviceName, getHardware, getModel, getBatteryLevel, getDeviceId, getManufacturer, isBatteryCharging, getBrand, getBuildNumber } from 'react-native-device-info';

import QRCodeReader from './Components/QRCodeReader';

import { LocalNotification } from './Components/PushNotificationController'


class App extends Component {
  state = {
  }

  onQRCodeReaderPressed = (e) => {
    e.preventDefault();
    this.setState({
      currentView: <QRCodeReader onBackButtonPressed={this.onBackButtonPressed} />
    })
  }

  readDevice = async () => {
    this.setState({
      deviceInfo:
        `\n
      Brand: ${getBrand()}\n
      Manufacturer: ${await getManufacturer()}\n
      BuildNumber: ${getBuildNumber()}\n
      Hardware: ${await getHardware()}\n
      DeviceName: ${await getDeviceName()}\n
      DeviceID: ${getDeviceId()}\n
      Model: ${getModel()}\n
      IsBatteryCharging: ${await isBatteryCharging()}\n
      BatteryLevel: ${(await getBatteryLevel() * 100)} %
      `})
  }

  onPushNotificationPressed = (e) => {
    e.preventDefault();
    console.log("onPushNotificationPressed")
    LocalNotification.instantNotification();
  }

  onScheduledPushNotificationPressed = (e) => {
    e.preventDefault();
    console.log("onScheduledPushNotificationPressed")
    LocalNotification.scheduledNotification();
  }

  onBackButtonPressed = (e) => {
    e.stopPropagation();
    this.setState({
      currentView: undefined
    })
  }

  render() {
    if (!this.state.deviceInfo)
      this.readDevice();
    return (
      <View style={styles.container}>
        {!this.state.currentView ?
          <View style={styles.menu}>
            <Button style={styles.button} title="QRCodeReader" onPress={this.onQRCodeReaderPressed} />
            <Button title="Push Notification" onPress={this.onPushNotificationPressed} />
            <Button title="Push Notification in 5 Seconds" onPress={this.onScheduledPushNotificationPressed} />
            <Text style={{ color: "white" }}>{this.state.deviceInfo}</Text>
          </View>
          :
          <View style={styles.container}>
            {this.state.currentView}
          </View>
        }
      </View>
    );
  };
}

const styles = StyleSheet.create({
  menu: {
    flex: 1,
    flexDirection: 'column',
    backgroundColor: 'black',
    padding: 10,
    alignContent: "center",
  },
  container: {
    flex: 1,
    flexDirection: 'column',
    backgroundColor: 'black',
  },
  preview: {
    flex: 1,
    justifyContent: 'flex-end',
    alignItems: 'center',
  },
  capture: {
    flex: 0,
    backgroundColor: '#fff',
    borderRadius: 5,
    padding: 15,
    paddingHorizontal: 20,
    alignSelf: 'center',
    margin: 20,
  },
});

export default App;
