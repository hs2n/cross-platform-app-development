import PushNotification from 'react-native-push-notification'

PushNotification.configure({
  // (required) Called when a remote or local notification is opened or received
  onNotification: function(notification) {
    console.log('LOCAL NOTIFICATION ==>', notification)
  },
  popInitialNotification: true,
  //This prevents an Firebase not initialized error
  requestPermissions: true
});

//For some odd reason you have to differentiate between instantNotification and scheduledNotification even though you have to set a date prop in PushNotification.localNotificationSchedule()
export const LocalNotification = {
  instantNotification: () => {
    PushNotification.localNotification({
      autoCancel: true,
      bigText:
        'This is local notification demo in React Native app. Only shown, when expanded.',
      subText: 'Local Notification Demo',
      title: 'Local Notification Title',
      message: 'Expand me to see more',
      vibrate: true,
      vibration: 300,
      playSound: true,
      soundName: 'default',
      actions: '["Okay", "Cool"]'
    })
  },
  
  scheduledNotification: (delay) => {
    PushNotification.localNotificationSchedule({
      autoCancel: true,
      bigText:
        'This is scheduled notification demo in React Native app. Only shown, when expanded.',
      subText: 'Scheduled Notification Demo',
      title: 'Scheduled Notification Title',
      message: 'Expand me to see more',
      vibrate: true,
      vibration: 300,
      playSound: true,
      soundName: 'default',
      actions: '["Okay", "Cool"]',
      date: new Date(Date.now() + (delay ? delay : 5) * 1000),
    })
  }
} 
