import 'package:chipchop_buyer/app_localizations.dart';
import 'package:chipchop_buyer/db/models/user.dart';
import 'package:chipchop_buyer/screens/settings/ChangeSecret.dart';
import 'package:chipchop_buyer/screens/settings/EditUserProfile.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:chipchop_buyer/services/utils/Dateutils.dart';
import 'package:flutter/material.dart';

class UserProfileWidget extends StatelessWidget {
  UserProfileWidget(this.user, [this.title = "Profile Details"]);

  final User user;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: CustomColors.lightGrey,
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Icon(
              Icons.assignment_ind,
              size: 35.0,
              color: CustomColors.blue,
            ),
            title: Text(
              title,
              style: TextStyle(
                color: CustomColors.green,
                fontSize: 18.0,
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.edit,
                size: 35.0,
                color: CustomColors.blue,
              ),
              onPressed: () {
                if (user.mobileNumber != cachedLocalUser.mobileNumber) {
                  CustomDialogs.information(
                      context,
                      "Warning",
                      CustomColors.alertRed,
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
            color: CustomColors.blue,
          ),
          ListTile(
            leading: SizedBox(
              width: 95,
              child: Text(
                AppLocalizations.of(context).translate('name'),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: CustomColors.grey),
              ),
            ),
            title: TextFormField(
              initialValue: user.firstName,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                fillColor: CustomColors.white,
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                  color: CustomColors.grey,
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
                    fontWeight: FontWeight.bold,
                    color: CustomColors.grey),
              ),
            ),
            title: TextFormField(
              initialValue: user.countryCode.toString() +
                  ' ' +
                  user.mobileNumber.toString(),
              decoration: InputDecoration(
                fillColor: CustomColors.lightGrey,
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: CustomColors.grey)),
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
                          fontWeight: FontWeight.bold,
                          color: CustomColors.grey),
                    ),
                  ),
                  title: TextFormField(
                    initialValue: "****",
                    textAlign: TextAlign.start,
                    obscureText: true,
                    decoration: InputDecoration(
                      fillColor: CustomColors.white,
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: CustomColors.grey)),
                    ),
                    readOnly: true,
                  ),
                  trailing: IconButton(
                    highlightColor: CustomColors.alertRed.withOpacity(0.5),
                    tooltip: AppLocalizations.of(context)
                        .translate('change_password'),
                    icon: Icon(
                      Icons.edit,
                      size: 25.0,
                      color: CustomColors.alertRed.withOpacity(0.7),
                    ),
                    onPressed: () {
                      if (user.mobileNumber == cachedLocalUser.mobileNumber) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangeSecret(),
                            settings: RouteSettings(
                                name: '/settings/user/secret'),
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
                    fontWeight: FontWeight.bold,
                    color: CustomColors.grey),
              ),
            ),
            title: TextFormField(
              initialValue: user.gender,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                fillColor: CustomColors.white,
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: CustomColors.grey)),
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
                    fontWeight: FontWeight.bold,
                    color: CustomColors.grey),
              ),
            ),
            title: TextFormField(
              initialValue: user.emailID,
              decoration: InputDecoration(
                fillColor: CustomColors.white,
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: CustomColors.white)),
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
                    fontWeight: FontWeight.bold,
                    color: CustomColors.grey),
              ),
            ),
            title: TextFormField(
              initialValue: user.dateOfBirth == null
                  ? ''
                  : Dateutils.formatDate(
                      DateTime.fromMillisecondsSinceEpoch(user.dateOfBirth)),
              decoration: InputDecoration(
                fillColor: CustomColors.white,
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: CustomColors.grey)),
                suffixIcon: Icon(
                  Icons.cake,
                  size: 35,
                  color: CustomColors.blue,
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
                    fontWeight: FontWeight.bold,
                    color: CustomColors.grey),
              ),
            ),
            title: TextFormField(
              initialValue: user.address.toString(),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 5,
              decoration: InputDecoration(
                fillColor: CustomColors.white,
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: CustomColors.grey)),
              ),
              readOnly: true,
            ),
          )
        ],
      ),
    );
  }
}
