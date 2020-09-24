import 'package:chipchop_buyer/screens/utils/ColorLoader.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/GradientText.dart';
import 'package:flutter/material.dart';

class AsyncWidgets {
  static asyncWaiting(
      {dotOneColor = CustomColors.alertRed,
      dotTwoColor = CustomColors.green,
      dotThreeColor = CustomColors.lightBlue}) {
    return <Widget>[
      ColorLoader(
        dotOneColor: dotOneColor,
        dotTwoColor: dotTwoColor,
        dotThreeColor: dotThreeColor,
        dotIcon: Icon(Icons.adjust),
      ),
      GradientText(
        'Loading...',
        size: 18.0,
        gradient: LinearGradient(
          colors: [
            CustomColors.blue,
            CustomColors.green,
          ],
        ),
      ),
    ];
  }

  static asyncError() {
    return <Widget>[
      Icon(
        Icons.error_outline,
        color: CustomColors.alertRed,
        size: 60,
      ),
      Text(
        'Unable to load, Error!',
        style: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.bold,
            color: CustomColors.alertRed),
      ),
    ];
  }
}
