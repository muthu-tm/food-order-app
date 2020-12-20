import 'package:chipchop_buyer/db/models/geopoint_data.dart';
import 'package:chipchop_buyer/db/models/user_locations.dart';
import 'package:chipchop_buyer/screens/home/HomeScreen.dart';
import 'package:chipchop_buyer/screens/utils/CustomColors.dart';
import 'package:chipchop_buyer/screens/utils/CustomSnackBar.dart';
import 'package:chipchop_buyer/services/analytics/analytics.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EditLocationPicker extends StatefulWidget {
  EditLocationPicker(this.loc);

  final UserLocations loc;
  @override
  State createState() => EditLocationPickerState();
}

class EditLocationPickerState extends State<EditLocationPicker> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GoogleMapController mapController;
  Geoflutterfire geo = Geoflutterfire();

  GeoPointData geoData;

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    geoData = widget.loc.geoPoint;

    _searchAndNavigate(widget.loc.address.pincode);

    _markers.add(
      Marker(
        markerId: MarkerId(
          widget.loc.geoPoint.geoHash,
        ),
        position: LatLng(widget.loc.geoPoint.geoPoint.latitude,
            widget.loc.geoPoint.geoPoint.longitude),
      ),
    );
  }

  @override
  Widget build(context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Edit Location",
          textAlign: TextAlign.start,
          style: TextStyle(color: CustomColors.black, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: CustomColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: CustomColors.green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: CustomColors.green,
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
            await widget.loc.updateLocation();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (BuildContext context) => HomeScreen(0),
                settings: RouteSettings(name: '/home'),
              ),
              (Route<dynamic> route) => false,
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
          "Update Location",
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: LatLng(
                      geoData.geoPoint.latitude, geoData.geoPoint.longitude),
                  zoom: 15),
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
                elevation: 2,
                child: Container(
                  color: CustomColors.white,
                  alignment: Alignment.topCenter,
                  child: TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.search,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: "Search",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(5),
                      ),
                      autofocus: false,
                      onFieldSubmitted: (searchKey) async {
                        if (searchKey != "")
                          await _searchAndNavigate(searchKey);
                      }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _searchAndNavigate(String searchKey) async {
    try {
      List<Placemark> marks =
          await Geolocator().placemarkFromAddress(searchKey);
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            zoom: 13,
            target:
                LatLng(marks[0].position.latitude, marks[0].position.longitude),
          ),
        ),
      );
    } catch (err) {
      Analytics.reportError({
        'type': 'location_search_error',
        'search_key': searchKey,
        'error': err.toString()
      }, 'location');
      Fluttertoast.showToast(
          msg: 'Error, Unable to find matching address',
          backgroundColor: CustomColors.alertRed,
          textColor: Colors.white);
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

    geoPoint.geoHash = point.hash;
    geoPoint.geoPoint = point.geoPoint;
    geoData = geoPoint;
    return point.hash;
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }
}
