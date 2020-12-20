import 'package:chipchop_buyer/app_localizations.dart';
import 'package:chipchop_buyer/db/models/address.dart';
import 'package:chipchop_buyer/db/models/user_locations.dart';
import 'package:chipchop_buyer/screens/user/EditLocationPicker.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomSnackBar.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:flutter/material.dart';

class EditLocation extends StatefulWidget {
  EditLocation(this.loc);

  final UserLocations loc;
  @override
  _EditLocationState createState() => _EditLocationState();
}

class _EditLocationState extends State<EditLocation> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Address updatedAddress = Address();
  String locName = '';
  String userName = cachedLocalUser.getFullName();
  int uNumber = cachedLocalUser.mobileNumber;

  @override
  void initState() {
    super.initState();

    locName = widget.loc.locationName;
    userName = widget.loc.userName;
    uNumber = int.parse(widget.loc.userNumber);
    updatedAddress = widget.loc.address;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('title_add_location'),
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
      floatingActionButton: InkWell(
        onTap: () {
          final FormState form = _formKey.currentState;

          if (form.validate()) {
            UserLocations loc = widget.loc;
            loc.locationName = locName;
            loc.userNumber = uNumber.toString();
            loc.userName = userName;
            loc.address = updatedAddress;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditLocationPicker(loc),
                settings: RouteSettings(name: '/location/edit/picker'),
              ),
            );
          } else {
            _scaffoldKey.currentState.showSnackBar(
                CustomSnackBar.errorSnackBar("Please fill valid data!", 2));
          }
        },
        child: Container(
          height: 40,
          width: 120,
          padding: EdgeInsets.all(10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: CustomColors.green,
              border: Border.all(color: CustomColors.black),
              borderRadius: BorderRadius.circular(10.0)),
          child: Text(
            "Continue",
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 10.0, top: 10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      AppLocalizations.of(context).translate('location_name'),
                      style: TextStyle(
                          color: CustomColors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, top: 10, right: 10),
                  child: TextFormField(
                    autofocus: false,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    textAlign: TextAlign.start,
                    initialValue: locName,
                    decoration: InputDecoration(
                      hintText: "Ex, Home, Work",
                      fillColor: CustomColors.white,
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: CustomColors.grey)),
                    ),
                    validator: (name) {
                      if (name.isEmpty) {
                        return "Enter Location Name";
                      } else {
                        this.locName = name.trim();
                        return null;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0, top: 10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "User Name",
                      style: TextStyle(
                          color: CustomColors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, top: 10, right: 10),
                  child: TextFormField(
                    autofocus: false,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    textAlign: TextAlign.start,
                    initialValue: userName,
                    decoration: InputDecoration(
                      fillColor: CustomColors.white,
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: CustomColors.grey)),
                    ),
                    validator: (name) {
                      if (name.isEmpty) {
                        return "Enter User Name";
                      } else {
                        this.userName = name.trim();
                        return null;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0, top: 10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Contact Number",
                      style: TextStyle(
                          color: CustomColors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, top: 10, right: 10),
                  child: TextFormField(
                    autofocus: false,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.start,
                    initialValue: uNumber.toString(),
                    decoration: InputDecoration(
                      prefix: Text('+91'),
                      fillColor: CustomColors.white,
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: CustomColors.grey)),
                    ),
                    validator: (number) {
                      if (number.isEmpty) {
                        return "Enter Contact Number";
                      } else {
                        this.uNumber = int.parse(number.trim());
                        return null;
                      }
                    },
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
                                initialValue: updatedAddress.street,
                                textAlign: TextAlign.start,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)
                                      .translate('building_and_street'),
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
                                initialValue: updatedAddress.landmark,
                                textAlign: TextAlign.start,
                                textCapitalization:
                                    TextCapitalization.sentences,
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
                                initialValue: updatedAddress.city,
                                textAlign: TextAlign.start,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)
                                      .translate('city'),
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
                                initialValue: updatedAddress.state,
                                textAlign: TextAlign.start,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)
                                      .translate('state'),
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
                                keyboardType: TextInputType.number,
                                initialValue: updatedAddress.pincode,
                                textAlign: TextAlign.start,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)
                                      .translate('pincode'),
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
                            Padding(padding: EdgeInsets.only(left: 5)),
                            Flexible(
                              child: TextFormField(
                                initialValue: updatedAddress.country ?? "India",
                                keyboardType: TextInputType.number,
                                textCapitalization:
                                    TextCapitalization.sentences,
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
                SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
