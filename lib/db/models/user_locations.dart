import 'package:chipchop_buyer/db/models/model.dart';
import 'package:chipchop_buyer/db/models/address.dart';
import 'package:chipchop_buyer/db/models/geopoint_data.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_locations.g.dart';

@JsonSerializable(explicitToJson: true)
class UserLocations {
  @JsonKey(name: 'uuid', defaultValue: "")
  String uuid;
  @JsonKey(name: 'user_number', defaultValue: "")
  String userNumber;
  @JsonKey(name: 'user_name', defaultValue: "")
  String userName;
  @JsonKey(name: 'loc_name', defaultValue: "")
  String locationName;
  @JsonKey(name: 'geo_point', defaultValue: "")
  GeoPointData geoPoint;
  @JsonKey(name: 'address')
  Address address;

  UserLocations();

  factory UserLocations.fromJson(Map<String, dynamic> json) =>
      _$UserLocationsFromJson(json);
  Map<String, dynamic> toJson() => _$UserLocationsToJson(this);

  Query getGroupQuery() {
    return Model.db.collectionGroup('user_locations');
  }

  CollectionReference getCollectionRef() {
    return Model.db
        .collection("buyers")
        .doc(cachedLocalUser.getID())
        .collection("user_locations");
  }

  String getID() {
    return this.uuid;
  }

  Future updateLocation() async {
    try {
      await getCollectionRef().doc(getID()).update(this.toJson());

      if (cachedLocalUser.primaryLocation.uuid == this.uuid) {
        cachedLocalUser.primaryLocation = UserLocations.fromJson(this.toJson());
      }
    } catch (err) {
      throw err;
    }
  }
}
