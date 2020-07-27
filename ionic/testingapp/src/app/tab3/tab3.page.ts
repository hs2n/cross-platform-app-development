import { Component } from '@angular/core';
import { Plugins } from '@capacitor/core';
const { LocalNotifications } = Plugins;

@Component({
  selector: 'app-tab3',
  templateUrl: 'tab3.page.html',
  styleUrls: ['tab3.page.scss']
})
export class Tab3Page {

  constructor() {}

	notify(){
		this.createPush();
	}

  async createPush(){
	  const notifs = await LocalNotifications.schedule({
		  notifications: [
			  {
				  title: "Hallo!",
				  body: "Diese Nachricht kommt von der App!",
				  id: 1,
				  schedule: { at: new Date(Date.now() + 1000 * 1) },
				  sound: null,
				  attachments: null,
				  actionTypeId: "",
				  extra: null
			  }
		  ]
	  });
  }

}
