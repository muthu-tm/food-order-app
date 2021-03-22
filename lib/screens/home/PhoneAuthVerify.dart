import 'dart:async';

import 'package:chipchop_buyer/db/models/user.dart' as u;
import 'package:chipchop_buyer/screens/utils/url_launcher_utils.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:chipchop_buyer/screens/home/update_app.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:chipchop_buyer/screens/utils/CustomSnackBar.dart';
import 'package:chipchop_buyer/services/controllers/auth/auth_controller.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chipchop_buyer/app_localizations.dart';

class PhoneAuthVerify extends StatefulWidget {
  PhoneAuthVerify(
      this._rememberUser,
      this.isRegister,
      this.number,
      this.countryCode,
      this.passKey,
      this.name,
      this.lastName,
      this.verificationID,
      this.forceResendingToken);

  final bool _rememberUser;
  final bool isRegister;
  final String number;
  final int countryCode;
  final String passKey;
  final String name;
  final String lastName;
  final String verificationID;
  final forceResendingToken;

  @override
  _PhoneAuthVerifyState createState() => _PhoneAuthVerifyState();
}

class _PhoneAuthVerifyState extends State<PhoneAuthVerify> {
  TextEditingController textEditingController = TextEditingController();
  String currentText = "";
  StreamController<ErrorAnimationType> errorController;

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final AuthController _authController = AuthController();
  u.User _user;

  @override
  void initState() {
    super.initState();
    startTimer();

    errorController = StreamController<ErrorAnimationType>();
  }

  int resendSMSCount = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Timer _timer;
  int _start = 30;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();

