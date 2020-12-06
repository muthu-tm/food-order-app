import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/db/models/user_activity_tracker.dart';
import 'package:chipchop_buyer/screens/chats/StoreChatScreen.dart';
import 'package:chipchop_buyer/screens/store/ViewStoreScreen.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:chipchop_buyer/services/utils/DateUtils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

class StoreWidget extends StatelessWidget {
  StoreWidget(this.store);

  final Store store;
  @override
  Widget build(BuildContext context) {
    bool isWithinWorkingHours = (DateUtils.getTimeInMinutes(store.activeTill) -
                    DateUtils.getCurrentTimeInMinutes() >
                0 ||
            DateUtils.getCurrentTimeInMinutes() -
                    DateUtils.getTimeInMinutes(store.activeFrom) <
                0) &&
        (DateTime.now().weekday <= 6
            ? store.workingDays.contains(DateTime.now().weekday)
            : store.workingDays.contains(0));

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      color: isWithinWorkingHours ? Colors.white : Colors.grey[600],
      elevation: 2,
      child: InkWell(
        onTap: () {
          UserActivityTracker _activity = UserActivityTracker();
          _activity.keywords = "";
          _activity.storeID = store.uuid;
          _activity.storeName = store.name;
          _activity.type = 1;
          _activity.create();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewStoreScreen(store),
              settings: RouteSettings(name: '/store'),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Container(
                      height: 120,
                      width: 110,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: CachedNetworkImage(
                          imageUrl: store.getPrimaryImage(),
                          imageBuilder: (context, imageProvider) => Image(
                            fit: BoxFit.fill,
                            image: imageProvider,
                          ),
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => Center(
                            child: SizedBox(
                              height: 50.0,
                              width: 50.0,
                              child: CircularProgressIndicator(
                                  value: downloadProgress.progress,
                                  valueColor:
                                      AlwaysStoppedAnimation(CustomColors.blue),
                                  strokeWidth: 2.0),
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.error,
                            size: 35,
                          ),
                          fadeOutDuration: Duration(seconds: 1),
                          fadeInDuration: Duration(seconds: 2),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        Flexible(
                          child: Text(
                            store.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 13.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Container(
                          child: getStoreDistance(
                              context, store.geoPoint.geoPoint),
                        ),
                        SizedBox(height: 5.0),
                        isWithinWorkingHours
                            ? Text(
                                "Closing in ${DateUtils.durationInMinutesToHoursAndMinutes(DateUtils.getTimeInMinutes(store.activeTill) - DateUtils.getCurrentTimeInMinutes())} hours",
                                style: TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.green),
                              )
                            : Text("Store Closed"),
                        SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          onTap: isWithinWorkingHours
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StoreChatScreen(
                                        storeID: store.uuid,
                                        storeName: store.name,
                                      ),
                                      settings:
                                          RouteSettings(name: '/store/chat'),
                                    ),
                                  );
                                }
                              : () {
                                  Fluttertoast.showToast(
                                      msg: 'Store is closed');
                                },
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: 110,
                              height: 35,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.chat,
                                    size: 18,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Chat",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: CustomColors.black),
                                  ),
                                ],
                              ),
                              decoration: BoxDecoration(
                                color: isWithinWorkingHours
                                    ? Colors.greenAccent[200]
                                    : Colors.grey,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<double> getDistance(
      double startLat, double startLong, double endLat, double endLong) async {
    try {
      double _distanceInMeters = await Geolocator().distanceBetween(
        startLat,
        startLong,
        endLat,
        endLong,
      );

      return _distanceInMeters / 1000;
    } catch (err) {
      return 0.00;
    }
  }

  Widget getStoreDistance(BuildContext context, GeoPoint pos) {
    return FutureBuilder(
      future: getDistance(
          cachedLocalUser.primaryLocation.geoPoint.geoPoint.latitude,
          cachedLocalUser.primaryLocation.geoPoint.geoPoint.longitude,
          pos.latitude,
          pos.longitude),
      builder: (context, AsyncSnapshot<double> snapshot) {
        Widget child;

        if (snapshot.connectionState == ConnectionState.done) {
          child = Container(
            child: Row(
              children: [
                Container(
                    padding: EdgeInsets.all(1.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: CustomColors.black)),
                    child: Icon(
                      Icons.navigation,
                      size: 10,
                    )),
                Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: Text(
                    '${snapshot.data.toStringAsFixed(2)} km',
                    style: TextStyle(
                        color: Colors.red[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(left: 5.0),
                    child: Text(
                      "${store.address.city ?? ""} ",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          child = Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 100),
                    child: Text(
                      "${store.address.city ?? ""} ",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return child;
      },
    );
  }
}
