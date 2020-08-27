import 'dart:async';

import 'package:chipchop_buyer/db/models/user_locations.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchMap extends StatefulWidget {

  @override
  _SearchMapState createState() => _SearchMapState();
}

class _SearchMapState extends State<SearchMap> {

  Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    super.initState();
    print("In map");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildGoogleMap(context),
          Center(
            child: RaisedButton(
              onPressed: () => location(),
              child: Text(
                "Press",
                style: TextStyle(color: Colors.black),
              ),
            ),
          )
        ],
      ),
    );
  }

  void location() async{

    print("location method");

    var val = FutureBuilder(
      future: cachedLocalUser.getLocations(),
      builder: (context, AsyncSnapshot<List<UserLocations>> snapshot) {
        return Text(snapshot.data.first.geoPoint.toString());
      });

    val.future.asStream().forEach((element) {print(element.first.geoPoint.geoPoint.latitude);});
  }

  Widget _buildGoogleMap(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition:
            CameraPosition(target: LatLng(13.061780, 80.276350), zoom: 15),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: {
          Marker(
            markerId: MarkerId('My location'),
            position: LatLng(13.061780, 80.276350),
            infoWindow: InfoWindow(title: 'Triplicane'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueViolet,
            ),
          )
        },
      ),
    );
  }
}
