import 'package:chipchop_buyer/app_localizations.dart';
import 'package:chipchop_buyer/screens/Home/AuthPage.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/services/analytics/analytics.dart';
import 'package:chipchop_buyer/services/utils/constants.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
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
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

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
    Analytics.setupAnalytics(analytics, observer);
    return MaterialApp(
      locale: this.locale,
      title: buyer_app_name,
      theme: ThemeData(
        brightness: Brightness.light,
        // textTheme: TextTheme(
        //   headline5: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
        //   headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
        //   bodyText2: TextStyle(
        //     fontSize: 14.0,
        //     color: CustomColors.white,
        //   ),
        // ),
        textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          )
      ),
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
      navigatorObservers: <NavigatorObserver>[observer],
      home: AuthPage(),
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
