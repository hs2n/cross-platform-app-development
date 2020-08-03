import React, { Component } from 'react';
import {
  StyleSheet,
  View,
  Text,
  Button,
  Alert,
  Platform,
} from 'react-native';

import { getDeviceName, getHardware, getModel, getBatteryLevel, getDeviceId, getManufacturer, isBatteryCharging, getBrand, getBuildNumber } from 'react-native-device-info';

import QRCodeReader from './Components/QRCodeReader';

import { LocalNotification } from './Components/PushNotificationController'

import Auth0 from 'react-native-auth0';
const auth0 = new Auth0({ domain: 'scarcheek.eu.auth0.com', clientId: '9wVcQ3fa6pbfMeWOu5tYnfvKLhTDXHrd' });

/**
 * IMPORTANT INFO:
 * If you want to deploy this app on iOS you have to go to run following commands for it to work
 *  cd ios
 *  pod install
 * OR
 *  npx pod-install
 * hopefully this will work, wasnt able to test it due to the lack of an ios device
 */
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

  login = () => {
    auth0.webAuth
      .authorize({ scope: 'openid email profile' })
      .then(credentials => {
        Alert.alert("Notice", "Login Successful")
        this.setState({
          accessToken: credentials.accessToken
        })
      })
      .catch(error => console.log('ERROR: ' + JSON.stringify(error)));
  }

  logout = () => {
    auth0.webAuth
      .clearSession({})
      .then(success => {
        Alert.alert("Notice",
          'Logged out!'
        );
        this.setState({
          accessToken: null,
          currentView: null
        });
      })
      .catch(error => {
        console.log('Log out cancelled');
      });
  }

  onScheduledPushNotificationPressed = (e) => {
    e.preventDefault();
    console.log("onScheduledPushNotificationPressed")
    LocalNotification.scheduledNotification();
  }

  onBackButtonPressed = (e) => {
    e.stopPropagation();
    this.setState({
      currentView: null
    })
  }

  render() {
    if (!this.state.deviceInfo)
      this.readDevice();

    if (!this.state.accessToken) {
      return (
        <View style={styles.container}>
          <Button onPress={this.login} title="Login"></Button>
        </View>
      )
    } else {
      return (
        <View style={styles.container}>
          {!this.state.currentView ?
            <View style={styles.menu}>
              <Button title="Logout" onPress={this.logout} />
              <Button style={styles.button} title="QRCodeReader" onPress={this.onQRCodeReaderPressed} />
              {
                Platform.OS !== 'ios' &&
                <View>
                  <Button title="Push Notification" onPress={this.onPushNotificationPressed} />
                  <Button title="Push Notification in 5 Seconds" onPress={this.onScheduledPushNotificationPressed} />
                </View>
              }
              <Text style={{ color: "white" }}>{this.state.deviceInfo}</Text>
            </View>
            :
            <View style={styles.container}>
              {this.state.currentView}
            </View>
          }
        </View>
      );
    }


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
