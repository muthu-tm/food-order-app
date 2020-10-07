import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_buyer/screens/store/ViewStoreScreen.dart';
import 'package:chipchop_buyer/screens/user/ViewLocationsScreen.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../db/models/store.dart';
import '../utils/CustomColors.dart';

class StoresInMap extends StatefulWidget {
  @override
  _StoresInMapState createState() => _StoresInMapState();
}

class _StoresInMapState extends State<StoresInMap> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = Set();
  List<Store> stores = [];

  LatLng latLngCamera;

  @override
  void initState() {
    super.initState();
    latLngCamera = LatLng(
        cachedLocalUser.primaryLocation.geoPoint.geoPoint.latitude,
        cachedLocalUser.primaryLocation.geoPoint.geoPoint.longitude);

    var _marker = Marker(
      markerId: MarkerId(cachedLocalUser.getID()),
      infoWindow: InfoWindow(
          title: cachedLocalUser.primaryLocation.locationName,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewLocationsScreen(),
                settings: RouteSettings(name: '/location'),
              ),
            );
          }),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueGreen,
      ),
      position: LatLng(
          cachedLocalUser.primaryLocation.geoPoint.geoPoint.latitude,
          cachedLocalUser.primaryLocation.geoPoint.geoPoint.longitude),
    );
    markers.add(_marker);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Stores in Map",
          textAlign: TextAlign.start,
          style: TextStyle(color: CustomColors.lightGrey, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: CustomColors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: CustomColors.green,
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
        compassEnabled: true,
        myLocationButtonEnabled: true,
        mapToolbarEnabled: true,
        myLocationEnabled: true,
        initialCameraPosition: CameraPosition(
            target: LatLng(
                cachedLocalUser.primaryLocation.geoPoint.geoPoint.latitude,
                cachedLocalUser.primaryLocation.geoPoint.geoPoint.longitude),
            zoom: 13),
        onCameraMove: (val) {
          latLngCamera = val.target;
        },
        onCameraIdle: _loadStoresMarker,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: markers,
      ),
    );
  }

  void _loadStoresMarker() async {
    if (latLngCamera == null) {
      return;
    }

    Set<Marker> _markers = Set();
    List<Store> _stores = await Store()
        .getNearByStores(latLngCamera.latitude, latLngCamera.longitude, 5);

    _stores.forEach((element) {
      GeoPoint pos = element.geoPoint.geoPoint;

      var marker = Marker(
        markerId: MarkerId(element.uuid),
        infoWindow: InfoWindow(
            title: element.name,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewStoreScreen(element),
                  settings: RouteSettings(name: '/store'),
                ),
              );
            }),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueMagenta,
        ),
        position: LatLng(pos.latitude, pos.longitude),
      );
      _markers.add(marker);
    });
    setState(() {
      stores = _stores;
      markers.addAll(_markers);
    });
  }

  Widget _buildContainer() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
          margin: EdgeInsets.symmetric(vertical: 15.0),
          height: 150.0,
          child: stores.length > 0
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  primary: true,
                  itemCount: stores.length,
                  itemBuilder: (BuildContext context, int index) {
                    Store store = stores[index];

                    GeoPoint pos = store.geoPoint.geoPoint;

                    return Padding(
                      padding: EdgeInsets.all(5.0),
                      child: GestureDetector(
                        onLongPress: () {
                          _gotoLocation(pos.latitude, pos.longitude);
                        },
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewStoreScreen(store),
                              settings: RouteSettings(name: '/store'),
                            ),
                          );
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: BoxDecoration(
                            color: CustomColors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: CachedNetworkImage(
                                      imageUrl: store.getStoreImages().first,
                                      imageBuilder: (context, imageProvider) =>
                                          Image(
                                        fit: BoxFit.fill,
                                        image: imageProvider,
                                      ),
                                      progressIndicatorBuilder: (context, url,
                                              downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
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
                              ),
                              Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                        child: Text(
                                      store.name,
                                      style: TextStyle(
                                          color: CustomColors.blue,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    )),
                                    SizedBox(height: 5.0),
                                    Container(
                                      child: getStoreDistance(context, pos),
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
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              : Container()),
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
