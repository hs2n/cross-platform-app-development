import { Component } from '@angular/core';
import { BarcodeScanner } from '@ionic-native/barcode-scanner/ngx';
import { Plugins } from '@capacitor/core';
const { LocalNotifications, Device } = Plugins;

@Component({
  selector: 'app-tab1',
  templateUrl: 'tab1.page.html',
  styleUrls: ['tab1.page.scss']
})
export class Tab1Page {
	androidInfos: object;
	data: any;
	constructor(private barcodeScanner: BarcodeScanner) {
		Device.getInfo().then(info => this.androidInfos = Object.keys(info).map(key => this.createDataObject(key, info[key])));
	}

	createDataObject(name1, info1) {
		return {
			name: name1,
			info: info1
		}
	}

	scan() {
		this.data = null;
		this.barcodeScanner.scan().then(barcodeData => {
			console.log('Barcode data', barcodeData);
			this.data = barcodeData;
		}).catch(err => {
			console.log('Error', err);
		});
	}

	notify(time: number) {
		this.createPush(time);
	}

	async createPush(time: number) {
		const notifs = await LocalNotifications.schedule({
			notifications: [
				{
					title: "Hallo!",
					body: "Diese Nachricht kommt nach " + time + " sekunden von der App!",
					id: 1,
					schedule: { at: new Date(Date.now() + 1000 * time) },
					sound: null,
					attachments: null,
					actionTypeId: "",
					extra: null
				}
			]
		});
	}

}
