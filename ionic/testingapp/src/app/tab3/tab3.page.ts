import 'capacitor-secure-storage-plugin';
import { Plugins } from '@capacitor/core';
import { Component } from '@angular/core';
const { SecureStoragePlugin } = Plugins;
import { ToastController } from '@ionic/angular';
const key = "secretValue";

@Component({
  selector: 'app-tab3',
  templateUrl: 'tab3.page.html',
  styleUrls: ['tab3.page.scss']
})
export class Tab3Page {
  public secretData : string;
  public hasData : boolean;
	constructor(public toastController: ToastController) {
		this.load()
		.then((value: string) => {this.secretData = value; this.hasData = true; console.log(value)})
		.catch((err) => {this.secretData = undefined; this.hasData = false; console.log(err)});
  }
  action(){
	if(!this.hasData && this.secretData.length > 0){
		console.log(this.secretData);
		this.save(this.secretData)
			.then((value) => {this.presentToast("Key saved!"); console.log(value)});
		this.hasData = true;
	}else if(this.hasData){
		this.hasData = false;
		this.secretData = undefined;
		this.clear();
		this.presentToast("Key cleared!");
	}
  }

  async presentToast(message1 : string){
	  const toast = await this.toastController.create({
		  message: message1,
		  duration: 2000
	  });
	  toast.present();
  }

  async clear() : Promise<boolean>{
	return await SecureStoragePlugin.clear();
  }

  async load() : Promise<string>{
	return (await SecureStoragePlugin.get({key})).value;
  }

  async save(value : string) : Promise<boolean>{
	  console.log({ key, value });
	  return await SecureStoragePlugin.set({ key, value });
  }

}
