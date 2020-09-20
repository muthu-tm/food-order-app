import 'package:chipchop_buyer/db/models/user_locations.dart';
import 'package:chipchop_buyer/screens/app/bottomBar.dart';
import 'package:chipchop_buyer/screens/search/search_bar_widget.dart';
import 'package:chipchop_buyer/screens/search/stores_in_map.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomSnackBar.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:flutter/material.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: SearchBarWidget(
          performSearch: null,
        ),
      ),
      body: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(
              "or",
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
            RaisedButton(
              color: CustomColors.mfinBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: CustomColors.mfinButtonGreen)),
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
              child: Text(
                "Nearby stores in map",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: bottomBar(context),
    );
  }
}
