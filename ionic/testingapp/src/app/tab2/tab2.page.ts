import { Component } from '@angular/core';
import { Plugins } from '@capacitor/core';
const { Device } = Plugins;

@Component({
  selector: 'app-tab2',
  templateUrl: 'tab2.page.html',
  styleUrls: ['tab2.page.scss']
})
export class Tab2Page {
	data: any;
  constructor() {
	  Device.getInfo().then(info => this.data = Object.keys(info).map(key => this.createDataObject(key, info[key])));
  }

  createDataObject(name1, info1){
	  return {
		  name : name1,
		  info : info1
	  }
  }

}
