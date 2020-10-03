import 'package:chipchop_buyer/db/models/user_locations.dart';
import 'package:chipchop_buyer/screens/home/HomeScreen.dart';
import 'package:chipchop_buyer/screens/user/AddLocation.dart';
import 'package:chipchop_buyer/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ViewLocationsScreen extends StatefulWidget {
  @override
  _ViewLocationsScreenState createState() => _ViewLocationsScreenState();
}

class _ViewLocationsScreenState extends State<ViewLocationsScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
            settings: RouteSettings(name: '/home'),
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Locations",
            textAlign: TextAlign.start,
            style: TextStyle(color: CustomColors.lightGrey, fontSize: 16),
          ),
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: CustomColors.white,
              ),
              onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(),
                      settings: RouteSettings(name: '/home'),
                    ),
                  )),
          backgroundColor: CustomColors.green,
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: CustomColors.blueGreen,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddLocation(),
                settings: RouteSettings(name: '/location/add'),
              ),
            );
          },
          label: Text("Add Location"),
          icon: Icon(Icons.add_location),
        ),
        body: StreamBuilder(
          stream: cachedLocalUser.streamLocations(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            Widget child;

            if (snapshot.hasData) {
              if (snapshot.data.documents.length == 0) {
                child = Container(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.not_listed_location,
                          size: 40,
                          color: CustomColors.purple,
                        ),
                        SizedBox(height: 20),
                        Text(
                          "No Locations Found!",
                          style: TextStyle(
                              color: CustomColors.blueGreen,
                              fontSize: 16,
                              fontFamily: "Georgia"),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              } else {
                child = Container(
                  child: ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (BuildContext context, int index) {
                        UserLocations loc = UserLocations.fromJson(
                            snapshot.data.documents[index].data);

                        return Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            padding:
                                EdgeInsets.only(left: 12, top: 8, right: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.only(
                                          left: 8, right: 8, top: 4, bottom: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5),
                                        ),
                                      ),
                                      child: Text(
                                        loc.locationName,
                                        style: TextStyle(
                                            color: CustomColors.blue,
                                            fontSize: 10),
                                      ),
                                    )
                                  ],
                                ),
                                createAddressText(loc.address.street, 16),
                                createAddressText(loc.address.city, 6),
                                createAddressText(loc.address.pincode, 6),
                                SizedBox(
                                  height: 6,
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Mobile : ",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: CustomColors.blue),
                                      ),
                                      TextSpan(
                                        text: loc.userNumber,
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Container(
                                  color: Colors.grey.shade300,
                                  height: 1,
                                  width: double.infinity,
                                ),
                                addressAction(loc)
                              ],
                            ),
                          ),
                        );
                      }),
                );
              }
            } else if (snapshot.hasError) {
              child = Center(
                child: Column(
                  children: AsyncWidgets.asyncError(),
                ),
              );
            } else {
              child = Center(
                child: Column(
                  children: AsyncWidgets.asyncWaiting(),
                ),
              );
            }
            return child;
          },
        ),
      ),
    );
  }

  createAddressText(String strAddress, double topMargin) {
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      child: Text(
        strAddress,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
      ),
    );
  }

  addressAction(UserLocations loc) {
    return Container(
      child: Row(
        children: <Widget>[
          Spacer(
            flex: 2,
          ),
          FlatButton.icon(
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => AddLocation(),
              //     settings: RouteSettings(name: '/location'),
              //   ),
              // );
            },
            icon: Icon(
              Icons.edit_location,
              color: CustomColors.blue,
            ),
            label: Text(
              "Edit",
              style: TextStyle(fontSize: 12, color: Colors.indigo.shade700),
            ),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          Spacer(
            flex: 3,
          ),
          Container(
            height: 20,
            width: 1,
            color: Colors.grey,
          ),
          Spacer(
            flex: 3,
          ),
          FlatButton.icon(
            onPressed: () async {
              try {
                await cachedLocalUser.updatePrimaryLocation(loc);
                Fluttertoast.showToast(
                    msg: 'Primary Location Updated',
                    backgroundColor: CustomColors.green,
                    textColor: Colors.white);
              } catch (err) {
                Fluttertoast.showToast(
                    msg: 'Error, Unable to update Primary Location',
                    backgroundColor: CustomColors.alertRed,
                    textColor: Colors.white);
                print(err);
              }
            },
            icon: Icon(
              Icons.location_on,
              color: CustomColors.blueGreen,
            ),
            label: Text("Set As Primary",
                style: TextStyle(fontSize: 12, color: Colors.indigo.shade700)),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          Container(
            height: 20,
            width: 1,
            color: Colors.grey,
          ),
          Spacer(
            flex: 3,
          ),
          FlatButton.icon(
            onPressed: () async {
              try {
                await cachedLocalUser.removeLocation(loc);
                Fluttertoast.showToast(
                    msg: 'Location Removed',
                    backgroundColor: CustomColors.green,
                    textColor: Colors.white);
              } catch (err) {
                Fluttertoast.showToast(
                    msg: 'Error, Unable to remove Location',
                    backgroundColor: CustomColors.alertRed,
                    textColor: Colors.white);
                print(err);
              }
            },
            icon: Icon(
              Icons.delete_forever,
              color: CustomColors.alertRed,
            ),
            label: Text("Remove",
                style: TextStyle(fontSize: 12, color: Colors.indigo.shade700)),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          Spacer(
            flex: 2,
          ),
        ],
      ),
    );
  }
}
