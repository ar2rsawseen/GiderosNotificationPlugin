package com.giderosmobile.android.plugins.notification;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;

import com.google.android.gcm.GCMBaseIntentService;

public class GCMIntentService extends GCMBaseIntentService {

	@Override
	protected void onRegistered(Context context, String registrationId) {
		NotificationClass.onPushRegistration(registrationId);
	}
	
	@Override
	protected void onUnregistered(Context context, String registrationId) {

	}
	
	@Override
	protected void onMessage(Context context, Intent intent){
		Bundle bundle = intent.getExtras();
		if (bundle != null) {
			//get settigns
			SharedPreferences alarmSettings = context.getSharedPreferences("NotificationClassData", Context.MODE_PRIVATE);

			//get notification data
			int id = bundle.getInt("id");
			String title = bundle.getString("title");
			String message = bundle.getString("message");
			String sound = bundle.getString("sound");
			int number = bundle.getInt("number");
			
			//create notification object
			GNotification note = new GNotification();
			if (id != 0) {
				note.id = id;
			}
			if (title != null) {
				note.title = title;
			}
			else
			{
				note.title = alarmSettings.getString("appName", "");
			}
			if (message != null) {
				note.message = message;
			}
			if (sound != null) {
				note.sound = sound;
			}
			if (number != 0) {
				note.number = number;
			}
			note.icon = alarmSettings.getInt("icon", 0);
			note.mainClass = alarmSettings.getString("mainClass", "");
			note.soundPrefix = alarmSettings.getString("pathPrefix", "");
			NotificationClass.dispatch(context, note, true);
		}
	}
	
	@Override
	protected void onError(Context context, String errorId){
		NotificationClass.onPushRegistrationError(errorId);
	}
	
}