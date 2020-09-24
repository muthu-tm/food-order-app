import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chipchop_buyer/db/models/model.dart';
import 'package:chipchop_buyer/db/models/store_contacts.dart';
import 'package:chipchop_buyer/db/models/address.dart';
import 'package:chipchop_buyer/db/models/geopoint_data.dart';
import 'package:chipchop_buyer/db/models/store_user_access.dart';
import 'package:chipchop_buyer/db/models/delivery_details.dart';
part 'store.g.dart';

@JsonSerializable(explicitToJson: true)
class Store extends Model {
  static CollectionReference _storeCollRef = Model.db.collection("stores");

  
  @JsonKey(name: 'uuid', nullable: false)
  String uuid;
  @JsonKey(name: 'owned_by', defaultValue: "")
  String ownedBy;
  @JsonKey(name: 'store_name', defaultValue: "")
  String storeName;
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
  @JsonKey(name: 'store_profile', defaultValue: "")
  String storeProfile;
  @JsonKey(name: 'users')
  List<int> users;
  @JsonKey(name: 'users_access')
  List<StoreUserAccess> usersAccess;
  @JsonKey(name: 'contacts')
  List<StoreContacts> contacts;
  @JsonKey(name: 'delivery')
  List<DeliveryDetails> deliveryDetails;
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  Store();

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

}
