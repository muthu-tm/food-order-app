import 'package:chipchop_buyer/app_localizations.dart';
import 'package:chipchop_buyer/db/models/geopoint_data.dart';
import 'package:chipchop_buyer/db/models/user_locations.dart';
import 'package:chipchop_buyer/screens/home/HomeScreen.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomSnackBar.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPicker extends StatefulWidget {
  LocationPicker(this.loc);

  final UserLocations loc;
  @override
  State createState() => LocationPickerState();
}

class LocationPickerState extends State<LocationPicker> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GoogleMapController mapController;
  Geoflutterfire geo = Geoflutterfire();

  GeoPointData geoData;
  var geoPointData;

  final Set<Marker> _markers = {};
  String searchKey = "";

  @override
  void initState() {
    super.initState();
    this.searchKey = widget.loc.address.pincode;
  }

  @override
  Widget build(context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('title_add_location'),
        ),
        backgroundColor: CustomColors.mfinBlue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: CustomColors.mfinBlue,
        onPressed: () async {
          if (geoData == null || geoData.geoHash.isEmpty) {
            _scaffoldKey.currentState.showSnackBar(
              CustomSnackBar.errorSnackBar(
                  "Please PIN your location correctly!", 2),
            );
            return;
          }
          widget.loc.geoPoint = geoData;
          try {
            // await cachedLocalUser.updateLocations("Ei50FS5lOMSTI43QbEUQ", {'geo_point': geoPointData});
            await cachedLocalUser.addLocations(widget.loc);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => HomeScreen(),
                settings: RouteSettings(name: '/'),
              ),
            );
          } catch (err) {
            _scaffoldKey.currentState.showSnackBar(
              CustomSnackBar.errorSnackBar(
                  "Sorry, Unable to add your location now. Please try again later!",
                  2),
            );
          }
        },
        label: Text(
          AppLocalizations.of(context).translate('button_add_location'),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: LatLng(12.9716, 77.5946), zoom: 5),
              onTap: (latlang) {
                if (_markers.length >= 1) {
                  _markers.clear();
                }

                _onAddMarkerButtonPressed(latlang);
              },
              compassEnabled: true,
              onMapCreated: _onMapCreated,
              myLocationButtonEnabled: true,
              mapToolbarEnabled: true,
              myLocationEnabled: true,
              markers: _markers,
              mapType: MapType.normal,
            ),
            Positioned(
              top: 10,
              left: 10,
              right: 80,
              child: Card(
                elevation: 5.0,
                color: CustomColors.buyerWhite,
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)
                        .translate('hint_search_with_picode'),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(5),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () async {
                        if (searchKey != "") await _searchAndNavigate();
                      },
                    ),
                  ),
                  autofocus: false,
                  onChanged: (val) {
                    setState(
                      () {
                        searchKey = val;
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _searchAndNavigate() async {
    try {
      List<Placemark> marks =
          await Geolocator().placemarkFromAddress(searchKey);
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            zoom: 11,
            target:
                LatLng(marks[0].position.latitude, marks[0].position.longitude),
          ),
        ),
      );
    } catch (e) {
      print(e.toString());
    }
  }

  void _onAddMarkerButtonPressed(LatLng latlang) async {
    String hashID = _loadAddress(latlang.latitude, latlang.longitude);

    setState(() {
      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(hashID),
        position: latlang,
        infoWindow: InfoWindow(
          title: "${cachedLocalUser.firstName}",
          //  snippet: '5 Star Rating',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }

  String _loadAddress(double latitude, double longitude) {
    GeoFirePoint point = geo.point(latitude: latitude, longitude: longitude);
    GeoPointData geoPoint = GeoPointData();
    geoPointData = point.data;

    // print(" ------- firepoint data: ------ " + point.data.geohash.toString());
    // print(" ------- firepoint data: ------ " +
    //     point.geopoint.latitude.toString());
    // print(" ------- firepoint data: ------ " +
    //     point.data.geopoint.longitude.toString());

    print(" -------  data: ------ " + latitude.toString());
    print(" -------  data: ------ " + longitude.toString());

    geoPoint.geoHash = point.hash;
    geoPoint.geoPoint = point.geoPoint;
    // geoPoint.latitude = latitude;
    // geoPoint.longitude = longitude;
    geoData = geoPoint;
    return point.hash;
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }
}
