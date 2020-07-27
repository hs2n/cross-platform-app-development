This App is part of the 3-Part Evaluation process and was made with the react-native framework

--ONLY FOLLOW THIS IF YOU WANT TO EXECUTE THE APP ON YOUR IOS DEVICE--

You might have trouble setting up the app for iOS, so you will probably have to reinitialize the project with following commands:

//installs node.js python2 and jdk8 - NOT NECESSARY if you already have this installed
choco install -y nodejs.install python2 jdk8

//Installs the react-native cli needed for setup
npm install -g react-native-cli

react-native init testapp
cd testapp
npm start # you can also use: expo start

//to execute the app 
react-native run-ios

//For further information visit: https://reactnative.dev/docs/0.59/getting-started

After initializing the app you should be able to copy-paste the Components folder and the App.js file to your new project
It will most likely not execute because the config files are not setup yet

If you really want you can setup the components too so camera as well as push notifications work
If so, follow these tutorials: 

https://react-native-community.github.io/react-native-camera/docs/installation
https://github.com/zo0r/react-native-push-notification#installation