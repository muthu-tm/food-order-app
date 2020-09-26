import 'package:chipchop_buyer/db/models/user_locations.dart';
import 'package:chipchop_buyer/screens/app/appBar.dart';
import 'package:chipchop_buyer/screens/app/bottomBar.dart';
import 'package:chipchop_buyer/screens/search/search_bar_widget.dart';
import 'package:chipchop_buyer/screens/search/stores_in_map.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomSnackBar.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../app_localizations.dart';

class SearchHome extends StatefulWidget {
  @override
  _SearchHomeState createState() => _SearchHomeState();
}

class _SearchHomeState extends State<SearchHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBar(context),
      body: Container(
        color: CustomColors.lightGrey,
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(5.0),
              child: SearchBarWidget(),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "OR",
                style: TextStyle(
                    fontFamily: 'Georgia',
                    color: CustomColors.grey,
                    fontSize: 18),
              ),
            ),
            FlatButton.icon(
              onPressed: () async {
                List<UserLocations> userLocations =
                    await cachedLocalUser.getLocations();

                if (userLocations.isNotEmpty && userLocations != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StoresInMap(userLocations.first),
                      settings: RouteSettings(name: '/settings/user/edit'),
                    ),
                  );
                } else {
                  _scaffoldKey.currentState.showSnackBar(
                    CustomSnackBar.errorSnackBar(
                      AppLocalizations.of(context).translate('set_location'),
                      2,
                    ),
                  );
                }
              },
              icon: Icon(
                FontAwesomeIcons.mapMarkerAlt,
                color: CustomColors.blue,
              ),
              label: Padding(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  "Nearby stores in map",
                  style: TextStyle(color: CustomColors.black),
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: bottomBar(context),
    );
  }
}
