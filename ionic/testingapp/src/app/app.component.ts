import { Component, OnInit } from '@angular/core';

import { Platform } from '@ionic/angular';
import { SplashScreen } from '@ionic-native/splash-screen/ngx';
import { StatusBar } from '@ionic-native/status-bar/ngx';



import {
	Plugins,
	PushNotification,
	PushNotificationToken,
	PushNotificationActionPerformed
} from '@capacitor/core';

const { PushNotifications } = Plugins;



@Component({
  selector: 'app-root',
  templateUrl: 'app.component.html',
  styleUrls: ['app.component.scss']
})
export class AppComponent implements OnInit {
  constructor(
    private platform: Platform,
    private splashScreen: SplashScreen,
	private statusBar: StatusBar
  ) {
    this.initializeApp();
  }

  ngOnInit(){
	  console.log('Initializing HomePage');

	  // Request permission to use push notifications
	  // iOS will prompt user and return if they granted permission or not
	  // Android will just grant without prompting
	  PushNotifications.requestPermission().then(result => {
		  if (result.granted) {
			  // Register with Apple / Google to receive push via APNS/FCM
			  PushNotifications.register();
		  } else {
			  // Show some error
		  }
	  });

	  // On success, we should be able to receive notifications
	  PushNotifications.addListener('registration',
		  (token: PushNotificationToken) => {
			  alert('Push registration success, token: ' + token.value);
		  }
	  );

	  // Some issue with our setup and push will not work
	  PushNotifications.addListener('registrationError',
		  (error: any) => {
			  alert('Error on registration: ' + JSON.stringify(error));
		  }
	  );

	  // Show us the notification payload if the app is open on our device
	  PushNotifications.addListener('pushNotificationReceived',
		  (notification: PushNotification) => {
			  alert('Push received: ' + JSON.stringify(notification));
		  }
	  );

	  // Method called when tapping on a notification
	  PushNotifications.addListener('pushNotificationActionPerformed',
		  (notification: PushNotificationActionPerformed) => {
			  alert('Push action performed: ' + JSON.stringify(notification));
		  }
	  );
  }

  initializeApp() {
    this.platform.ready().then(() => {
      this.statusBar.styleDefault();
      this.splashScreen.hide();
    });
  }
}
