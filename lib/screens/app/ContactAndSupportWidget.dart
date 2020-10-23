import 'package:flutter/material.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/url_launcher_utils.dart';

import '../../app_localizations.dart';

Widget contactAndSupportDialog(context) {
  return Container(
    height: 400,
    width: MediaQuery.of(context).size.width * 0.9,
    child: Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          ListTile(
            leading: Icon(
              Icons.headset_mic,
              size: 35.0,
              color: CustomColors.alertRed,
            ),
            title: Text(
              AppLocalizations.of(context).translate('help_and_support'),
              style: TextStyle(
                  color: CustomColors.positiveGreen,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Divider(
            color: CustomColors.green,
          ),
          SizedBox(height: 5),
          ClipRRect(
              child: Image.asset(
                "images/icons/logo.png",
                height: 60,
                width: 60,
              ),
            ),
          SizedBox(height: 15),
          Text(
            AppLocalizations.of(context).translate('lost_need_help'),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: CustomColors.green,
                fontSize: 16.0,
                fontWeight: FontWeight.bold),
          ),
          Text(
            AppLocalizations.of(context).translate('happy_to_help'),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: CustomColors.positiveGreen,
                fontSize: 14.0,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 40),
          Text(
            AppLocalizations.of(context).translate('contact_us'),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: CustomColors.green,
                fontSize: 18.0,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Spacer(
                flex: 2,
              ),
              RaisedButton.icon(
                icon: Icon(
                  Icons.email,
                  color: CustomColors.alertRed,
                ),
                elevation: 15.0,
                onPressed: () {
                  UrlLauncherUtils.sendEmail(
                      'hello.ifin@gmail.com',
                      'Uniques - Help %26 Support',
                      'Please type your query/issue here with your mobile number.. We will get back to you ASAP!');
                },
                label: Text(
                    AppLocalizations.of(context).translate('email'),
                    style: TextStyle(
                      color: CustomColors.blue,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                color: CustomColors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              Spacer(
                flex: 1,
              ),
              RaisedButton.icon(
                icon: Icon(
                  Icons.phone,
                  color: CustomColors.alertRed,
                ),
                elevation: 15.0,
                onPressed: () {
                  UrlLauncherUtils.makePhoneCall('919361808580');
                },
                label: Text(
                    AppLocalizations.of(context).translate('phone'),
                    style: TextStyle(
                      color: CustomColors.blue,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                color: CustomColors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              Spacer(
                flex: 2,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
