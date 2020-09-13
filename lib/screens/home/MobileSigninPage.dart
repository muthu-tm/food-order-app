import 'package:chipchop_buyer/screens/home/HomeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chipchop_buyer/db/models/user.dart';
import 'package:chipchop_buyer/screens/home/update_app.dart';
import 'package:chipchop_buyer/screens/home/PhoneAuthVerify.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:chipchop_buyer/screens/utils/CustomSnackBar.dart';
import 'package:chipchop_buyer/services/analytics/analytics.dart';
import 'package:chipchop_buyer/services/controllers/auth/auth_controller.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chipchop_buyer/app_localizations.dart';

class MobileSignInPage extends StatefulWidget {
  @override
  _MobileSignInPageState createState() => _MobileSignInPageState();
}

class _MobileSignInPageState extends State<MobileSignInPage> {
  String number, _smsVerificationCode;
  int countryCode = 91;
  bool _passwordVisible = true;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passKeyController = TextEditingController();
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: CustomColors.buyerLightGrey,
      body: SingleChildScrollView(
        child: _getColumnBody(),
      ),
    );
  }

  Widget _getColumnBody() => Column(
        //mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 25),
            child: ClipRRect(
              child: Image.asset(
                "images/icons/logo.png",
                height: 80,
                width: 80,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              "Welcome",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Text(
              "Register account",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
          Container(
            child: Padding(
              padding:
                  const EdgeInsets.only(bottom: 8.0, left: 24.0, right: 24.0),
              child: TextField(
                textAlign: TextAlign.left,
                keyboardType: TextInputType.number,
                inputFormatters:[
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.phone,
                    color: CustomColors.mfinFadedButtonGreen,
                    size: 35.0,
                  ),
                  prefixIconConstraints: BoxConstraints(
                    minWidth: 75,
                  ),
                  fillColor: CustomColors.buyerWhite,
                  hintText: "Mobile Number",
                  hintStyle: TextStyle(
                      fontSize: 16.0,
                      fontFamily: 'Montserrat',
                      color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  filled: true,
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),
          ),
          SizedBox(height: 5),
          Container(
            child: Padding(
              padding:
                  const EdgeInsets.only(bottom: 8.0, left: 24.0, right: 24.0),
              child: TextField(
                textAlign: TextAlign.left,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: CustomColors.mfinFadedButtonGreen,
                    size: 35.0,
                  ),
                  prefixIconConstraints: BoxConstraints(
                    minWidth: 75,
                  ),
                  fillColor: CustomColors.buyerWhite,
                  hintText: "Name",
                  hintStyle: TextStyle(
                      fontSize: 16.0,
                      fontFamily: 'Montserrat',
                      color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  filled: true,
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),
          ),
          SizedBox(height: 5),
          Container(
            child: Padding(
              padding:
                  const EdgeInsets.only(bottom: 8.0, left: 24.0, right: 24.0),
              child: TextField(
                textAlign: TextAlign.left,
                keyboardType: TextInputType.number,
                maxLength: 4,
                controller: _passKeyController,
                obscureText: _passwordVisible,
                maxLengthEnforced: true,
                decoration: InputDecoration(
                  prefixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: CustomColors.mfinFadedButtonGreen,
                      size: 35.0,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                  prefixIconConstraints: BoxConstraints(
                    minWidth: 75,
                  ),
                  fillColor: CustomColors.buyerWhite,
                  hintText: "4-digit secret key",
                  hintStyle: TextStyle(
                      fontSize: 16.0,
                      fontFamily: 'Montserrat',
                      color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  filled: true,
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(width: 5),
              Icon(Icons.info, color: CustomColors.buyerAlertRed, size: 20.0),
              SizedBox(width: 10.0),
              Expanded(
                child: RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: AppLocalizations.of(context)
                          .translate('we_will_send'),
                      style: TextStyle(
                          color: CustomColors.mfinBlue,
                          fontWeight: FontWeight.w400)),
                  TextSpan(
                      text: AppLocalizations.of(context)
                          .translate('one_time_password'),
                      style: TextStyle(
                          color: CustomColors.buyerAlertRed,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700)),
                  TextSpan(
                      text: AppLocalizations.of(context)
                          .translate('to_mobile_no'),
                      style: TextStyle(
                          color: CustomColors.mfinBlue,
                          fontWeight: FontWeight.w400)),
                ])),
              ),
              SizedBox(width: 5),
            ],
          ),
          SizedBox(height: 10),
          RaisedButton(
            elevation: 16.0,
            onPressed: startPhoneAuth,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                AppLocalizations.of(context).translate('get_otp'),
                style: TextStyle(
                  color: CustomColors.mfinButtonGreen,
                  fontSize: 18.0,
                ),
              ),
            ),
            color: CustomColors.mfinBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Text(
                  AppLocalizations.of(context).translate('already_account'),
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Georgia',
                    color: CustomColors.buyerPositiveGreen,
                  ),
                ),
              ),
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocalizations.of(context).translate('login'),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CustomColors.mfinBlue,
                  ),
                ),
              ),
            ],
          ),
        ],
      );

  startPhoneAuth() async {
    if (_phoneNumberController.text.length != 10) {
      _scaffoldKey.currentState.showSnackBar(CustomSnackBar.errorSnackBar(
          AppLocalizations.of(context).translate('invalid_number'), 2));
      return;
    } else if (_nameController.text.length <= 2) {
      _scaffoldKey.currentState.showSnackBar(CustomSnackBar.errorSnackBar(
          AppLocalizations.of(context).translate('enter_your_name'), 2));
      return;
    } else if (_passKeyController.text.length != 4) {
      _scaffoldKey.currentState.showSnackBar(CustomSnackBar.errorSnackBar(
          AppLocalizations.of(context).translate('secret_key_validation'), 2));
      return;
    } else {
      CustomDialogs.actionWaiting(
          context, AppLocalizations.of(context).translate('checking_user'));
      this.number = _phoneNumberController.text;

      var data = await User().getByID(countryCode.toString() + number);
      if (data != null) {
        Analytics.reportError({
          "type": 'sign_up_error',
          "user_id": countryCode.toString() + number,
          'name': _nameController.text,
          'error': "Found an existing user for this mobile number"
        }, 'sign_up');
        Navigator.pop(context);
        _scaffoldKey.currentState.showSnackBar(CustomSnackBar.errorSnackBar(
            "Found an existing user for this mobile number", 2));
      } else {
        await _verifyPhoneNumber();
      }
    }
  }

  _verifyPhoneNumber() async {
    String phoneNumber = '+' + countryCode.toString() + number;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 5),
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
        .then((AuthResult authResult) async {
      dynamic result = await _authController.registerWithMobileNumber(
          int.parse(number),
          countryCode,
          _passKeyController.text,
          _nameController.text,
          "",
          authResult.user.uid);
      if (!result['is_success']) {
        Navigator.pop(context);
        _scaffoldKey.currentState
            .showSnackBar(CustomSnackBar.errorSnackBar(result['message'], 5));
      } else {
        final SharedPreferences prefs = await _prefs;
        prefs.setString("mobile_number", countryCode.toString() + number);

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) => UpdateApp(
              child: HomeScreen(),
            ),
          ),
          (Route<dynamic> route) => false,
        );
      }
    }).catchError((error) {
      Navigator.pop(context);
      _scaffoldKey.currentState.showSnackBar(CustomSnackBar.errorSnackBar(
          AppLocalizations.of(context).translate('try_later'), 2));
      _scaffoldKey.currentState
          .showSnackBar(CustomSnackBar.errorSnackBar("${error.toString()}", 2));
    });
  }

  _smsCodeSent(String verificationId, List<int> code) {
    _scaffoldKey.currentState.showSnackBar(CustomSnackBar.successSnackBar(
        AppLocalizations.of(context).translate('otp_send'), 1));

    _smsVerificationCode = verificationId;
    Navigator.pop(context);
    CustomDialogs.actionWaiting(
        context, AppLocalizations.of(context).translate('verify_user'));
  }

  _verificationFailed(AuthException authException, BuildContext context) {
    Navigator.pop(context);
    _scaffoldKey.currentState.showSnackBar(CustomSnackBar.errorSnackBar(
        "Verification Failed:" + authException.message.toString(), 2));
  }

  _codeAutoRetrievalTimeout(String verificationId) {
    _smsVerificationCode = verificationId;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (BuildContext context) => PhoneAuthVerify(
            true,
            number,
            countryCode,
            _passKeyController.text,
            _nameController.text,
            _smsVerificationCode),
      ),
    );
  }
}
