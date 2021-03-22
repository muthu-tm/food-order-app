import 'package:flutter/material.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';

class CustomDialogs {
  static information(BuildContext context, String title, Color titleColor,
      String description) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 10.0,
            title: Text(
              title,
              style: TextStyle(
                  color: titleColor,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[Text(description)],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
                style: TextButton.styleFrom(
                  primary: CustomColors.green,
                  backgroundColor: CustomColors.blue,
                ),
              )
            ],
          );
        });
  }

  static actionWaiting(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        barrierColor: CustomColors.lightGrey.withOpacity(0.7),
        builder: (BuildContext context) {
          return Container(
            alignment: Alignment.center,
            width: 50,
            height: 50,
            child: Stack(
              children: <Widget>[
                Container(
                  width: 45,
                  height: 45,
                  alignment: Alignment.center,
                  child: ClipRRect(
                    child: Image.asset(
                      "images/icons/logo.png",
                      height: 35,
                      width: 35,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: SizedBox(
                    width: 45,
                    height: 45,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      backgroundColor: CustomColors.alertRed,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(CustomColors.green),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  static waiting(BuildContext context, String title, String description) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 10.0,
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[Text(description)],
              ),
            ),
          );
        });
  }

  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          key: key,
          elevation: 0,
          contentPadding: EdgeInsets.all(1),
          backgroundColor: Colors.transparent,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              width: 60,
              height: 60,
              child: Stack(
                children: <Widget>[
                  Container(
                    width: 60,
                    height: 60,
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: CustomColors.lightGrey),
                    child: ClipRRect(
                      child: Image.asset(
                        "images/icons/logo.png",
                        height: 35,
                        width: 35,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 7.5,
                    left: 7.5,
                    child: SizedBox(
                      width: 45,
                      height: 45,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        backgroundColor: CustomColors.alertRed,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(CustomColors.green),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  static confirm(BuildContext context, String title, String description,
      Function() yesAction, Function() noAction) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 10.0,
            title: new Text(
              title,
              style: TextStyle(
                  color: CustomColors.alertRed,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  new Container(
                    child: new Text(
                      description,
                      style:
                          TextStyle(color: CustomColors.blue, fontSize: 20.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 10.0,
                  // splashColor: CustomColors.green,
                ),
                child: new Text(
                  'NO',
                  style: TextStyle(color: CustomColors.green, fontSize: 18.0),
                  textAlign: TextAlign.center,
                ),
                onPressed: noAction,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 10.0,
                  // splashColor: CustomColors.alertRed,
                ),
                child: new Text(
                  'YES',
                  style:
                      TextStyle(color: CustomColors.alertRed, fontSize: 18.0),
                  textAlign: TextAlign.center,
                ),
                onPressed: yesAction,
              ),
            ],
          );
        });
  }
}
