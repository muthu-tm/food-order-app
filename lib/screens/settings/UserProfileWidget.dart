import 'package:chipchop_buyer/app_localizations.dart';
import 'package:chipchop_buyer/db/models/user.dart';
import 'package:chipchop_buyer/screens/settings/ChangeSecret.dart';
import 'package:chipchop_buyer/screens/settings/EditUserProfile.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:chipchop_buyer/services/utils/DateUtils.dart';
import 'package:flutter/material.dart';

class UserProfileWidget extends StatelessWidget {
  UserProfileWidget(this.user, [this.title = "Profile Details"]);

  final User user;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: CustomColors.buyerLightGrey,
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Icon(
              Icons.assignment_ind,
              size: 35.0,
              color: CustomColors.mfinBlue,
            ),
            title: Text(
              title,
              style: TextStyle(
                color: CustomColors.mfinBlue,
                fontSize: 18.0,
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.edit,
                size: 35.0,
                color: CustomColors.mfinBlue,
              ),
              onPressed: () {
                if (user.mobileNumber != cachedLocalUser.mobileNumber) {
                  CustomDialogs.information(
                      context,
                      "Warning",
                      CustomColors.buyerAlertRed,
                      "You are not allowed to edit this user data!");
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditUserProfile(),
                      settings: RouteSettings(name: '/settings/user/edit'),
                    ),
                  );
                }
              },
            ),
          ),
          Divider(
            color: CustomColors.mfinBlue,
          ),
          ListTile(
            leading: SizedBox(
              width: 95,
              child: Text(
                AppLocalizations.of(context).translate('name'),
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: "Georgia",
                    fontWeight: FontWeight.bold,
                    color: CustomColors.buyerGrey),
              ),
            ),
            title: TextFormField(
              initialValue: user.firstName,
              decoration: InputDecoration(
                fillColor: CustomColors.buyerWhite,
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                  color: CustomColors.buyerGrey,
                )),
              ),
              readOnly: true,
            ),
          ),
          ListTile(
            leading: SizedBox(
              width: 95,
              child: Text(
                AppLocalizations.of(context).translate('contact_number'),
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: "Georgia",
                    fontWeight: FontWeight.bold,
                    color: CustomColors.buyerGrey),
              ),
            ),
            title: TextFormField(
              initialValue: user.countryCode.toString() +
                  ' ' +
                  user.mobileNumber.toString(),
              decoration: InputDecoration(
                fillColor: CustomColors.buyerLightGrey,
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: CustomColors.buyerGrey)),
              ),
              enabled: false,
              autofocus: false,
            ),
          ),
          (user.mobileNumber == cachedLocalUser.mobileNumber)
              ? ListTile(
                  leading: SizedBox(
                    width: 95,
                    child: Text(
                      AppLocalizations.of(context).translate('password'),
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: "Georgia",
                          fontWeight: FontWeight.bold,
                          color: CustomColors.buyerGrey),
                    ),
                  ),
                  title: TextFormField(
                    initialValue: "****",
                    textAlign: TextAlign.start,
                    obscureText: true,
                    decoration: InputDecoration(
                      fillColor: CustomColors.buyerWhite,
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: CustomColors.buyerGrey)),
                    ),
                    readOnly: true,
                  ),
                  trailing: IconButton(
                    highlightColor: CustomColors.buyerAlertRed.withOpacity(0.5),
                    tooltip: AppLocalizations.of(context)
                        .translate('change_password'),
                    icon: Icon(
                      Icons.edit,
                      size: 25.0,
                      color: CustomColors.buyerAlertRed.withOpacity(0.7),
                    ),
                    onPressed: () {
                      if (user.mobileNumber == cachedLocalUser.mobileNumber) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangeSecret(),
                            settings: RouteSettings(
                                name: '/settings/user/secret/edit'),
                          ),
                        );
                      }
                    },
                  ),
                )
              : Container(),
          ListTile(
            leading: SizedBox(
              width: 95,
              child: Text(
                AppLocalizations.of(context).translate('gender'),
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: "Georgia",
                    fontWeight: FontWeight.bold,
                    color: CustomColors.buyerGrey),
              ),
            ),
            title: TextFormField(
              initialValue: user.gender,
              decoration: InputDecoration(
                fillColor: CustomColors.buyerWhite,
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: CustomColors.buyerGrey)),
              ),
              readOnly: true,
            ),
          ),
          ListTile(
            leading: SizedBox(
              width: 95,
              child: Text(
                AppLocalizations.of(context).translate('email'),
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: "Georgia",
                    fontWeight: FontWeight.bold,
                    color: CustomColors.buyerGrey),
              ),
            ),
            title: TextFormField(
              initialValue: user.emailID,
              decoration: InputDecoration(
                fillColor: CustomColors.buyerWhite,
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: CustomColors.buyerWhite)),
              ),
              readOnly: true,
            ),
          ),
          ListTile(
            leading: SizedBox(
              width: 95,
              child: Text(
                AppLocalizations.of(context).translate('dob'),
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: "Georgia",
                    fontWeight: FontWeight.bold,
                    color: CustomColors.buyerGrey),
              ),
            ),
            title: TextFormField(
              initialValue: user.dateOfBirth == null
                  ? ''
                  : DateUtils.formatDate(
                      DateTime.fromMillisecondsSinceEpoch(user.dateOfBirth)),
              decoration: InputDecoration(
                fillColor: CustomColors.buyerWhite,
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: CustomColors.buyerGrey)),
                suffixIcon: Icon(
                  Icons.perm_contact_calendar,
                  size: 35,
                  color: CustomColors.mfinBlue,
                ),
              ),
              readOnly: true,
            ),
          ),
          ListTile(
            leading: SizedBox(
              width: 95,
              child: Text(
                AppLocalizations.of(context).translate('address'),
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: "Georgia",
                    fontWeight: FontWeight.bold,
                    color: CustomColors.buyerGrey),
              ),
            ),
            title: TextFormField(
              initialValue: user.address.toString(),
              maxLines: 5,
              decoration: InputDecoration(
                fillColor: CustomColors.buyerWhite,
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: CustomColors.buyerGrey)),
              ),
              readOnly: true,
            ),
          )
        ],
      ),
    );
  }
}
