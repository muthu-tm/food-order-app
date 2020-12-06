import 'package:chipchop_buyer/screens/app/appBar.dart';
import 'package:chipchop_buyer/screens/user/AddLocation.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserLocationChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_pin_circle,
                size: 70,
                color: CustomColors.green,
              ),
              Text(
                "We don't find any location in your profile",
                style: TextStyle(
                    color: CustomColors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
              Card(
                elevation: 3.0,
                color: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: InkWell(
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddLocation(),
                        settings: RouteSettings(name: '/location/add'),
                      ),
                    );
                  },
                  child: Container(
                    height: 45,
                    width: 250,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(30)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            "Set Primary Location",
                            style: TextStyle(
                                fontSize: 16,
                                color: CustomColors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Icon(
                          FontAwesomeIcons.mapPin,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
