import 'package:chipchop_buyer/app_localizations.dart';
import 'package:chipchop_buyer/db/models/address.dart';
import 'package:chipchop_buyer/db/models/user_locations.dart';
import 'package:chipchop_buyer/screens/user/LocationPicker.dart';
import 'package:chipchop_buyer/screens/utils/AddressWidget.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomSnackBar.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:flutter/material.dart';

class AddLocation extends StatefulWidget {
  @override
  _AddLocationState createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Address sAddress = Address();
  String locName = '';
  String userName = '';
  int uNumber = cachedLocalUser.mobileNumber;

  @override
  void initState() {
    super.initState();
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: CustomColors.blueGreen,
        onPressed: () {
          final FormState form = _formKey.currentState;

          if (form.validate()) {
            if (sAddress.pincode == null || sAddress.pincode.isEmpty) {
              _scaffoldKey.currentState.showSnackBar(
                CustomSnackBar.errorSnackBar("Please enter your PINCODE!", 2),
              );
              return;
            }
            UserLocations loc = UserLocations();
            loc.locationName = locName;
            loc.userNumber = '91' + uNumber.toString();
            loc.userName = userName;
            loc.address = sAddress;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LocationPicker(loc),
                settings: RouteSettings(name: '/location/add/picker'),
              ),
            );
          } else {
            _scaffoldKey.currentState.showSnackBar(
                CustomSnackBar.errorSnackBar("Please fill valid data!", 2));
          }
        },
        label: Text(
          AppLocalizations.of(context).translate('button_next'),
        ),
        icon: Icon(Icons.arrow_forward_ios),
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
                          fontFamily: "Georgia",
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
                      }
                      return null;
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
                          fontFamily: "Georgia",
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
                    textAlign: TextAlign.start,
                    initialValue: locName,
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
                      }
                      return null;
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
                          fontFamily: "Georgia",
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
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: AddressWidget("Address", Address(), sAddress),
                ),
                SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
