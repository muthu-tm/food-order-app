import 'package:chipchop_buyer/db/models/user.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
part 'shopping_cart.g.dart';

@JsonSerializable(explicitToJson: true)
class ShoppingCart {

  @JsonKey(name: 'uuid', nullable: false)
  String uuid;
  @JsonKey(name: 'name', defaultValue: "")
  String name;
  @JsonKey(name: 'store_uuid', defaultValue: "")
  String storeID;
  @JsonKey(name: 'product_uuid', defaultValue: "")
  String productID;
  @JsonKey(name: 'quantity')
  double quantity;
  @JsonKey(name: 'in_wishlist')
  bool inWishlist;
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  ShoppingCart();


  factory ShoppingCart.fromJson(Map<String, dynamic> json) =>
      _$ShoppingCartFromJson(json);
  Map<String, dynamic> toJson() => _$ShoppingCartToJson(this);

  CollectionReference getCollectionRef() {
    return User().getDocumentReference(cachedLocalUser.getID()).collection("shopping_cart");
  }

  DocumentReference getDocumentReference(String uuid) {
    return getCollectionRef().document(uuid);
  }

  String getID() {
    return this.uuid;
  }

  Stream<DocumentSnapshot> streamStoreData() {
    return getDocumentReference(getID()).snapshots();
  }

  Future<void> create() async {
    try {
      DocumentReference docRef = getCollectionRef().document();
      this.createdAt = DateTime.now();
      this.updatedAt = DateTime.now();
      this.uuid = docRef.documentID;

      await docRef.setData(this.toJson());
    } catch (err) {
      throw err;
    }
  }

  Stream<QuerySnapshot> streamWishlist() {
    try {
      return getCollectionRef()
          .where('in_wishlist', isEqualTo: true)
          .snapshots();
    } catch (err) {
      throw err;
    }
  }

  Stream<QuerySnapshot> streamCartItems() {
    try {
      return getCollectionRef()
          .where('in_wishlist', isEqualTo: false)
          .snapshots();
    } catch (err) {
      throw err;
    }
  }
}
