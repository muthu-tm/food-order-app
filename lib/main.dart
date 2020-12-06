import 'package:chipchop_buyer/app_localizations.dart';
import 'package:chipchop_buyer/screens/Home/AuthPage.dart';
import 'package:chipchop_buyer/screens/home/LoginPage.dart';
import 'package:chipchop_buyer/screens/home/update_app.dart';
import 'package:chipchop_buyer/services/analytics/analytics.dart';
import 'package:chipchop_buyer/services/controllers/auth/auth_controller.dart';
import 'package:chipchop_buyer/services/utils/constants.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType();

    state.setState(() {
      state._fetchLocale().then((locale) {
        state.locale = locale;
      });
    });
  }
}

class _MyAppState extends State<MyApp> {
  Locale locale;

  @override
  void initState() {
    super.initState();
    this._fetchLocale().then((locale) {
      setState(() {
        this.locale = locale;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: this.locale,
      title: buyer_app_name,
      theme: ThemeData(
          brightness: Brightness.light,
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          )),
      supportedLocales: [
        Locale('en', 'US'),
        Locale('ta', 'IN'),
        Locale('hi', 'IN'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
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

  _fetchLocale() async {
    try {
      var _prefs = await SharedPreferences.getInstance();
      var _language = _prefs.getString("language");

      if (_language == "Tamil") {
        return Locale('ta', 'IN');
      } else if (_language == "Hindi") {
        return Locale('hi', 'IN');
      } else {
        return Locale('en', 'US');
      }
    } catch (e) {
      return Locale('en', 'US');
    }
  }
}
