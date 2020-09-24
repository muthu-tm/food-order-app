import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/db/models/user_locations.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../db/models/store.dart';
import '../utils/CustomColors.dart';

class StoresInMap extends StatefulWidget {
  final UserLocations locations;
  StoresInMap(this.locations);

  @override
  _StoresInMapState createState() => _StoresInMapState();
}

class _StoresInMapState extends State<StoresInMap> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = Set();

  @override
  void initState() {
    super.initState();
    _addStoresMarker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search stores in map"),
      ),
      body: Stack(
        children: [
          _buildGoogleMap(context),
          _buildContainer(),
        ],
      ),
    );
  }

  Widget _buildGoogleMap(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
            target: LatLng(widget.locations.geoPoint.geoPoint.latitude,
                widget.locations.geoPoint.geoPoint.longitude),
            zoom: 15),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: markers,
      ),
    );
  }

  void _addStoresMarker() {
    Store().streamNearByStores(widget.locations).forEach((element) {
      element.forEach((element) {
        GeoPoint pos = element.data['geo_point']['geopoint'];

        var marker = Marker(
          markerId: MarkerId(element.data['uuid']),
          infoWindow: InfoWindow(title: element.data['loc_name']),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueMagenta,
          ),
          position: LatLng(pos.latitude, pos.longitude),
        );
        setState(() {
          markers.add(marker);
        });
      });
    });
  }

  Widget _buildContainer() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 150.0,
        child: StreamBuilder(
            stream: Store().streamNearByStores(widget.locations),
            builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
              Widget child;

              if (snapshot.hasData) {
                if (snapshot.data.length == 0) {
                  child = Container(
                    child: Text(
                      "No stores",
                      style: TextStyle(color: CustomColors.black),
                    ),
                  );
                } else {
                  child = ListView.builder(
                    scrollDirection: Axis.horizontal,
                    primary: true,
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      Store store = Store.fromJson(snapshot.data[index].data);

                      GeoPoint pos = store.geoPoint.geoPoint;

                      return Padding(
                        padding: EdgeInsets.all(5.0),
                        child: GestureDetector(
                          onTap: () {
                            _gotoLocation(pos.latitude, pos.longitude);
                          },
                          child: Container(
                            child: FittedBox(
                              child: Material(
                                color: CustomColors.white,
                                elevation: 14.0,
                                borderRadius: BorderRadius.circular(10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      width: 100,
                                      height: 120,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              store.getMediumProfilePicPath(),
                                          imageBuilder:
                                              (context, imageProvider) => Image(
                                            fit: BoxFit.fill,
                                            image: imageProvider,
                                          ),
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              CircularProgressIndicator(
                                                  value: downloadProgress
                                                      .progress),
                                          errorWidget: (context, url, error) =>
                                              Icon(
                                            Icons.error,
                                            size: 35,
                                          ),
                                          fadeOutDuration: Duration(seconds: 1),
                                          fadeInDuration: Duration(seconds: 2),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 5.0),
                                                child: Container(
                                                    child: Text(
                                                  store.storeName,
                                                  style: TextStyle(
                                                      color: CustomColors.blue,
                                                      fontSize: 24.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                              ),
                                              SizedBox(height: 5.0),
                                              Container(
                                                child: getStoreDistance(
                                                    context, pos),
                                              ),
                                              SizedBox(height: 5.0),
                                              Container(
                                                  child: Text(
                                                "Timings - ${store.activeFrom} : ${store.activeTill}",
                                                style: TextStyle(
                                                  color: CustomColors.black,
                                                  fontSize: 18.0,
                                                ),
                                              )),
                                            ],
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              } else if (snapshot.hasError) {
                child = Container(
                  child: Text(
                    "Error...",
                    style: TextStyle(color: CustomColors.black),
                  ),
                );
              } else {
                child = Container(
                  child: Text(
                    "Loading...",
                    style: TextStyle(color: CustomColors.black),
                  ),
                );
              }
              return child;
            }),
      ),
    );
  }

  Future<void> _gotoLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, long),
          zoom: 15,
          tilt: 50.0,
          bearing: 45.0,
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
          widget.locations.geoPoint.geoPoint.latitude,
          widget.locations.geoPoint.geoPoint.longitude,
          pos.latitude,
          pos.longitude),
      builder: (context, AsyncSnapshot<double> snapshot) {
        Widget child;

        if (snapshot.connectionState == ConnectionState.done) {
          child = Container(
            child: Row(
              children: [
                Text(
                  "Distance - ",
                  style: TextStyle(color: CustomColors.black),
                ),
                Text(
                  '${snapshot.data.toStringAsFixed(2)} km',
                  style: TextStyle(color: CustomColors.black),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          child = Container(
            child: Row(
              children: [
                Text("Distance - Not Found"),
              ],
            ),
          );
        } else {
          child = Container(
            child: Row(
              children: [
                Text("Loading..."),
              ],
            ),
          );
        }

        return child;
      },
    );
  }
}
