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
        title: Text(
          AppLocalizations.of(context).translate('profile_settings'),
          textAlign: TextAlign.start,
          style: TextStyle(color: CustomColors.black, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: CustomColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: CustomColors.green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: CustomColors.alertRed,
        onPressed: () async {
          await forceDeactivate(context);
        },
        label: Text(
          "DeActivate Account",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: CustomColors.white,
          ),
        ),
        splashColor: CustomColors.white,
        icon: Icon(
          Icons.delete_forever,
          size: 35,
          color: CustomColors.white,
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
    _pController.text = "";

    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Confirm!",
            style: TextStyle(
                color: CustomColors.alertRed,
                fontSize: 20.0,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.start,
          ),
          content: Container(
            height: 200,
            child: Column(
              children: <Widget>[
                Text(
                    "Deactivating account won't remove your details immediatly.\n\nWe will notify you before cleaning your details!"),
                Expanded(
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    obscureText: true,
                    autofocus: false,
                    controller: _pController,
                    decoration: InputDecoration(
                      hintText: 'Secret KEY',
                      fillColor: CustomColors.lightGrey,
                      filled: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
                color: CustomColors.green,
                child: Text(
                  "NO",
                  style: TextStyle(
                      color: CustomColors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
                onPressed: () {
                  _pController.text = "";
                  Navigator.pop(context);
                }),
            FlatButton(
              color: CustomColors.alertRed,
              child: Text(
                "YES",
                style: TextStyle(
                    color: CustomColors.lightGrey,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.start,
              ),
              onPressed: () async {
                bool isValid = UserController().authCheck(_pController.text);

                if (isValid) {
                  try {
                    await cachedLocalUser.updateByID({
                      'is_active': false,
                      'deactivated_at':
                          DateUtils.getUTCDateEpoch(DateTime.now())
                    }, cachedLocalUser.getID());
                    await AuthController().signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AuthPage(
                            cachedLocalUser.getID(),
                            cachedLocalUser.firstName +
                                    ' ' +
                                    cachedLocalUser.lastName ??
                                "",
                            cachedLocalUser.getSmallProfilePicPath()),
                        settings: RouteSettings(name: '/logout'),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  } catch (err) {
                    _pController.text = "";
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
