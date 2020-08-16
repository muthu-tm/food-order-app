import 'package:chipchop_buyer/app_localizations.dart';
import 'package:chipchop_buyer/db/models/address.dart';
import 'package:chipchop_buyer/db/models/user_locations.dart';
import 'package:chipchop_buyer/screens/user/LocationPicker.dart';
import 'package:chipchop_buyer/screens/utils/AddressWidget.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomSnackBar.dart';
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
        ),
        backgroundColor: CustomColors.mfinBlue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: CustomColors.mfinBlue,
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
            loc.address = sAddress;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LocationPicker(loc),
                settings: RouteSettings(name: '/add/location/picker'),
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
                          color: CustomColors.buyerGrey,
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
                      fillColor: CustomColors.buyerWhite,
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: CustomColors.buyerGrey)),
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
