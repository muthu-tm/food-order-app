import 'package:chipchop_buyer/db/models/address.dart';
import 'package:chipchop_buyer/db/models/user.dart';
import 'package:chipchop_buyer/screens/settings/UserProfileSettings.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:chipchop_buyer/screens/utils/CustomSnackBar.dart';
import 'package:chipchop_buyer/screens/utils/field_validator.dart';
import 'package:chipchop_buyer/services/controllers/user/user_controller.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:chipchop_buyer/services/utils/Dateutils.dart';
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
      this._date.text = Dateutils.formatDate(
          DateTime.fromMillisecondsSinceEpoch(user.dateOfBirth));
    else
      this._date.text = Dateutils.formatDate(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    updatedUser['mobile_number'] = user.mobileNumber;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Edit Profile",
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
        onPressed: () {
          _submit();
        },
        label: Text(
          "Save",
          style: TextStyle(
            fontSize: 17,
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
                          "First Name",
                          style: TextStyle(
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
                          hintText: "First Name",
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
                          "Last Name",
                          style: TextStyle(
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
                          hintText: "Last Name",
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
                          "Email",
                          style: TextStyle(
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
                            hintText: "Email ID",
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
                          "Date of Birth",
                          style: TextStyle(
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
                          'Gender',
                          style: TextStyle(
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
                              "Male",
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
                              "Female",
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
              Padding(
                padding: EdgeInsets.all(5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 40,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Address",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            child: TextFormField(
                              initialValue: user.address.street,
                              textAlign: TextAlign.center,
                              textCapitalization: TextCapitalization.sentences,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: "Building no. & street",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                labelStyle: TextStyle(
                                  fontSize: 12.0,
                                  color: CustomColors.black,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: CustomColors.lightGreen)),
                                fillColor: CustomColors.white,
                                filled: true,
                              ),
                              validator: (street) {
                                if (street.trim().isEmpty) {
                                  return "Enter your Street";
                                } else {
                                  updatedAddress.street = street.trim();
                                  return null;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            child: TextFormField(
                              initialValue: user.address.landmark,
                              textAlign: TextAlign.start,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                labelText: "Landmark",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                labelStyle: TextStyle(
                                  fontSize: 12.0,
                                  color: CustomColors.black,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 3.0, horizontal: 10.0),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: CustomColors.lightGreen)),
                                fillColor: CustomColors.white,
                                filled: true,
                              ),
                              validator: (landmark) {
                                if (landmark.trim() != "") {
                                  updatedAddress.landmark = landmark.trim();
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            child: TextFormField(
                              initialValue: user.address.city,
                              textAlign: TextAlign.start,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                labelText: "City",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                labelStyle: TextStyle(
                                  fontSize: 12.0,
                                  color: CustomColors.black,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 3.0, horizontal: 10.0),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: CustomColors.lightGreen)),
                                fillColor: CustomColors.white,
                                filled: true,
                              ),
                              validator: (city) {
                                if (city.trim().isEmpty) {
                                  return "Enter your City";
                                } else {
                                  updatedAddress.city = city.trim();
                                  return null;
                                }
                              },
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(left: 5)),
                          Flexible(
                            child: TextFormField(
                              initialValue: user.address.state,
                              textCapitalization: TextCapitalization.sentences,
                              textAlign: TextAlign.start,
                              decoration: InputDecoration(
                                labelText: "State",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                labelStyle: TextStyle(
                                  fontSize: 12.0,
                                  color: CustomColors.black,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 3.0, horizontal: 10.0),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: CustomColors.lightGreen)),
                                fillColor: CustomColors.white,
                                filled: true,
                              ),
                              validator: (state) {
                                if (state.trim().isEmpty) {
                                  return "Enter Your State";
                                } else {
                                  updatedAddress.state = state.trim();
                                  return null;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            child: TextFormField(
                              initialValue: user.address.pincode,
                              textAlign: TextAlign.start,
                              decoration: InputDecoration(
                                labelText: "Pincode",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                labelStyle: TextStyle(
                                  fontSize: 12.0,
                                  color: CustomColors.black,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 3.0, horizontal: 10.0),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: CustomColors.lightGreen)),
                                fillColor: CustomColors.white,
                                filled: true,
                              ),
                              validator: (pinCode) {
                                if (pinCode.trim().isEmpty) {
                                  return "Enter Your Pincode";
                                } else {
                                  updatedAddress.pincode = pinCode.trim();

                                  return null;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            child: TextFormField(
                              initialValue: user.address.country ?? "India",
                              textCapitalization: TextCapitalization.sentences,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.start,
                              decoration: InputDecoration(
                                labelText: "Country / Region",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                labelStyle: TextStyle(
                                  fontSize: 12.0,
                                  color: CustomColors.black,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 3.0, horizontal: 10.0),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: CustomColors.lightGreen)),
                                fillColor: CustomColors.white,
                                filled: true,
                              ),
                              validator: (country) {
                                if (country.trim().isEmpty) {
                                  updatedAddress.country = "India";
                                } else {
                                  updatedAddress.country = country.trim();
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
        updatedUser['date_of_birth'] = Dateutils.getUTCDateEpoch(picked);
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
        ScaffoldMessenger.of(context)
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
      ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.errorSnackBar("Please fill valid data!", 2));
    }
  }
}
