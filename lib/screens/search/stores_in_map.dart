import 'dart:async';
import 'package:chipchop_buyer/db/models/store_locations.dart';
import 'package:chipchop_buyer/db/models/user_locations.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
    StoreLocations().streamNearByStores(widget.locations).forEach((element) {
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
            stream: StoreLocations().streamNearByStores(widget.locations),
            builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
              Widget child;

              if (snapshot.hasData) {
                if (snapshot.data.length == 0) {
                  child = Container(
                    child: Text(
                      "No stores",
                      style: TextStyle(color: CustomColors.buyerBlack),
                    ),
                  );
                } else {
                  child = ListView.builder(
                      //scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        StoreLocations locations =
                            StoreLocations.fromJson(snapshot.data[index].data);

                        GeoPoint pos = locations.geoPoint.geoPoint;

                        return ListBody(
                          //mainAxis: Axis.horizontal,
                          children: [
                            SizedBox(width: 10.0),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _boxes(
                                  "https://lh5.googleusercontent.com/p/AF1QipO3VPL9m-b355xWeg4MXmOQTauFAEkavSluTtJU=w225-h160-k-no",
                                  pos.latitude,
                                  pos.longitude,
                                  locations.locationName,
                                  locations.activeFrom,
                                  locations.activeTill),
                            ),
                          ],
                        );
                      });
                }
              } else if (snapshot.hasError) {
                child = Container(
                  child: Text(
                    "Error...",
                    style: TextStyle(color: CustomColors.buyerBlack),
                  ),
                );
              } else {
                child = Container(
                  child: Text(
                    "Loading...",
                    style: TextStyle(color: CustomColors.buyerBlack),
                  ),
                );
              }
              return child;
            }),
      ),
    );
  }

  Widget _boxes(String _image, double lat, double long, String storeName,
      String activeFrom, String activeTill) {
    return GestureDetector(
      onTap: () {
        _gotoLocation(lat, long);
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
                    width: 100,
                    height: 120,
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(24.0),
                      child: Image(
                        fit: BoxFit.fill,
                        image: NetworkImage(_image),
                      ),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: myDetailsContainer1(storeName, activeFrom, activeTill),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Future<void> _gotoLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: 15,
      tilt: 50.0,
      bearing: 45.0,
    )));
  }
}

Widget myDetailsContainer1(String storeName, String activeFrom, String activeTill) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Container(
            child: Text(
          storeName,
          style: TextStyle(
              color: Color(0xff6200ee),
              fontSize: 24.0,
              fontWeight: FontWeight.bold),
        )),
      ),
      SizedBox(height: 5.0),
      Container(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
              child: Text(
            "4.1",
            style: TextStyle(
              color: Colors.black54,
              fontSize: 18.0,
            ),
          )),
          Container(
              child: Text(
            "(946)",
            style: TextStyle(
              color: Colors.black54,
              fontSize: 18.0,
            ),
          )),
        ],
      )),
      SizedBox(height: 5.0),
      Container(
          child: Text(
        "American \u00B7 \u0024\u0024 \u00B7 1.6 mi",
        style: TextStyle(
          color: Colors.black54,
          fontSize: 18.0,
        ),
      )),
      SizedBox(height: 5.0),
      Container(
          child: Text(
        "Timings - $activeFrom : $activeTill",
        style: TextStyle(
            color: Colors.black54, fontSize: 18.0, fontWeight: FontWeight.bold),
      )),
    ],
  );
}
