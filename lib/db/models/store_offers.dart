import 'package:chipchop_buyer/db/models/model.dart';
import 'package:chipchop_buyer/db/models/store_locations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'store_offers.g.dart';

@JsonSerializable(explicitToJson: true)
class StoreOffers {
  @JsonKey(name: 'store_loc_id', defaultValue: "")
  String storeLocationID;
  @JsonKey(name: 'offer_code', defaultValue: "")
  String offerCode;
  @JsonKey(name: 'offer_name', defaultValue: "")
  String offerName;
  @JsonKey(name: 'desc', defaultValue: "")
  String desc;
  @JsonKey(name: 'active_from')
  int activeFrom;
  @JsonKey(name: 'active_till')
  int activeTill;
  @JsonKey(name: 'is_active', defaultValue: true)
  bool isActive;
  @JsonKey(name: 'offer_image', defaultValue: "")
  String offerImage;
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  StoreOffers();

  factory StoreOffers.fromJson(Map<String, dynamic> json) =>
      _$StoreOffersFromJson(json);
  Map<String, dynamic> toJson() => _$StoreOffersToJson(this);

  CollectionReference getCollectionRef(String storeUUID, String locUUID) {
    return StoreLocations().getDocumentReference(storeUUID, locUUID).collection("store_offers");
  }

  Query getGroupQuery() {
    return Model.db.collectionGroup('store_offers');
  }

  String getID() {
    return this.createdAt.millisecondsSinceEpoch.toString();
  }
}
