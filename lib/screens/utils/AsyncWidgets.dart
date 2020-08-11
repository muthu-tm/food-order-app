import 'package:chipchop_buyer/screens/utils/ColorLoader.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/GradientText.dart';
import 'package:flutter/material.dart';

class AsyncWidgets {
  static asyncWaiting(
      {dotOneColor = CustomColors.buyerAlertRed,
      dotTwoColor = CustomColors.mfinButtonGreen,
      dotThreeColor = CustomColors.mfinLightBlue}) {
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
            CustomColors.mfinBlue,
            CustomColors.mfinButtonGreen,
          ],
        ),
      ),
    ];
  }

  static asyncError() {
    return <Widget>[
      Icon(
        Icons.error_outline,
        color: CustomColors.buyerAlertRed,
        size: 60,
      ),
      Text(
        'Unable to load, Error!',
        style: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.bold,
            color: CustomColors.buyerAlertRed),
      ),
    ];
  }
}
