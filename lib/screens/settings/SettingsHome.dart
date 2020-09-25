import 'package:chipchop_buyer/screens/app/appBar.dart';
import 'package:chipchop_buyer/screens/app/bottomBar.dart';
import 'package:chipchop_buyer/screens/app/sideDrawer.dart';
import 'package:chipchop_buyer/screens/settings/UserProfileSettings.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/services/utils/constants.dart';
import 'package:flutter/material.dart';

class SettingsHome extends StatefulWidget {
  @override
  _SettingsHomeState createState() => _SettingsHomeState();
}

class _SettingsHomeState extends State<SettingsHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      drawer: sideDrawer(context),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: ListView(
            children: <Widget>[
              InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Stack(
                        children: <Widget>[
                          Container(
                            width: 85,
                            height: 80,
                            decoration: BoxDecoration(
                                color: CustomColors.green,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(40),
                                    bottomRight: Radius.circular(40))),
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: SizedBox(
                              width: 60,
                              height: 60,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: CustomColors.blue.withOpacity(0.4),
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Icon(
                                    Icons.person,
                                    size: 35,
                                    color: CustomColors.blue,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Profile Settings",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: 'Georgia',
                          color: CustomColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserSetting(),
                      settings: RouteSettings(name: '/settings/profile'),
                    ),
                  );
                },
              ),
              Divider(
                color: CustomColors.green,
                thickness: 2.0,
                height: 1,
              ),
              InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Stack(
                        children: <Widget>[
                          Container(
                            width: 85,
                            height: 80,
                            decoration: BoxDecoration(
                                color: CustomColors.green,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(40),
                                    bottomRight: Radius.circular(40))),
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: SizedBox(
                              width: 60,
                              height: 60,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: CustomColors.blue.withOpacity(0.4),
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Icon(
                                    Icons.store_mall_directory,
                                    size: 35,
                                    color: CustomColors.blue,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Store Settings",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: 'Georgia',
                          color: CustomColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () async {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => AddNewStoreHome(),
                  //     settings: RouteSettings(name: '/settings/store'),
                  //   ),
                  // );
                },
              ),
              Divider(
                color: CustomColors.green,
                thickness: 2.0,
                height: 1,
              ),
              InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Stack(
                        children: <Widget>[
                          Container(
                            width: 85,
                            height: 80,
                            decoration: BoxDecoration(
                                color: CustomColors.green,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(40),
                                    bottomRight: Radius.circular(40))),
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: SizedBox(
                              width: 60,
                              height: 60,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: CustomColors.blue.withOpacity(0.4),
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Icon(
                                    Icons.local_offer,
                                    size: 35,
                                    color: CustomColors.blue,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "PromoCode",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: 'Georgia',
                          color: CustomColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserSetting(),
                      settings: RouteSettings(name: '/settings/profile'),
                    ),
                  );
                },
              ),
              Divider(
                color: CustomColors.green,
                thickness: 2.0,
                height: 1,
              ),
              InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Stack(
                        children: <Widget>[
                          Container(
                            width: 85,
                            height: 80,
                            decoration: BoxDecoration(
                                color: CustomColors.green,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(40),
                                    bottomRight: Radius.circular(40))),
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: SizedBox(
                              width: 60,
                              height: 60,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: CustomColors.blue.withOpacity(0.4),
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: ClipRRect(
                                    child: Image.asset(
                                      "images/icons/logo.png",
                                      height: 25,
                                      width: 25,
                                      cacheHeight: 30,
                                      cacheWidth: 35,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        buyer_app_name,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: 'Georgia',
                          color: CustomColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserSetting(),
                      settings: RouteSettings(name: '/settings/profile'),
                    ),
                  );
                },
              ),
              Divider(
                color: CustomColors.green,
                thickness: 2.0,
                height: 1,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomBar(context),
    );
  }
}
