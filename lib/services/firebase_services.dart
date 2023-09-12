import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:sno_biz_app/app_route/app_route.dart';
import 'package:sno_biz_app/screens/chats/chat_screen.dart';
import 'dart:developer';

import '../main.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class FirebaseServices {
  final _firebaseMessaging = FirebaseMessaging.instance;
  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    // final String? payload = notificationResponse.payload;
    // if (notificationResponse.payload != null) {}
  }
  var bigTextStyleInformation;
  Future initLocalNotifications() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/sno_biz_logo');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // handleMessage(message);
      RemoteNotification? notification = message.notification;

      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        print(notification.toString() + ' notification recived object');
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              styleInformation: BigTextStyleInformation(''),

              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: '@drawable/sno_biz_logo',
            ),
          ),
        );
      }
    });
  }

  Future initPushNotifications() async {
    log("initPushNotifications function call");

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> initNotifications() async {
    log("init notification  \n");
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );

    log('User granted permission: ${settings.authorizationStatus}');
    initLocalNotifications();
    initPushNotifications();
  }

  void handleMessage(RemoteMessage? message) async {
    if (message == null) return;
    log(message!.data.toString() + " testing r");
    log(message!.data["mode"].toString() + " mode");

    if (message.data["mode"].toString().isNotEmpty) {
      String id = message.data["id"];
      switch (message.data["mode"]) {
        case "ticket":
          {
            nextPage(
                navigatorKey.currentState!.context,
                ChatScreen(
                  data: message.data,
                  fromNotification: true,
                  updateReadFlag: true,
                ));

            break;
          }

        case "myTicket":
          {
            nextPage(
                navigatorKey.currentState!.context,
                ChatScreen(
                    data: message.data,
                    fromNotification: true,
                    updateReadFlag: true));

            break;
          }
        case "chat":
          {
            nextPage(
                navigatorKey.currentState!.context,
                ChatScreen(
                    data: message.data,
                    fromNotification: true,
                    updateReadFlag: true));

            break;
          }
      }
    }
  }
}
