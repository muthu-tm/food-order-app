import 'package:chipchop_buyer/db/models/user.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
part 'users_shopping_details.g.dart';

@JsonSerializable(explicitToJson: true)
class UserShoppingDetails {
  @JsonKey(name: 'store_uuid', nullable: false)
  String storeID;
  @JsonKey(name: 'product_uuid', nullable: false)
  String productID;
  @JsonKey(name: 'product_name', nullable: false)
  String productName;
  @JsonKey(name: 'user_number', nullable: false)
  String userID;
  @JsonKey(name: 'user_name', nullable: false)
  String userName;
  @JsonKey(name: 'quantity', nullable: false)
  double quantity;
  @JsonKey(name: 'updated_at', nullable: false)
  int updatedAt;

  UserShoppingDetails();

  factory UserShoppingDetails.fromJson(Map<String, dynamic> json) =>
      _$UserShoppingDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$UserShoppingDetailsToJson(this);

  CollectionReference getCollectionRef(String uuid) {
    return User().getDocumentReference(uuid).collection("shopping_history");
  }

  String getID() {
    return '${this.storeID}_${this.productID}';
  }

  Future<List<UserShoppingDetails>> getFrequentlyShopped() async {
    try {
      QuerySnapshot _qSnap = await getCollectionRef(cachedLocalUser.getID())
          .orderBy('quantity', descending: true)
          .getDocuments();

      List<UserShoppingDetails> shoppDetails = [];
      for (var i = 0; i < _qSnap.documents.length; i++) {
        UserShoppingDetails _sd =
            UserShoppingDetails.fromJson(_qSnap.documents[i].data);
        shoppDetails.add(_sd);
      }

      return shoppDetails;
    } catch (err) {
      throw err;
    }
  }
}
