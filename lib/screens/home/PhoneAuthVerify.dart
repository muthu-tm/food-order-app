import 'package:chipchop_buyer/screens/home/HomeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chipchop_buyer/db/models/user.dart';
import 'package:chipchop_buyer/screens/home/update_app.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:chipchop_buyer/screens/utils/CustomSnackBar.dart';
import 'package:chipchop_buyer/services/controllers/auth/auth_controller.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chipchop_buyer/app_localizations.dart';

// OTP VERIFICATION SCREEN

class PhoneAuthVerify extends StatefulWidget {
  PhoneAuthVerify(this.isRegister, this.number, this.countryCode, this.passKey,
      this.name, this.lastName, this.verificationID);

  final bool isRegister;
  final String number;
  final int countryCode;
  final String passKey;
  final String name;
  final String lastName;
  final String verificationID;

  @override
  _PhoneAuthVerifyState createState() => _PhoneAuthVerifyState();
}

class _PhoneAuthVerifyState extends State<PhoneAuthVerify> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final AuthController _authController = AuthController();

  double _height, _width, _fixedPadding;

  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();
  FocusNode focusNode3 = FocusNode();
  FocusNode focusNode4 = FocusNode();
  FocusNode focusNode5 = FocusNode();
  FocusNode focusNode6 = FocusNode();
  List<String> code = [];

  @override
  void initState() {
    super.initState();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _fixedPadding = _height * 0.025;

    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: Text(
        "Powered by Fourcup Inc.",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
        ),
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.all(_fixedPadding),
                child: ClipRRect(
                  child: Image.asset(
                    "images/icons/logo.png",
                    height: 80,
                  ),
                ),
              ),
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
                "Buy Organic Vegetables & Groceries",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14.0,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "My Pass Code",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              _getBody(),
              SizedBox(
                height: 10,
              ),
              RaisedButton(
                elevation: 16.0,
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
                color: CustomColors.alertRed,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _getBody() => Card(
        margin: EdgeInsets.all(10),
        color: Color(0xffD8F2A7),
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: SizedBox(
          child: _getColumnBody(),
        ),
      );

  Widget _getColumnBody() => Column(
        children: <Widget>[
          SizedBox(height: 20.0),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              getPinField(key: "1", focusNode: focusNode1),
              SizedBox(width: 5.0),
              getPinField(key: "2", focusNode: focusNode2),
              SizedBox(width: 5.0),
              getPinField(key: "3", focusNode: focusNode3),
              SizedBox(width: 5.0),
              getPinField(key: "4", focusNode: focusNode4),
              SizedBox(width: 5.0),
              getPinField(key: "5", focusNode: focusNode5),
              SizedBox(width: 5.0),
              getPinField(key: "6", focusNode: focusNode6),
              SizedBox(width: 5.0),
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(width: 16.0),
              Flexible(
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
                        text: 'Resend',
                        style: TextStyle(
                            color: CustomColors.alertRed,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 16.0),
            ],
          ),
          SizedBox(height: 16.0),
          SizedBox(height: 32.0),
        ],
      );

  signIn() {
    if (code.length != 6) {
      _scaffoldKey.currentState.showSnackBar(CustomSnackBar.errorSnackBar(
          AppLocalizations.of(context).translate('invalid_otp'), 2));
    } else {
      CustomDialogs.showLoadingDialog(context, _keyLoader);
      verifyOTPAndLogin(code.join());
    }
  }

  void verifyOTPAndLogin(String smsCode) async {
    AuthCredential _authCredential = PhoneAuthProvider.getCredential(
        verificationId: widget.verificationID, smsCode: smsCode);

    FirebaseAuth.instance
        .signInWithCredential(_authCredential)
        .then((AuthResult authResult) async {
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
          _scaffoldKey.currentState
              .showSnackBar(CustomSnackBar.errorSnackBar(result['message'], 5));
        } else {
          await _success();
        }
      } else {
        Map<String, dynamic> _uJSON =
            await User().getByID(widget.countryCode.toString() + widget.number);
        dynamic result =
            await _authController.signInWithMobileNumber(User.fromJson(_uJSON));
        if (!result['is_success']) {
          Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
          _scaffoldKey.currentState
              .showSnackBar(CustomSnackBar.errorSnackBar(result['message'], 5));
        } else {
          try {
            await _success();
          } catch (err) {
            _scaffoldKey.currentState.showSnackBar(CustomSnackBar.errorSnackBar(
                AppLocalizations.of(context).translate('unable_to_login'), 2));
            return;
          }
        }
      }
    }).catchError((error) {
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      _scaffoldKey.currentState.showSnackBar(CustomSnackBar.errorSnackBar(
          AppLocalizations.of(context).translate('try_later'), 2));
      _scaffoldKey.currentState
          .showSnackBar(CustomSnackBar.errorSnackBar("${error.toString()}", 2));
    });
  }

  _success() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString(
        "mobile_number", widget.countryCode.toString() + widget.number);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) => UpdateApp(
          child: HomeScreen(),
        ),
      ),
      (Route<dynamic> route) => false,
    );
  }

  Widget getPinField({String key, FocusNode focusNode}) => SizedBox(
        height: 40.0,
        width: 35.0,
        child: TextField(
          key: Key(key),
          expands: false,
          autofocus: false,
          focusNode: focusNode,
          onChanged: (String value) {
            if (value.length == 1) {
              code.insert(int.parse(key) - 1, value);
              switch (code.length) {
                case 1:
                  FocusScope.of(context).requestFocus(focusNode2);
                  break;
                case 2:
                  FocusScope.of(context).requestFocus(focusNode3);
                  break;
                case 3:
                  FocusScope.of(context).requestFocus(focusNode4);
                  break;
                case 4:
                  FocusScope.of(context).requestFocus(focusNode5);
                  break;
                case 5:
                  FocusScope.of(context).requestFocus(focusNode6);
                  break;
                default:
                  FocusScope.of(context).requestFocus(FocusNode());
                  break;
              }
            } else {
              code.removeAt(int.parse(key) - 1);
            }
          },
          maxLengthEnforced: false,
          textAlign: TextAlign.center,
          cursorColor: CustomColors.black,
          keyboardType: TextInputType.number,
          style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
              color: CustomColors.alertRed),
        ),
      );
}
