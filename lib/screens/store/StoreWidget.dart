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
    final currentTime = DateTime.now();
    bool businessHours = (currentTime
            .isAfter(DateUtils.getTimeAsDateTimeObject(store.activeFrom)) &&
        currentTime
            .isBefore(DateUtils.getTimeAsDateTimeObject(store.activeTill)));
    bool businessDays = (DateTime.now().weekday <= 6
        ? store.workingDays.contains(DateTime.now().weekday)
        : store.workingDays.contains(0));
    bool isWithinWorkingHours = businessHours && businessDays;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      color: isWithinWorkingHours ? Colors.white : Colors.grey[300],
      elevation: 2,
      child: InkWell(
        onTap: () {
          UserActivityTracker _activity = UserActivityTracker();
          _activity.keywords = "";
          _activity.storeID = store.uuid;
          _activity.storeName = store.name;
          _activity.refImage = store.getPrimaryImage();
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
        child: _getStoreCard(
            context, businessDays, currentTime, isWithinWorkingHours),
      ),
    );
  }

  Widget _getStoreCard(BuildContext context, bool businessDays,
      DateTime currentTime, bool isWithinWorkingHours) {
    return Container(
      height: 120,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5.0, right: 5),
            child: Container(
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: CachedNetworkImage(
                  height: 100,
                  width: 100,
                  imageUrl: store.getPrimaryImage(),
                  imageBuilder: (context, imageProvider) => Image(
                    fit: BoxFit.fill,
                    image: imageProvider,
                  ),
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Center(
                    child: SizedBox(
                      height: 50.0,
                      width: 50.0,
                      child: CircularProgressIndicator(
                          value: downloadProgress.progress,
                          valueColor: AlwaysStoppedAnimation(CustomColors.blue),
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
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Text(
                    store.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  store.address.street + ', ' + store.address.city,
                  style: TextStyle(fontSize: 10, color: Colors.black),
                ),
                SizedBox(height: 5),
                Container(
                  child: getStoreDistance(context, store.geoPoint.geoPoint),
                ),
                SizedBox(
                  height: 5,
                ),
                store.deliveryDetails.freeDelivery != null
                    ? Container(
                        padding: EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Container(
                            padding: EdgeInsets.fromLTRB(5, 4, 5, 4),
                            decoration: BoxDecoration(
                              color: Colors.pink[100],
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                            child: Text(
                              "Free delivery above ₹ ${store.deliveryDetails.freeDelivery}",
                              style: TextStyle(fontSize: 7),
                            ),
                          ),
                        ),
                      )
                    : Container(),
                SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
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
                              settings: RouteSettings(name: '/store/chat'),
                            ),
                          );
                        }
                      : () {
                          Fluttertoast.showToast(msg: 'Store is closed');
                        },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.150,
                      height: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            child: Icon(
                              Icons.chat_bubble,
                              color: Colors.white,
                              size: 8,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Chat",
                            style: TextStyle(
                                fontSize: 10, color: CustomColors.black),
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: isWithinWorkingHours
                            ? Colors.cyanAccent[400]
                            : Colors.grey,
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                (businessDays &&
                        currentTime.isBefore(DateUtils.getTimeAsDateTimeObject(
                            store.activeFrom)))
                    ? Text(
                        "Opening in ${currentTime.difference(DateUtils.getTimeAsDateTimeObject(store.activeFrom)).abs().toString().substring(0, 4)} hours",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 8.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.red),
                      )
                    : isWithinWorkingHours
                        ? Text(
                            "Closing in ${DateUtils.durationInMinutesToHoursAndMinutes(DateUtils.getTimeInMinutes(store.activeTill) - DateUtils.getCurrentTimeInMinutes())} hours",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 8.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.green),
                          )
                        : Text(
                            "Store Closed",
                            style: TextStyle(
                                fontSize: 9.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.red),
                          ),
                ClipRRect(
                  child: Image.asset(
                    "images/store_assured.png",
                    height: 40,
                    width: 100,
                  ),
                ),
              ],
            ),
          )
        ],
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
                Row(
                  children: [
                    Icon(
                      Icons.assistant_navigation,
                      size: 13,
                      color: Colors.red,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 5.0),
                      child: Text(
                        '${snapshot.data.toStringAsFixed(2)} km',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.local_taxi_outlined,
                      size: 13,
                      color: Colors.red,
                    ),
                    Text(
                      " ₹ ${store.deliveryDetails.deliveryCharges02.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 10, color: Colors.black),
                    ),
                  ],
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
