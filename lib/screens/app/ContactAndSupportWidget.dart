import 'package:chipchop_buyer/services/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/url_launcher_utils.dart';

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
              "Help and Support",
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
            "Get Lost? Need Some Help?",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: CustomColors.green,
                fontSize: 16.0,
                fontWeight: FontWeight.bold),
          ),
          Text(
            "We are happy to help you!",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: CustomColors.positiveGreen,
                fontSize: 14.0,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 40),
          Text(
            "Contact Us",
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
              ElevatedButton.icon(
                icon: Icon(
                  Icons.email,
                  color: CustomColors.alertRed,
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 15.0,
                  primary: CustomColors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () {
                  UrlLauncherUtils.sendEmail(
                      support_email_ID,
                      'Uniques - Help %26 Support',
                      'Please type your query/issue here with your mobile number.. We will get back to you ASAP!');
                },
                label: Text(
                  "Email",
                  style: TextStyle(
                    color: CustomColors.blue,
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Spacer(
                flex: 1,
              ),
              ElevatedButton.icon(
                icon: Icon(
                  Icons.phone,
                  color: CustomColors.alertRed,
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 15.0,
                  primary: CustomColors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () {
                  UrlLauncherUtils.makePhoneCall(support_mobile_number);
                },
                label: Text(
                  "Phone",
                  style: TextStyle(
                    color: CustomColors.blue,
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
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
