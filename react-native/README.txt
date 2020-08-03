This App is part of the 3-Part Evaluation process and was made with the react-native framework

Execute the following 2 commands before trying to start the app:
	npm install
	yarn install
and you should be good to go on andorid

for iOS follow these extra steps:

#THIS PART IS REQUIRED FOR USAGE ON IOS DEVICES - IGNORE IF YOU WANT TO DEPLOY THE APP ON ANDROID
Pretty much all steps have been done for you, but when using iOS you still have to follow these steps:
first run following command:

	run npx pod-install

Go into your TestApp/ios dir and open QRReaderExample.xcworkspace workspace. Select the top project "QRReaderExample" and select the "Signing & Capabilities" tab. 
Add a 2 new Capabilities using "+" button:

	Background Mode capability and tick Remote Notifications.
	Push Notifications capability

I would recommend running 'pod install' inside the ios folder after youre done to ensure all packages are linked and installed

after that you can execute following command:

	npx react-native run-ios

to run the app on your ios device