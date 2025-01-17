import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:plasco/services/constants.dart';
import 'package:plasco/views/auth/EnterNoWidget.dart';
import 'package:plasco/views/main/MainPageWidget.dart';
import 'package:plasco/views/splash.dart';

import 'locator.dart';


const AndroidNotificationChannel  channel = const AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
);

/// Initialize the [FlutterLocalNotificationsPlugin] package.
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin=FlutterLocalNotificationsPlugin();
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  var notification = message.data;

  if (notification != null   ) {
    if(!kIsWeb){
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification['title'],
          notification['body'],
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,

              icon: 'notification_icon',
            ),
          ));
    }else{

    }

  }
}

Widget _defaultHome;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupLocator();




  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.white, // navigation bar color
    statusBarColor: Colors.white, // status bar color
    statusBarIconBrightness: Brightness.dark, // status bar icon color
    systemNavigationBarIconBrightness:
        Brightness.dark, // color of navigation controls
  ));




  await Firebase.initializeApp();
  if (!kIsWeb) {
    /*channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      'This channel is used for important notifications.', // description
      importance: Importance.high,
    );*/

    // flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    var notification = message.data;
    //AndroidNotification android = message.notification?.android;
    if (notification != null  ) {
      if( !kIsWeb){
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification['title'],
            notification['body'],
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,

                icon: 'notification_icon',
              ),
            ));
      }else{

      }

    }
  });


  locator<Constants>().getData().then((loggedIn) async {
    _defaultHome = EnterNoWidget();

    if (loggedIn) {
      _defaultHome = MainPageWidget();
    }
    runApp(MyApp());
  });
}
//final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Map<int, Color> color = {
      50: Color.fromRGBO(20, 56, 92, .1),
      100: Color.fromRGBO(20, 56, 92, .2),
      200: Color.fromRGBO(20, 56, 92, .3),
      300: Color.fromRGBO(20, 56, 92, .4),
      400: Color.fromRGBO(20, 56, 92, .5),
      500: Color.fromRGBO(20, 56, 92, .6),
      600: Color.fromRGBO(20, 56, 92, .7),
      700: Color.fromRGBO(20, 56, 92, .8),
      800: Color.fromRGBO(20, 56, 92, .9),
      900: Color.fromRGBO(20, 56, 92, 1),
    };
    MaterialColor colorCustom = MaterialColor(0xFF14385C, color);
    /* return MaterialApp(
      title: 'Plasco',
      theme: ThemeData(
          primarySwatch: colorCustom,
          unselectedWidgetColor: ColorPalette.Gray2,
          canvasColor: Colors.transparent),
      home: EnterNoWidget(),debugShowCheckedModeBanner: false,
    );*/
    return FutureBuilder(
      // Replace the 3 second delay with your initialization code:
      future: Future.delayed(Duration(seconds: 3)),
      builder: (context, AsyncSnapshot snapshot) {
        // Show splash screen while waiting for app resources to load:
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            //scaffoldMessengerKey: rootScaffoldMessengerKey,
            home: Splash(), debugShowCheckedModeBanner: false,
          );
        } else {
          // Loading is done, return the app:
          return MaterialApp(
              //scaffoldMessengerKey: rootScaffoldMessengerKey,
              title: 'Plasco',
              theme: ThemeData(
                primarySwatch: colorCustom,
              ),
              home: _defaultHome,
              debugShowCheckedModeBanner: false);
        }
      },
    );
  }
}
