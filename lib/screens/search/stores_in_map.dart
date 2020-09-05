import 'dart:async';

import 'package:chipchop_buyer/db/models/user_locations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StoresInMap extends StatefulWidget {
  final Stream<List<DocumentSnapshot>> stores;
  final UserLocations locations;
  StoresInMap(this.stores, this.locations);

  @override
  _StoresInMapState createState() => _StoresInMapState();
}

class _StoresInMapState extends State<StoresInMap> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> storesMarker = {};

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
          //_buildContainer(),
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
        markers: storesMarker,
      ),
    );
  }

  void _addStoresMarker() {
    widget.stores.forEach((element) {
      element.forEach((DocumentSnapshot document) {
        GeoPoint pos = document.data['geo_point']['geopoint'];

        var marker = Marker(
          markerId: MarkerId(document.data['uuid']),

          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueMagenta,
          ),
          position: LatLng(pos.latitude, pos.longitude),
        );

        setState(() {
          storesMarker.add(marker);
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
            stream: widget.stores,
            builder: (context, asyncSnapshot) {
              return ListView(
                children: [
                  SizedBox(width: 10.0),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _boxes(asyncSnapshot.data),
                  ),
                  SizedBox(width: 10.0),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                  ),
                  SizedBox(width: 10.0),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                  ),
                ],
              );
            }),
      ),
    );
  }

  Widget _boxes(snapshot) {
    return GestureDetector(
      onTap: () {
        //_gotoLocation(lat,long);
      },
      child: Container(
        child: new FittedBox(
          child: Material(
              color: Colors.white,
              elevation: 14.0,
              borderRadius: BorderRadius.circular(24.0),
              shadowColor: Color(0x802196F3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(snapshot.toString()),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
