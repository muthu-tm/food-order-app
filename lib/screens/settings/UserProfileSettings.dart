import 'package:chipchop_buyer/app_localizations.dart';
import 'package:chipchop_buyer/db/models/user.dart';
import 'package:chipchop_buyer/screens/home/AuthPage.dart';
import 'package:chipchop_buyer/screens/settings/UserProfileWidget.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomSnackBar.dart';
import 'package:chipchop_buyer/services/controllers/auth/auth_controller.dart';
import 'package:chipchop_buyer/services/controllers/user/user_controller.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:chipchop_buyer/services/utils/DateUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class UserSetting extends StatefulWidget {
  @override
  _UserSettingState createState() => _UserSettingState();
}

class _UserSettingState extends State<UserSetting> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _pController = TextEditingController();
  final User _user = cachedLocalUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('profile_settings')),
        backgroundColor: CustomColors.mfinBlue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: CustomColors.buyerAlertRed.withOpacity(0.7),
        onPressed: () async {
          await forceDeactivate(context);
        },
        label: Text(
          "DeActivate Account",
          style: TextStyle(
            fontSize: 17,
            fontFamily: "Georgia",
            fontWeight: FontWeight.bold,
            color: CustomColors.buyerWhite,
          ),
        ),
        splashColor: CustomColors.buyerWhite,
        icon: Icon(
          Icons.delete_forever,
          size: 35,
          color: CustomColors.buyerWhite,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              UserProfileWidget(_user),
              Padding(padding: EdgeInsets.only(top: 35, bottom: 35))
            ],
          ),
        ),
      ),
    );
  }

  Future forceDeactivate(BuildContext context) async {
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Confirm!",
            style: TextStyle(
                color: CustomColors.buyerAlertRed,
                fontSize: 20.0,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.start,
          ),
          content: Container(
            height: 225,
            child: Column(
              children: <Widget>[
                Text(
                    "Deactivating account won't remove your Finance Data.\n\nIf you wish to clean all, Deactivate your finance first, please!"),
                Card(
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    obscureText: true,
                    autofocus: false,
                    controller: _pController,
                    decoration: InputDecoration(
                      hintText: 'Secret KEY',
                      fillColor: CustomColors.buyerLightGrey,
                      filled: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              color: CustomColors.mfinBlue,
              child: Text(
                "NO",
                style: TextStyle(
                    color: CustomColors.mfinBlue,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.start,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            FlatButton(
              color: CustomColors.buyerAlertRed,
              child: Text(
                "YES",
                style: TextStyle(
                    color: CustomColors.buyerLightGrey,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.start,
              ),
              onPressed: () async {
                bool isValid = UserController().authCheck(_pController.text);

                if (isValid) {
                  try {
                    await _user.updateByID({
                      'is_active': false,
                      'deactivated_at':
                          DateUtils.getUTCDateEpoch(DateTime.now())
                    }, _user.mobileNumber.toString());
                    await AuthController().signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AuthPage(),
                        settings: RouteSettings(name: '/logout'),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  } catch (err) {
                    Navigator.pop(context);
                    _scaffoldKey.currentState.showSnackBar(
                      CustomSnackBar.errorSnackBar(
                        "Unable to deactivate your account now! Please try again later.",
                        3,
                      ),
                    );
                  }
                } else {
                  _pController.text = "";
                  Navigator.pop(context);
                  _scaffoldKey.currentState.showSnackBar(
                    CustomSnackBar.errorSnackBar(
                      "Failed to Authenticate!",
                      3,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
