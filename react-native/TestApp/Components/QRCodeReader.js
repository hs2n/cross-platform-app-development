/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow strict-local
 */

import React, { Component } from 'react';
import {
  StyleSheet,
  View,
  Button,
  
} from 'react-native';

import { RNCamera } from 'react-native-camera';
import OpenURLButton from './OpenURLButton';


/**
 * this is the view when reading QR Codes
 * properties: 
 * onBackButtonPressed -> callbackfunction that gets executed when the back button is pressed
 */
class QRCodeReader extends Component {
  state = {
    barcodes: []
  }

  barcodeRecognized = ({ barcodes }) => {
    let stateBarcodes = [];
    barcodes.forEach(barcode => {
      if (barcode.type === 'QR_CODE')
        stateBarcodes.push(barcode)
    });
    this.setState({ barcodes: stateBarcodes });
  }

  renderBarcodes = () => (
    <View>
      {this.state.barcodes.map(this.renderBarcode)}
    </View>
  );
  renderBarcode = ({ bounds, data }) => (
    <React.Fragment key={data + bounds.origin.x}>
      <View
        style={{
          borderWidth: 2,
          borderRadius: 10,
          position: 'absolute',
          borderColor: 'black',
          justifyContent: 'center',

          padding: 0,
          ...bounds.size,
          left: bounds.origin.x,
          top: bounds.origin.y,
        }}
      >
        <OpenURLButton url={data}> press me </OpenURLButton>

      </View>
    </React.Fragment>
  );

  render() {
    return (
      <View style={styles.container}>
        <Button onPress={this.props.onBackButtonPressed} title="<-" />
        <RNCamera
          ref={ref => {
            this.camera = ref;
          }}
          style={{
            flex: 1,
            width: '100%',
          }}
          onGoogleVisionBarcodesDetected={this.barcodeRecognized}
        >
          {this.renderBarcodes()}
        </RNCamera>

      </View>
    );
  };
}

const styles = StyleSheet.create({
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

export default QRCodeReader;
