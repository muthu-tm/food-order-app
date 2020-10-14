import 'package:chipchop_buyer/db/models/model.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_store_wallet_history.g.dart';

@JsonSerializable(explicitToJson: true)
class UserStoreWalletHstory {
  @JsonKey(name: 'id')
  String id;
  @JsonKey(name: 'type')
  int type; // 0 - Order Debit, 1 - Order Credit, 2 - Store offer, 3 - Referral, 4 - offer code
  @JsonKey(name: 'details')
  String details;
  @JsonKey(name: 'store_uuid')
  String storeUUID;
  @JsonKey(name: 'user_number')
  String userNumber;
  @JsonKey(name: 'amount', defaultValue: 0)
  double amount;
  @JsonKey(name: 'created_at', nullable: true)
  int createdAt;

  UserStoreWalletHstory();

  factory UserStoreWalletHstory.fromJson(Map<String, dynamic> json) =>
      _$UserStoreWalletHstoryFromJson(json);
  Map<String, dynamic> toJson() => _$UserStoreWalletHstoryToJson(this);

  Query getGroupQuery() {
    return Model.db.collectionGroup('user_store_wallet');
  }

  CollectionReference getCollectionRef(String storeID) {
    return Model.db
        .collection("stores")
        .document(storeID)
        .collection("customers")
        .document(cachedLocalUser.getID())
        .collection('user_store_wallet');
  }

  String getID() {
    return this.createdAt.toString();
  }

  Stream<QuerySnapshot> streamUsersStoreWallet(String storeID) {
    return getCollectionRef(storeID).snapshots();
  }
}
