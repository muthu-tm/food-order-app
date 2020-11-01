import 'package:chipchop_buyer/screens/home/HomeScreen.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
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
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passKeyController = TextEditingController();
  final AuthController _authController = AuthController();

  bool _rememberUser = true;
  bool _radioValue = true;

  @override
  void initState() {
    super.initState();

    _lastNameController.text = "";
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: CustomColors.lightGrey,
      bottomNavigationBar: Text(
        "Powered by Fourcup Inc.",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
        ),
      ),
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffD8F2A7), Color(0xffA4D649)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(child: _getColumnBody()),
        ),
      ),
    );
  }

  Widget _getColumnBody() => Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
          SizedBox(height: 20),
          Text(
            "SIGNUP",
            style: TextStyle(
              fontFamily: "OLED",
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
            ),
          ),
          Card(
            margin: EdgeInsets.all(10),
            color: Color(0xffD8F2A7),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      bottom: 5.0, top: 20, left: 20.0, right: 20.0),
                  child: TextField(
                    controller: _phoneNumberController,
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: InputDecoration(
                      prefix: Text('+91'),
                      prefixIcon: Icon(
                        Icons.phone,
                        color: CustomColors.lightGreen,
                        size: 30.0,
                      ),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 75,
                      ),
                      fillColor: CustomColors.white,
                      hintText: "Mobile Number",
                      hintStyle:
                          TextStyle(fontSize: 16.0, color: Colors.black54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
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
                SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      child: Flexible(
                        child: Padding(
                          padding:
                              EdgeInsets.only(left: 20, right: 5.0, bottom: 5),
                          child: TextField(
                            controller: _nameController,
                            textAlign: TextAlign.left,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              fillColor: CustomColors.white,
                              hintText: "First Name",
                              hintStyle: TextStyle(
                                  fontSize: 16.0, color: Colors.black54),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
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
                    ),
                    Container(
                      child: Flexible(
                        child: Padding(
                          padding:
                              EdgeInsets.only(right: 20, left: 5.0, bottom: 5),
                          child: TextField(
                            controller: _lastNameController,
                            textAlign: TextAlign.left,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              fillColor: CustomColors.white,
                              hintText: "Last Name",
                              hintStyle: TextStyle(
                                  fontSize: 16.0, color: Colors.black54),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
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
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Container(
                  child: Padding(
                    padding:
                        EdgeInsets.only(bottom: 5.0, left: 20.0, right: 20.0),
                    child: TextField(
                      textAlign: TextAlign.left,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(4),
                      ],
                      controller: _passKeyController,
                      obscureText: _passwordVisible,
                      maxLengthEnforced: true,
                      decoration: InputDecoration(
                        prefixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: CustomColors.lightGreen,
                            size: 30.0,
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
                        fillColor: CustomColors.white,
                        hintText: "4-digit secret key",
                        hintStyle:
                            TextStyle(fontSize: 16.0, color: Colors.black54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
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
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.info, color: CustomColors.alertRed, size: 20.0),
              SizedBox(width: 10.0),
              Flexible(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: AppLocalizations.of(context)
                              .translate('we_will_send'),
                          style: TextStyle(
                              color: CustomColors.blue,
                              fontWeight: FontWeight.w400)),
                      TextSpan(
                          text: AppLocalizations.of(context)
                              .translate('one_time_password'),
                          style: TextStyle(
                              color: CustomColors.alertRed,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700)),
                      TextSpan(
                          text: AppLocalizations.of(context)
                              .translate('to_mobile_no'),
                          style: TextStyle(
                              color: CustomColors.blue,
                              fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
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
                width: 200,
                child: RaisedButton(
                  elevation: 10.0,
                  onPressed: startPhoneAuth,
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      "Register",
                      style: TextStyle(
                        color: CustomColors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  color: CustomColors.alertRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(5),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Text(
                      AppLocalizations.of(context).translate('already_account'),
                      style: TextStyle(
                        fontSize: 14,
                        color: CustomColors.positiveGreen,
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
                        color: CustomColors.blue,
                      ),
                    ),
                  ),
                ],
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
      CustomDialogs.showLoadingDialog(context, _keyLoader);
      this.number = _phoneNumberController.text;

      var data = await User().getByID(countryCode.toString() + number);
      if (data != null) {
        Analytics.reportError({
          "type": 'sign_up_error',
          "user_id": countryCode.toString() + number,
          'name': _nameController.text,
          'error': "Found an existing user for this mobile number"
        }, 'sign_up');
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
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
          _lastNameController.text,
          authResult.user.uid);
      if (!result['is_success']) {
        Navigator.pop(context);
        _scaffoldKey.currentState
            .showSnackBar(CustomSnackBar.errorSnackBar(result['message'], 5));
      } else {
        final SharedPreferences prefs = await _prefs;
        if (_rememberUser) {
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
    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    CustomDialogs.showLoadingDialog(context, _keyLoader);
  }

  _verificationFailed(AuthException authException, BuildContext context) {
    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    _scaffoldKey.currentState.showSnackBar(CustomSnackBar.errorSnackBar(
        "Verification Failed:" + authException.message.toString(), 2));
  }

  _codeAutoRetrievalTimeout(String verificationId) {
    _smsVerificationCode = verificationId;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (BuildContext context) => PhoneAuthVerify(
            _rememberUser,
            true,
            number,
            countryCode,
            _passKeyController.text,
            _nameController.text,
            _lastNameController.text,
            _smsVerificationCode),
      ),
    );
  }
}
