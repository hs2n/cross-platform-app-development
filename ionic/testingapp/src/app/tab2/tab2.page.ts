import "@codetrix-studio/capacitor-google-auth";
import { Component } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Plugins } from '@capacitor/core';
import { ToastController } from '@ionic/angular';

@Component({
  selector: 'app-tab2',
  templateUrl: 'tab2.page.html',
  styleUrls: ['tab2.page.scss']
})
export class Tab2Page {
	public loginForm: FormGroup;
	public data: any;

	constructor(public formBuilder: FormBuilder, public toastController: ToastController) {
		this.loginForm = formBuilder.group({
			username: ['', Validators.compose([Validators.maxLength(30), Validators.pattern('[a-zA-Z ]*'), Validators.required])],
			password: ['', Validators.compose([Validators.maxLength(30), Validators.pattern('[a-zA-Z ]*'), Validators.required])]
		});
	}

	save() {
		this.data = JSON.stringify(this.loginForm.value);
	}


	logInGoogle() {
		Plugins.GoogleAuth.signIn().then((result => this.presentToast('SUCCESS! Message: ' + JSON.stringify(result)))).catch(err => 'SUCCESS! Error: ' + JSON.stringify(err));
	}

	logOutGoogle(){
		Plugins.GoogleAuth.signOut().then((result => this.presentToast('SUCCESS! Message: ' + JSON.stringify(result)))).catch(err => 'SUCCESS! Error: ' + JSON.stringify(err));
	}

	async presentToast(message1: string) {
		const toast = await this.toastController.create({
			message: message1,
			duration: 2000
		});
		toast.present();
	}
}
