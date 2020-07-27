import React, { useCallback } from "react";
import { Alert, Button, Linking, StyleSheet, View, Text, TouchableOpacity } from "react-native";

const supportedURL = "https://google.com";

const unsupportedURL = "slack://open?team=123456";

const OpenURLButton = ({ url, children }) => {
  const handlePress = useCallback(async () => {
    // Checking if the link is supported for links with custom URL scheme.
    const supported = await Linking.canOpenURL(url);

    if (supported) {
      // Opening the link with some app, if the URL scheme is "http" the web link should be opened
      // by some browser in the mobile
      await Linking.openURL(url);
    } else {
      Alert.alert(`Don't know how to open this URL: ${url}`);
    }
  }, [url]);
  return <TouchableOpacity style={{backgroundColor: 'rgba(255, 255, 255, 0.9)', justifyContent: "center", height: '100%', padding: 0}} onPress={handlePress }>
  <Text>{children}</Text>
</TouchableOpacity>
};


const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: "center", alignItems: "center" },
});

export default OpenURLButton;
