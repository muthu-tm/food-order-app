import 'package:chipchop_buyer/db/models/delivery_details.dart';
import 'package:chipchop_buyer/db/models/model.dart';
import 'package:chipchop_buyer/db/models/store.dart';
import 'package:chipchop_buyer/db/models/store_contacts.dart';
import 'package:chipchop_buyer/db/models/address.dart';
import 'package:chipchop_buyer/db/models/geopoint_data.dart';
import 'package:chipchop_buyer/db/models/user_locations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:json_annotation/json_annotation.dart';

part 'store_locations.g.dart';

@JsonSerializable(explicitToJson: true)
class StoreLocations {
  @JsonKey(name: 'uuid', defaultValue: "")
  String uuid;
  @JsonKey(name: 'loc_name', defaultValue: "")
  String locationName;
  @JsonKey(name: 'geo_point')
  GeoPointData geoPoint;
  @JsonKey(name: 'avail_products')
  List<String> availProducts;
  @JsonKey(name: 'avail_product_categories')
  List<String> availProductCategories;
  @JsonKey(name: 'avail_product_sub_categories')
  List<String> availProductSubCategories;
  @JsonKey(name: 'working_days')
  List<int> workingDays;
  @JsonKey(name: 'active_from')
  String activeFrom;
  @JsonKey(name: 'active_till')
  String activeTill;
  @JsonKey(name: 'address')
  Address address;
  @JsonKey(name: 'is_active', defaultValue: true)
  bool isActive;
  @JsonKey(name: 'contacts')
  List<StoreContacts> contacts;
  @JsonKey(name: 'delivery')
  List<DeliveryDetails> deliveryDetails;

  StoreLocations();

  factory StoreLocations.fromJson(Map<String, dynamic> json) =>
      _$StoreLocationsFromJson(json);
  Map<String, dynamic> toJson() => _$StoreLocationsToJson(this);

  CollectionReference getCollectionRef(String uuid) {
    return Store().getDocumentReference(uuid).collection("store_locations");
  }

  Query getGroupQuery() {
    return Model.db.collectionGroup('store_locations');
  }

  String getID() {
    return this.uuid;
  }

  DocumentReference getDocumentReference(String storeUUID, String locUUID) {
    return getCollectionRef(uuid).document();
  }

  Stream<List<DocumentSnapshot>> streamNearByStores(UserLocations loc) {
    Geoflutterfire geo = Geoflutterfire();
    GeoFirePoint usersAddressGeoFirePoint = geo.point(
        latitude: loc.geoPoint.geoPoint.latitude,
        longitude: loc.geoPoint.geoPoint.longitude);
    double radius = 5;

    return geo.collection(collectionRef: getGroupQuery()).within(
        center: usersAddressGeoFirePoint,
        radius: radius,
        field: 'geo_point',
        strictMode: true);
  }
}
