import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chipchop_buyer/db/models/model.dart';
import 'package:chipchop_buyer/db/models/store_contacts.dart';
import 'package:chipchop_buyer/db/models/address.dart';
import 'package:chipchop_buyer/db/models/geopoint_data.dart';
import 'package:chipchop_buyer/db/models/store_user_access.dart';
import 'package:chipchop_buyer/db/models/delivery_details.dart';

import '../../services/controllers/user/user_service.dart';
import '../../services/utils/constants.dart';
import 'user_locations.dart';
part 'store.g.dart';

@JsonSerializable(explicitToJson: true)
class Store extends Model {
  static CollectionReference _storeCollRef = Model.db.collection("stores");

  @JsonKey(name: 'uuid', nullable: false)
  String uuid;
  @JsonKey(name: 'owned_by', defaultValue: "")
  String ownedBy;
  @JsonKey(name: 'store_name', defaultValue: "")
  String name;
  @JsonKey(name: 'geo_point', defaultValue: "")
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
  @JsonKey(name: 'store_images', defaultValue: [""])
  List<String> storeImages;
  @JsonKey(name: 'users')
  List<int> users;
  @JsonKey(name: 'users_access')
  List<StoreUserAccess> usersAccess;
  @JsonKey(name: 'contacts')
  List<StoreContacts> contacts;
  @JsonKey(name: 'delivery')
  DeliveryDetails deliveryDetails;
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  Store();

  List<String> getStoreImages() {
    if (this.storeImages.isEmpty) {
      return [
        no_image_placeholder.replaceFirst(
            firebase_storage_path, image_kit_path + ik_medium_size)
      ];
    } else {
      if (this.storeImages.first != null && this.storeImages.first != "") {
        List<String> images = [];
        for (var img in this.storeImages) {
          images.add(img.replaceFirst(
              firebase_storage_path, image_kit_path + ik_medium_size));
        }
        return images;
      } else
        return [
          no_image_placeholder.replaceFirst(
              firebase_storage_path, image_kit_path + ik_medium_size)
        ];
    }
  }

  List<String> getStoreOriginalImages() {
    if (this.storeImages.isEmpty) {
      return [
        no_image_placeholder.replaceFirst(firebase_storage_path, image_kit_path)
      ];
    } else {
      if (this.storeImages.first != null && this.storeImages.first != "") {
        List<String> images = [];
        for (var img in this.storeImages) {
          images.add(img.replaceFirst(firebase_storage_path, image_kit_path));
        }
        return images;
      } else
        return [
          no_image_placeholder.replaceFirst(
              firebase_storage_path, image_kit_path)
        ];
    }
  }

  factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);
  Map<String, dynamic> toJson() => _$StoreToJson(this);

  CollectionReference getCollectionRef() {
    return _storeCollRef;
  }

  DocumentReference getDocumentReference(String uuid) {
    return _storeCollRef.document(uuid);
  }

  String getID() {
    return this.uuid;
  }

  Stream<DocumentSnapshot> streamStoreData() {
    return getDocumentReference(getID()).snapshots();
  }

  Stream<List<DocumentSnapshot>> streamNearByStores(
      UserLocations loc, double radius) {
    Geoflutterfire geo = Geoflutterfire();
    GeoFirePoint usersAddressGeoFirePoint = geo.point(
        latitude: loc.geoPoint.geoPoint.latitude,
        longitude: loc.geoPoint.geoPoint.longitude);

    return geo.collection(collectionRef: getCollectionRef()).within(
        center: usersAddressGeoFirePoint,
        radius: radius,
        field: 'geo_point',
        strictMode: true);
  }

  Future<List<Store>> getStoresByTypes(List<String> typeIDs) async {
    List<Store> stores = [];

    try {
      QuerySnapshot snap = await getCollectionRef()
          .where('avail_products', arrayContainsAny: typeIDs)
          .getDocuments();
      if (snap.documents.isNotEmpty) {
        for (var i = 0; i < snap.documents.length; i++) {
          Store _s = Store.fromJson(snap.documents[i].data);
          stores.add(_s);
        }
      }

      return stores;
    } catch (err) {
      print(err);
      throw err;
    }
  }

  Future<List<Store>> getNearByStores(
      double latitude, double longitude, double radius) async {
    Geoflutterfire geo = Geoflutterfire();
    GeoFirePoint usersAddressGeoFirePoint =
        geo.point(latitude: latitude, longitude: longitude);
    List<Store> stores = [];

    await geo
        .collection(collectionRef: getCollectionRef())
        .within(
            center: usersAddressGeoFirePoint,
            radius: radius,
            field: 'geo_point',
            strictMode: true)
        .take(1)
        .forEach((snap) {
      for (var i = 0; i < snap.length; i++) {
        Store _s = Store.fromJson(snap[i].data);
        stores.add(_s);
      }
    });

    return stores;
  }

  Future<List<Store>> streamFavStores(UserLocations loc) async {
    List<Store> stores = [];

    try {
      // if (loc != null &&
      //     (cachedLocalUser.favStores == null ||
      //         cachedLocalUser.favStores.isEmpty)) {
      //   await streamNearByStores(loc, 10).take(1).forEach((snap) {
      //     for (var i = 0; i < snap.length; i++) {
      //       Store _s = Store.fromJson(snap[i].data);
      //       stores.add(_s);
      //     }
      //   });
      // } else if (cachedLocalUser.favStores != null) {
      //   QuerySnapshot snap = await getCollectionRef()
      //       .where('uuid', whereIn: cachedLocalUser.favStores)
      //       .getDocuments();
      //   if (snap.documents.isNotEmpty) {
      //     for (var i = 0; i < snap.documents.length; i++) {
      //       Store _s = Store.fromJson(snap.documents[i].data);
      //       stores.add(_s);
      //     }
      //   }
      // }

      if (stores.isEmpty) {
        QuerySnapshot snap = await getCollectionRef().getDocuments();
        if (snap.documents.isNotEmpty) {
          for (var i = 0; i < snap.documents.length; i++) {
            Store _s = Store.fromJson(snap.documents[i].data);
            stores.add(_s);
          }
        }
      }

      return stores;
    } catch (err) {
      print(err);
      throw err;
    }
  }

  Future<double> getUserDistance() async {
    try {
      double _distanceInMeters = await Geolocator().distanceBetween(
        this.geoPoint.geoPoint.latitude,
        this.geoPoint.geoPoint.longitude,
        cachedLocalUser.primaryLocation.geoPoint.geoPoint.latitude,
        cachedLocalUser.primaryLocation.geoPoint.geoPoint.longitude,
      );

      return _distanceInMeters / 1000;
    } catch (err) {
      throw err;
    }
  }

  Future<double> getShippingCharge(String storeID) async {
    try {
      DocumentSnapshot snap = await getCollectionRef().document(storeID).get();

      double val = 0.00;

      if (snap.exists) {
        Store _s = Store.fromJson(snap.data);
        double dis = await _s.getUserDistance();
        if (dis < 2.0)
          val = _s.deliveryDetails.deliveryCharges02;
        else if (dis < 5.0)
          val = _s.deliveryDetails.deliveryCharges05;
        else if (dis < 10.0)
          val = _s.deliveryDetails.deliveryCharges10;
        else
          val = _s.deliveryDetails.deliveryChargesMax;
      }

      return val;
    } catch (err) {
      print(err);
      throw err;
    }
  }
}
