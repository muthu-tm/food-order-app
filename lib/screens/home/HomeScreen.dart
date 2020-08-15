import 'package:chipchop_buyer/app_localizations.dart';
import 'package:chipchop_buyer/screens/app/appBar.dart';
import 'package:chipchop_buyer/screens/app/sideDrawer.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: appBar(context),
      drawer: spenDrawer(context),
      backgroundColor: CustomColors.buyerWhite,
      body: SingleChildScrollView(
        child: Container(
          color: CustomColors.buyerLightGrey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.475,
                      decoration: BoxDecoration(
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color:
                                  CustomColors.mfinButtonGreen.withOpacity(0.6),
                              offset: const Offset(1.1, 4.0),
                              blurRadius: 8.0),
                        ],
                        gradient: LinearGradient(
                          colors: <Color>[
                            CustomColors.buyerBlack,
                            CustomColors.mfinButtonGreen,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(25.0),
                          bottomLeft: Radius.circular(3.0),
                          topLeft: Radius.circular(25.0),
                          topRight: Radius.circular(3.0),
                        ),
                      ),
                      height: 150,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "TODO",
                                  style: TextStyle(
                                    fontSize: 17.0,
                                    fontFamily: "Georgia",
                                    color: CustomColors.buyerWhite,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: bottomBar(context),
    );
  }
}