    errorController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffD8F2A7), Color(0xffA4D649)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
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
                SizedBox(
                  height: 20,
                ),
                _getPinFields(),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 40,
                      width: 150,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 16.0,
                          primary: CustomColors.alertRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(5),
                            ),
                          ),
                        ),
                        onPressed: signIn,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            AppLocalizations.of(context).translate('verify'),
                            style: TextStyle(
                              color: CustomColors.white,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getPinFields() => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 5),
            child: RichText(
              text: TextSpan(
                text: "Enter the code sent to ",
                children: [
                  TextSpan(
                    text: '+91 ${widget.number}',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ],
                style: TextStyle(color: Colors.black54, fontSize: 15),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 30),
            child: PinCodeTextField(
              appContext: context,
              pastedTextStyle: TextStyle(
                color: Colors.green.shade600,
                fontWeight: FontWeight.bold,
              ),
              length: 6,
              obscureText: false,
              obscuringCharacter: '*',
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                  fieldHeight: 45,
                  fieldWidth: 40,
                  activeFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                  inactiveFillColor: Colors.grey[300]),
              cursorColor: Colors.black,
              animationDuration: Duration(milliseconds: 300),
              errorAnimationController: errorController,
              textStyle: TextStyle(fontSize: 17, height: 1.6),
              enableActiveFill: true,
              backgroundColor: Colors.transparent,
              controller: textEditingController,
              keyboardType: TextInputType.number,
              boxShadows: [
                BoxShadow(
                  offset: Offset(0, 1),
                  color: Colors.black12,
                  blurRadius: 10,
                )
              ],
              onChanged: (value) {
                setState(() {
                  currentText = value;
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(width: 16.0),
              _start != 0
                  ? Text("Resend OTP in $_start sec")
                  : resendSMSCount < 1
                      ? Flexible(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "I didn't receive the code, ",
                                  style: TextStyle(
                                      color: CustomColors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                                TextSpan(
                                  text: 'RESEND',
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      _verifyPhoneNumber();
                                    },
                                  style: TextStyle(
                                      color: CustomColors.alertRed,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(),
              SizedBox(width: 16.0),
            ],
          ),
          SizedBox(height: 20.0),
        ],
      );

  _verifyPhoneNumber() async {
    String phoneNumber = '+' + widget.countryCode.toString() + widget.number;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.verifyPhoneNumber(
        forceResendingToken: widget.forceResendingToken,
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 0),
        verificationCompleted: (authCredential) =>
            _verificationComplete(authCredential, context),
        verificationFailed: (authException) =>
            _verificationFailed(authException, context),
        codeAutoRetrievalTimeout: (verificationId) =>
            _codeAutoRetrievalTimeout(verificationId),
        codeSent: (verificationId, [code]) =>
            _smsCodeSent(verificationId, [code]));
  }

  _verificationComplete(
      AuthCredential authCredential, BuildContext context) async {
    FirebaseAuth.instance
        .signInWithCredential(authCredential)
        .then((UserCredential authResult) async {
      final SharedPreferences prefs = await _prefs;

      var result = await _authController.signInWithMobileNumber(_user.getID());

      if (!result['is_success']) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar.errorSnackBar(
            AppLocalizations.of(context).translate('unable_to_login'), 2));
        ScaffoldMessenger.of(context)
            .showSnackBar(CustomSnackBar.errorSnackBar(result['message'], 2));
      } else {
        if (widget._rememberUser) {
          prefs.setBool('user_session_live', true);
        } else {
          prefs.setBool('user_session_live', false);
        }
        prefs.setString(
            "user_profile_pic", cachedLocalUser.getSmallProfilePicPath());
        prefs.setString("user_name",
            cachedLocalUser.firstName + " " + cachedLocalUser.lastName ?? "");
        prefs.setString("mobile_number", cachedLocalUser.getID());

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) => UpdateApp(),
          ),
          (Route<dynamic> route) => false,
        );
      }
    }).catchError((error) {
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar.errorSnackBar(
          AppLocalizations.of(context).translate('try_later'), 2));
    });
  }

  _smsCodeSent(String verificationId, [code]) {
    ScaffoldMessenger.of(context)
        .showSnackBar(CustomSnackBar.successSnackBar("OTP sent", 1));
    setState(() {
      resendSMSCount = resendSMSCount + 1;
    });
    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    CustomDialogs.showLoadingDialog(context, _keyLoader);
  }

  _verificationFailed(dynamic authException, BuildContext context) {
    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar.errorSnackBar(
        AppLocalizations.of(context).translate('verification_failed') +
            authException.message.toString(),
        2));
  }

  _codeAutoRetrievalTimeout(String verificationId) {}

  signIn() {
    if (currentText.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar.errorSnackBar(
          AppLocalizations.of(context).translate('invalid_otp'), 2));
      errorController.add(ErrorAnimationType.shake);
    } else {
      CustomDialogs.showLoadingDialog(context, _keyLoader);
      verifyOTPAndLogin(currentText.trim());
    }
  }

  void verifyOTPAndLogin(String smsCode) async {
    AuthCredential _authCredential = PhoneAuthProvider.credential(
        verificationId: widget.verificationID, smsCode: smsCode);

    FirebaseAuth.instance
        .signInWithCredential(_authCredential)
        .then((UserCredential authResult) async {
      if (widget.isRegister) {
        dynamic result = await _authController.registerWithMobileNumber(
            int.parse(widget.number),
            widget.countryCode,
            widget.passKey,
            widget.name,
            widget.lastName,
            authResult.user.uid);
        if (!result['is_success']) {
          Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
          ScaffoldMessenger.of(context)
              .showSnackBar(CustomSnackBar.errorSnackBar(result['message'], 5));
        } else {
          await _success();
        }
      } else {
        dynamic result = await _authController.signInWithMobileNumber(
            widget.countryCode.toString() + widget.number);
        if (!result['is_success']) {
          Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
          ScaffoldMessenger.of(context)
              .showSnackBar(CustomSnackBar.errorSnackBar(result['message'], 5));
        } else {
          try {
            await _success();
          } catch (err) {
            ScaffoldMessenger.of(context).showSnackBar(
                CustomSnackBar.errorSnackBar(
                    AppLocalizations.of(context).translate('unable_to_login'),
                    2));
            return;
          }
        }
      }
    }).catchError((error) {
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar.errorSnackBar(
          AppLocalizations.of(context).translate('try_later'), 2));
    });
  }

  _success() async {
    final SharedPreferences prefs = await _prefs;

    if (widget._rememberUser) {
      prefs.setBool('user_session_live', true);
    } else {
      prefs.setBool('user_session_live', false);
    }
    prefs.setString(
        "user_profile_pic", cachedLocalUser.getSmallProfilePicPath());
    prefs.setString("user_name",
        cachedLocalUser.firstName + " " + cachedLocalUser.lastName ?? "");
    prefs.setString("mobile_number", cachedLocalUser.getID());

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) => UpdateApp(),
      ),
      (Route<dynamic> route) => false,
    );
  }
}
