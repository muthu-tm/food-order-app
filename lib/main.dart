import 'package:chipchop_buyer/screens/Home/AuthPage.dart';
import 'package:chipchop_buyer/screens/home/LoginPage.dart';
import 'package:chipchop_buyer/screens/home/update_app.dart';
import 'package:chipchop_buyer/services/analytics/analytics.dart';
import 'package:chipchop_buyer/services/controllers/auth/auth_controller.dart';
import 'package:chipchop_buyer/services/utils/constants.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userID = prefs.getString('mobile_number') ?? "";
  String userName = prefs.getString('user_name') ?? "";
  String userImage = prefs.getString('user_profile_pic') ?? "";
  bool isLive = prefs.getBool('user_session_live') ?? false;
  FirebaseAnalytics analytics = FirebaseAnalytics();
  FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  Analytics.setupAnalytics(analytics, observer);
  if (isLive && userID != "") {
    try {
      dynamic result = await AuthController().signInWithMobileNumber(userID);

      if (!result['is_success']) {
        runApp(MyApp(observer, userID, userName, userImage, false));
      } else {
        runApp(MyApp(observer, userID, userName, userImage, true));
      }
    } catch (err) {
      runApp(MyApp(observer, userID, userName, userImage, false));
    }
  } else {
    runApp(MyApp(observer, userID, userName, userImage, false));
  }
}

class MyApp extends StatefulWidget {
  MyApp(this.observer, this.userID, this.userName, this.userImage, this.isLive);

  final FirebaseAnalyticsObserver observer;
  final bool isLive;
  final String userImage;
  final String userName;
  final String userID;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale locale;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: buyer_app_name,
      theme: ThemeData(
          brightness: Brightness.light,
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          )),
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode &&
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      navigatorObservers: <NavigatorObserver>[widget.observer],
      home: widget.isLive
          ? UpdateApp()
          : (widget.userID != "")
              ? AuthPage(widget.userID, widget.userName, widget.userImage)
              : LoginPage(),
    );
  }
}
