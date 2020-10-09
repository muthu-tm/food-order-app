import 'package:chipchop_buyer/app_localizations.dart';
import 'package:chipchop_buyer/db/models/address.dart';
import 'package:chipchop_buyer/db/models/user.dart';
import 'package:chipchop_buyer/screens/settings/UserProfileSettings.dart';
import 'package:chipchop_buyer/screens/utils/AddressWidget.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:chipchop_buyer/screens/utils/CustomSnackBar.dart';
import 'package:chipchop_buyer/screens/utils/field_validator.dart';
import 'package:chipchop_buyer/services/controllers/user/user_controller.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:chipchop_buyer/services/utils/DateUtils.dart';
import 'package:flutter/material.dart';

class EditUserProfile extends StatefulWidget {
  @override
  _EditUserProfileState createState() => _EditUserProfileState();
}

class _EditUserProfileState extends State<EditUserProfile> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  final User user = cachedLocalUser;
  final Map<String, dynamic> updatedUser = new Map();
  final Address updatedAddress = new Address();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final UserController _userController = UserController();

  DateTime selectedDate = DateTime.now();
  String gender;

  @override
  void initState() {
    super.initState();
    gender = user.gender;
    if (user.dateOfBirth != null)
      this._date.text = DateUtils.formatDate(
          DateTime.fromMillisecondsSinceEpoch(user.dateOfBirth));
    else
      this._date.text = DateUtils.formatDate(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    updatedUser['mobile_number'] = user.mobileNumber;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('edit_profile'),
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
        backgroundColor: CustomColors.alertRed,
        onPressed: () {
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Card(
                color: CustomColors.lightGrey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 15.0, top: 10),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          AppLocalizations.of(context).translate('first_name'),
                          style: TextStyle(
                              fontFamily: "Georgia",
                              color: CustomColors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                      ),
                    ),
                    ListTile(
                      title: TextFormField(
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        initialValue: user.firstName,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)
                              .translate('first_name'),
                          fillColor: CustomColors.white,
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 3.0, horizontal: 3.0),
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: CustomColors.white)),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Enter your First Name';
                          }
                          updatedUser['first_name'] = value;
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15.0, top: 10),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          AppLocalizations.of(context).translate('last_name'),
                          style: TextStyle(
                              fontFamily: "Georgia",
                              color: CustomColors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                      ),
                    ),
                    ListTile(
                      title: TextFormField(
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        initialValue: user.lastName,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)
                              .translate('last_name'),
                          fillColor: CustomColors.white,
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 3.0, horizontal: 3.0),
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: CustomColors.white)),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            updatedUser['last_name'] = "";
                          } else {
                            updatedUser['last_name'] = value;
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15.0, top: 10),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          AppLocalizations.of(context).translate('email'),
                          style: TextStyle(
                              fontFamily: "Georgia",
                              color: CustomColors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                      ),
                    ),
                    ListTile(
                      title: TextFormField(
                          keyboardType: TextInputType.text,
                          initialValue: user.emailID,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)
                                .translate('enter_email_id'),
                            fillColor: CustomColors.white,
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 3.0, horizontal: 3.0),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: CustomColors.white)),
                          ),
                          validator: (email) {
                            if (email.trim().isEmpty) {
                              setEmailID("");
                              return null;
                            } else {
                              return FieldValidator.emailValidator(
                                  email.trim(), setEmailID);
                            }
                          }),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15.0, top: 10),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          AppLocalizations.of(context).translate('dob'),
                          style: TextStyle(
                              fontFamily: "Georgia",
                              color: CustomColors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                      ),
                    ),
                    ListTile(
                      title: GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _date,
                            keyboardType: TextInputType.datetime,
                            decoration: InputDecoration(
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelStyle: TextStyle(
                                color: CustomColors.blue,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 3.0, horizontal: 10.0),
                              border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: CustomColors.white)),
                              fillColor: CustomColors.white,
                              filled: true,
                              suffixIcon: Icon(
                                Icons.perm_contact_calendar,
                                size: 35,
                                color: CustomColors.blue,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15.0, top: 10),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          AppLocalizations.of(context).translate('gender'),
                          style: TextStyle(
                              fontFamily: "Georgia",
                              color: CustomColors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Flexible(
                          child: RadioListTile(
                            title: Text(
                              AppLocalizations.of(context).translate('male'),
                              style: TextStyle(color: CustomColors.blue),
                            ),
                            value: "Male",
                            selected: gender.contains("Male"),
                            groupValue: gender,
                            onChanged: (val) {
                              setState(() {
                                gender = val;
                                updatedUser['gender'] = "Male";
                              });
                            },
                          ),
                        ),
                        Flexible(
                          child: RadioListTile(
                            title: Text(
                              AppLocalizations.of(context).translate('female'),
                              style: TextStyle(color: CustomColors.blue),
                            ),
                            value: "Female",
                            selected: gender.contains("Female"),
                            groupValue: gender,
                            onChanged: (val) {
                              setState(() {
                                gender = val;
                                updatedUser['gender'] = "Female";
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AddressWidget("Address", user.address, updatedAddress),
              Padding(padding: EdgeInsets.only(top: 35, bottom: 35)),
            ],
          ),
        ),
      ),
    );
  }

  setEmailID(String emailID) {
    updatedUser['emailID'] = emailID;
  }

  TextEditingController _date = TextEditingController();

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900, 1),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        updatedUser['date_of_birth'] = DateUtils.getUTCDateEpoch(picked);
      });
  }

  Future<void> _submit() async {
    final FormState form = _formKey.currentState;

    if (form.validate()) {
      CustomDialogs.showLoadingDialog(context, _keyLoader);

      updatedUser['address'] = updatedAddress.toJson();
      var result = await _userController.updateUser(updatedUser);

      if (!result['is_success']) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        _scaffoldKey.currentState
            .showSnackBar(CustomSnackBar.errorSnackBar(result['message'], 2));
      } else {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserSetting(),
            settings: RouteSettings(name: '/settings/user'),
          ),
        );
      }
    } else {
      _scaffoldKey.currentState.showSnackBar(
          CustomSnackBar.errorSnackBar("Please fill valid data!", 2));
    }
  }
}
