import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/app_localizations.dart';
import 'package:chipchop_buyer/db/models/user.dart';
import 'package:chipchop_buyer/screens/Home/HomeScreen.dart';
import 'package:chipchop_buyer/screens/Home/LoginPage.dart';
import 'package:chipchop_buyer/screens/Home/MobileSigninPage.dart';
import 'package:chipchop_buyer/screens/Home/update_app.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:chipchop_buyer/screens/utils/CustomSnackBar.dart';
import 'package:chipchop_buyer/services/controllers/auth/auth_controller.dart';
import 'package:chipchop_buyer/services/utils/constants.dart';
import 'package:chipchop_buyer/services/utils/hash_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: CustomColors.lightGrey,
      body: Center(
        child: SingleChildScrollView(
          primary: true,
          child: FutureBuilder<String>(
            future: _prefs.then(
              (SharedPreferences prefs) {
                return (prefs.getString('mobile_number') ?? '');
              },
            ),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data != '') {
                  return FutureBuilder<Map<String, dynamic>>(
                    future: User().getByID(snapshot.data),
                    builder: (BuildContext context,
                        AsyncSnapshot<Map<String, dynamic>> userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.done) {
                        if (userSnapshot.data == null) {
                          return LoginPage(false, _scaffoldKey);
                        } else {
                          User _user = User.fromJson(userSnapshot.data);
                          // return UniquesSignUp(_user, _scaffoldKey);
                          return SecretKeyAuth(_user, _scaffoldKey);
                        }
                      } else if (userSnapshot.hasError) {
                        return LoginPage(false, _scaffoldKey);
                      } else if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Container(
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.30,
                              ),
                              ClipRRect(
                                child: Image.asset(
                                  "images/icons/logo.png",
                                  height: 80,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(5),
                                child: shadowGradientText(buyer_app_name, 16.0),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.35,
                              ),
                              Text(
                                "Serving From",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: CustomColors.grey,
                                  fontSize: 12,
                                  fontFamily: "Georgia",
                                ),
                              ),
                              shadowGradientText("Fourcup Inc.", 20.0),
                            ],
                          ),
                        );
                      } else {
                        return LoginPage(false, _scaffoldKey);
                      }
                    },
                  );
                } else {
                  return LoginPage(false, _scaffoldKey);
                }
              } else if (snapshot.hasError) {
                return LoginPage(false, _scaffoldKey);
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: AsyncWidgets.asyncWaiting(),
                  ),
                );
              } else {
                return LoginPage(false, _scaffoldKey);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget shadowGradientText(String text, double size) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          CustomColors.green,
          CustomColors.blue,
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: CustomColors.white,
          fontSize: size,
          fontFamily: "Georgia",
        ),
      ),
    );
  }
}

class SecretKeyAuth extends StatefulWidget {
  SecretKeyAuth(this._user, this._scaffoldKey);

  final User _user;
  final GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  _SecretKeyAuthState createState() => _SecretKeyAuthState();
}

class _SecretKeyAuthState extends State<SecretKeyAuth> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  TextEditingController _pController = TextEditingController();
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();

    if (widget._user.preferences.isfingerAuthEnabled) biometric();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.85,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: widget._user.getProfilePicPath() == ""
                        ? Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: CustomColors.lightGreen,
                                  style: BorderStyle.solid,
                                  width: 2.0),
                            ),
                            child: Icon(
                              Icons.person,
                              size: 45.0,
                              color: CustomColors.blue,
                            ),
                          )
                        : SizedBox(
                            width: 100.0,
                            height: 100.0,
                            child: Center(
                              child: CachedNetworkImage(
                                imageUrl: widget._user.getMediumProfilePicPath(),
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
                  SizedBox(height: 15,),
                  Text(
                    widget._user.firstName,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: CustomColors.blue,
                    ),
                  ),
                  Text(
                    widget._user.mobileNumber.toString(),
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: CustomColors.blue,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 5, right: 5, bottom: 5),
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(4),
                      ],
                      obscureText: true,
                      autofocus: false,
                      controller: _pController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      (widget._user.preferences.isfingerAuthEnabled)
                          ? FlatButton(
                              onPressed: () async {
                                await biometric();
                              },
                              child: Text(
                                "Fingerprint",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: CustomColors.grey,
                                  fontSize: 11.0,
                                ),
                              ),
                            )
                          : Container(),
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  LoginPage(true, widget._scaffoldKey),
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
                  SizedBox(
                    height: 40,
                    width: 100,
                    child: RaisedButton(
                      color: CustomColors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      onPressed: () {
                        _submit(widget._user);
                      },
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context).translate('login'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: 'Georgia',
                            color: CustomColors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context).translate('no_account'),
                    style: TextStyle(
                      fontSize: 13.0,
                      fontFamily: 'Georgia',
                      fontWeight: FontWeight.bold,
                      color: CustomColors.alertRed.withOpacity(0.7),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) => MobileSignInPage(),
                          settings: RouteSettings(name: '/signup'),
                        ),
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context).translate('sign_up'),
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: CustomColors.positiveGreen,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
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
            await login(widget._user);
          } else {
            widget._scaffoldKey.currentState.showSnackBar(
              CustomSnackBar.errorSnackBar(
                  "Unable to use FingerPrint Login. Please LOGIN using Secret KEY!",
                  2),
            );
            return;
          }
        } else {
          widget._scaffoldKey.currentState.showSnackBar(
            CustomSnackBar.errorSnackBar(
                "Unable to use FingerPrint Login. Please LOGIN using Secret KEY!",
                2),
          );
          return;
        }
      }
    } catch (e) {
      widget._scaffoldKey.currentState.showSnackBar(
        CustomSnackBar.errorSnackBar(
            "Unable to use FingerPrint Login. Please LOGIN using Secret KEY!",
            2),
      );
    }
  }

  login(User _user) async {
    CustomDialogs.showLoadingDialog(context, _keyLoader);

    var result = await _authController.signInWithMobileNumber(_user);

    if (!result['is_success']) {
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      widget._scaffoldKey.currentState.showSnackBar(
          CustomSnackBar.errorSnackBar(
              AppLocalizations.of(context).translate('unable_to_login'), 2));
      widget._scaffoldKey.currentState
          .showSnackBar(CustomSnackBar.errorSnackBar(result['message'], 2));
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) => UpdateApp(
            child: HomeScreen(),
          ),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _submit(User _user) async {
    if (_pController.text.length == 0) {
      widget._scaffoldKey.currentState.showSnackBar(
          CustomSnackBar.errorSnackBar(
              AppLocalizations.of(context).translate('your_secret_key'), 2));
      return;
    } else {
      String hashKey = HashGenerator.hmacGenerator(_pController.text,
          _user.countryCode.toString() + _user.mobileNumber.toString());
      if (hashKey != _user.password) {
        widget._scaffoldKey.currentState.showSnackBar(
            CustomSnackBar.errorSnackBar(
                AppLocalizations.of(context).translate('wrong_secret_key'), 2));
        return;
      } else {
        await login(_user);
      }
    }
  }
}
