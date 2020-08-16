import 'package:chipchop_buyer/db/models/model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_store_wallet.g.dart';

@JsonSerializable(explicitToJson: true)
class UserStoreWallet {
  @JsonKey(name: 'uuid', nullable: false)
  String uuid;
  @JsonKey(name: 'store_uuid')
  String storeUUID;
  @JsonKey(name: 'user_number')
  int userNumber;
  @JsonKey(name: 'amount', defaultValue: 0)
  int amount;
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  UserStoreWallet();

  factory UserStoreWallet.fromJson(Map<String, dynamic> json) =>
      _$UserStoreWalletFromJson(json);
  Map<String, dynamic> toJson() => _$UserStoreWalletToJson(this);

  Query getGroupQuery() {
    return Model.db.collectionGroup('user_store_wallet');
  }

  String getID() {
    return this.uuid;
  }
}
