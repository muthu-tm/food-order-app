import 'package:chipchop_buyer/db/models/user_activity_tracker.dart';
import 'package:chipchop_buyer/screens/search/SearchAppBar.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomDialogs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserRecentSearches extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: UserActivityTracker().streamRecentActivity([3, 4]),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          Widget child;
          if (snapshot.hasData) {
            if (snapshot.data.documents.isNotEmpty) {
              child = Column(
                children: [
                  ListTile(
                    title: Text(
                      "Your Recent Searches",
                      style: TextStyle(
                          color: CustomColors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 17),
                    ),
                    trailing: FlatButton.icon(
                        onPressed: () async {
                          try {
                            CustomDialogs.actionWaiting(context);
                            await UserActivityTracker()
                                .clearRecentActivity([3, 4]);
                            Navigator.pop(context);
                          } catch (err) {
                            Navigator.pop(context);
                            Fluttertoast.showToast(
                                msg: "Unable to Clear now!",
                                backgroundColor: CustomColors.alertRed,
                                textColor: CustomColors.lightGrey);
                          }
                        },
                        icon: Icon(
                          Icons.clear_all,
                          color: CustomColors.alertRed,
                        ),
                        label: Text(
                          "Clear All",
                          style: TextStyle(color: CustomColors.alertRed),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      runAlignment: WrapAlignment.start,
                      spacing: 10.0,
                      children: List<Widget>.generate(
                          snapshot.data.documents.length, (int index) {
                        UserActivityTracker _ua = UserActivityTracker.fromJson(
                            snapshot.data.documents[index].data);
                        return ActionChip(
                            elevation: 1.0,
                            backgroundColor: CustomColors.grey,
                            label: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: Text(
                                _ua.keywords,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black),
                              ),
                            ),
                            onPressed: () async {
                              int mode = _ua.type == 3 ? 0 : 1;
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SearchAppBar(mode, _ua.keywords ?? ''),
                                  settings:
                                      RouteSettings(name: '/search/recent'),
                                ),
                              );
                            });
                      }),
                    ),
                  ),
                ],
              );
            } else {
              child = Container();
            }
          } else if (snapshot.hasError) {
            child = Container();
          } else {
            child = Container();
          }
          return child;
        });
  }
}
