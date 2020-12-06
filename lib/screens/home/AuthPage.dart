import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/app_localizations.dart';
import 'package:chipchop_buyer/db/models/user.dart';
import 'package:chipchop_buyer/screens/Home/LoginPage.dart';
import 'package:chipchop_buyer/screens/Home/MobileSigninPage.dart';
import 'package:chipchop_buyer/screens/Home/update_app.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:chipchop_buyer/screens/utils/CustomSnackBar.dart';
import 'package:chipchop_buyer/screens/utils/url_launcher_utils.dart';
import 'package:chipchop_buyer/services/analytics/analytics.dart';
import 'package:chipchop_buyer/services/controllers/auth/auth_controller.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:chipchop_buyer/services/utils/hash_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  AuthPage(this.userID, this.userName, this.userImage);

  final String userImage;
  final String userName;
  final String userID;

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  TextEditingController _pController = TextEditingController();
  final AuthController _authController = AuthController();

  bool _rememberUser = true;
  bool _radioValue = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: CustomColors.lightGrey,
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "From ",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CustomColors.black,
            ),
          ),
          InkWell(
            onTap: () {
              UrlLauncherUtils.launchURL('https://www.fourcup.com');
            },
            child: Text(
              " Fourcup Inc.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CustomColors.blue,
              ),
            ),
          ),
        ],
      ),
      extendBody: true,
      body: SingleChildScrollView(
        primary: true,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffD8F2A7), Color(0xffA4D649)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    child: Image.asset(
                      "images/icons/logo.png",
                      height: 80,
                    ),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          "UNIQUES",
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "OLED",
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        "Buy Food, Vegetables & Groceries",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                child: Flexible(
                  child: widget.userImage == ""
                      ? Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: CustomColors.alertRed,
                                style: BorderStyle.solid,
                                width: 2.0),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 45.0,
                            color: CustomColors.lightGrey,
                          ),
                        )
                      : SizedBox(
                          width: 100.0,
                          height: 100.0,
                          child: Center(
                            child: CachedNetworkImage(
                              imageUrl: widget.userImage,
                              imageBuilder: (context, imageProvider) =>
                                  CircleAvatar(
                                radius: 45.0,
                                backgroundImage: imageProvider,
                                backgroundColor: Colors.transparent,
                              ),
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) =>
                                      CircularProgressIndicator(
                                          value: downloadProgress.progress),
                              errorWidget: (context, url, error) => Icon(
                                Icons.error,
                                size: 35,
                              ),
                              fadeOutDuration: Duration(seconds: 1),
                              fadeInDuration: Duration(seconds: 2),
                            ),
                          ),
                        ),
                ),
              ),
              Text(
                widget.userName,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  color: CustomColors.blue,
                ),
              ),
              Text(
                widget.userID,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  color: CustomColors.blue,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                ),
                child: TextFormField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  autofocus: false,
                  controller: _pController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                    hintText:
                        AppLocalizations.of(context).translate('secret_key'),
                    fillColor: CustomColors.white,
                    filled: true,
                    contentPadding: EdgeInsets.all(14),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) => LoginPage(),
                        ),
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context).translate('forget_key'),
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: CustomColors.alertRed,
                        fontSize: 11.0,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Radio(
                        value: _radioValue,
                        groupValue: _rememberUser,
                        activeColor: CustomColors.alertRed,
                        toggleable: true,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _rememberUser = true;
                            });
                          } else {
                            setState(() {
                              _rememberUser = false;
                            });
                          }
                        },
                      ),
                      Text(
                        'Remember Me',
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                    width: 150,
                    child: RaisedButton(
                      color: CustomColors.alertRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(5),
                        ),
                      ),
                      onPressed: () {
                        _submit(widget.userID);
                      },
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context).translate('login'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18.0,
                            color: CustomColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      AppLocalizations.of(context).translate('no_account'),
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                        color: CustomColors.alertRed.withOpacity(0.7),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                MobileSignInPage(),
                            settings: RouteSettings(name: '/signup'),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context).translate('sign_up'),
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: CustomColors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  biometric() async {
    final LocalAuthentication auth = LocalAuthentication();
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      if (canCheckBiometrics) {
        List<BiometricType> availableBiometrics;
        availableBiometrics = await auth.getAvailableBiometrics();

        if (availableBiometrics.isNotEmpty) {
          bool authenticated = await auth.authenticateWithBiometrics(
              localizedReason: 'Touch your finger on the sensor to login',
              useErrorDialogs: true,
              sensitiveTransaction: true,
              stickyAuth: true);
          if (authenticated) {
            await login(widget.userID);
          } else {
            _scaffoldKey.currentState.showSnackBar(
              CustomSnackBar.errorSnackBar(
                  "Unable to use FingerPrint Login. Please LOGIN using Secret KEY!",
                  2),
            );
            return;
          }
        } else {
          _scaffoldKey.currentState.showSnackBar(
            CustomSnackBar.errorSnackBar(
                "Unable to use FingerPrint Login. Please LOGIN using Secret KEY!",
                2),
          );
          return;
        }
      }
    } catch (e) {
      _scaffoldKey.currentState.showSnackBar(
        CustomSnackBar.errorSnackBar(
            "Unable to use FingerPrint Login. Please LOGIN using Secret KEY!",
            2),
      );
    }
  }

  login(String _userID) async {
    CustomDialogs.showLoadingDialog(context, _keyLoader);

    var result = await _authController.signInWithMobileNumber(_userID);

    if (!result['is_success']) {
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      _scaffoldKey.currentState.showSnackBar(CustomSnackBar.errorSnackBar(
          AppLocalizations.of(context).translate('unable_to_login'), 2));
      _scaffoldKey.currentState
          .showSnackBar(CustomSnackBar.errorSnackBar(result['message'], 2));
    } else {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(
          "user_profile_pic", cachedLocalUser.getSmallProfilePicPath());
      prefs.setString("user_name",
          cachedLocalUser.firstName + " " + cachedLocalUser.lastName ?? "");
      if (_rememberUser) {
        prefs.setBool('user_session_live', true);
      } else {
        prefs.setBool('user_session_live', false);
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) => UpdateApp(),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _submit(String _userID) async {
    if (_pController.text.length == 0) {
      _scaffoldKey.currentState.showSnackBar(CustomSnackBar.errorSnackBar(
          AppLocalizations.of(context).translate('your_secret_key'), 2));
      return;
    } else {
      try {
        Map<String, dynamic> _userData = await User().getByID(_userID);
        User _user = User.fromJson(_userData);

        String hashKey =
            HashGenerator.hmacGenerator(_pController.text, _user.getID());
        if (hashKey != _user.password) {
          _scaffoldKey.currentState.showSnackBar(CustomSnackBar.errorSnackBar(
              AppLocalizations.of(context).translate('wrong_secret_key'), 2));
          return;
        } else {
          await login(_userID);
        }
      } catch (err) {
        Analytics.reportError({
          "type": 'log_in_error',
          "user_id": _userID,
          'name': widget.userName,
          'error': err.toString()
        }, 'log_in');
        _scaffoldKey.currentState.showSnackBar(
            CustomSnackBar.errorSnackBar("Sorry, Unable to Login now!", 2));
      }
    }
  }
}
