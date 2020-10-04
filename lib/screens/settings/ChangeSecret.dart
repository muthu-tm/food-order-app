import 'package:chipchop_buyer/app_localizations.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:chipchop_buyer/screens/utils/CustomSnackBar.dart';
import 'package:chipchop_buyer/screens/utils/field_validator.dart';
import 'package:chipchop_buyer/services/controllers/user/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ChangeSecret extends StatefulWidget {
  @override
  _ChangeSecretState createState() => _ChangeSecretState();
}

class _ChangeSecretState extends State<ChangeSecret> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String secretKey = "";
  String confirmKey = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('change_secret_key'),
          textAlign: TextAlign.start,
          style: TextStyle(color: CustomColors.lightGrey, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: CustomColors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: CustomColors.green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: CustomColors.blue,
        onPressed: () async {
          _submit();
        },
        label: Text(
          AppLocalizations.of(context).translate('save'),
          style: TextStyle(
            fontSize: 17,
            fontFamily: "Georgia",
            fontWeight: FontWeight.bold,
          ),
        ),
        splashColor: CustomColors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: 10, left: 5, right: 5, bottom: 10),
            child: Card(
              color: CustomColors.grey,
              elevation: 5.0,
              child: Column(
                children: <Widget>[
                  Text(
                      AppLocalizations.of(context).translate('new_secret_key')),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: TextFormField(
                      textAlign: TextAlign.start,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                          color: CustomColors.blue,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        fillColor: CustomColors.white,
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 3.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: CustomColors.white)),
                      ),
                      autofocus: false,
                      validator: (value) {
                        return FieldValidator.passwordValidator(
                            value, setSecretKey);
                      },
                    ),
                  ),
                  Text(AppLocalizations.of(context)
                      .translate('confirm_secret_key')),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: TextFormField(
                      textAlign: TextAlign.start,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                          color: CustomColors.blue,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        fillColor: CustomColors.white,
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 3.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: CustomColors.white)),
                      ),
                      autofocus: false,
                      validator: (value) {
                        if (value.isEmpty) {
                          return AppLocalizations.of(context)
                              .translate('reenter_secret_key');
                        } else {
                          if (secretKey != value) {
                            return AppLocalizations.of(context)
                                .translate('secret_key_mismatch');
                          }
                          confirmKey = value;
                          return null;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  setSecretKey(String sKey) {
    secretKey = sKey;
  }

  _submit() async {
    final FormState form = _formKey.currentState;

    if (form.validate()) {
      CustomDialogs.showLoadingDialog(context, _keyLoader);

      var result = await UserController().updateSecretKey(secretKey);
      if (!result['is_success']) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        _scaffoldKey.currentState
            .showSnackBar(CustomSnackBar.errorSnackBar(result['message'], 5));
      } else {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        _scaffoldKey.currentState.showSnackBar(CustomSnackBar.successSnackBar(
            AppLocalizations.of(context)
                .translate('secret_key_updated_successfully'),
            2));
        await Future.delayed(Duration(seconds: 1));
        Navigator.pop(context);
      }
    }
  }
}
