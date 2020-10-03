import 'package:chipchop_buyer/db/models/user.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
part 'shopping_cart.g.dart';

@JsonSerializable(explicitToJson: true)
class ShoppingCart {
  @JsonKey(name: 'uuid', nullable: false)
  String uuid;
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
    return User()
        .getDocumentReference(cachedLocalUser.getID())
        .collection("shopping_cart");
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

  Future<void> updateCartQuantity(
      bool isAdd, String storeId, String productID) async {
    try {
      QuerySnapshot snap = await getCollectionRef()
          .where('in_wishlist', isEqualTo: false)
          .where('store_uuid', isEqualTo: storeID)
          .where('product_uuid', isEqualTo: productID)
          .getDocuments();

      if (snap.documents.isNotEmpty) {
        ShoppingCart _sc = ShoppingCart.fromJson(snap.documents.first.data);
        if (isAdd)
          await snap.documents.first.reference.updateData(
              {'quantity': _sc.quantity + 1.0, 'updated_at': DateTime.now()});
        else
          await snap.documents.first.reference.updateData(
              {'quantity': _sc.quantity - 1.0, 'updated_at': DateTime.now()});
      }
    } catch (err) {
      throw err;
    }
  }

  Future<void> updateCartQuantityByID(bool isAdd, String id) async {
    try {
      DocumentSnapshot snap = await getCollectionRef().document(id).get();

      if (snap.exists) {
        ShoppingCart _sc = ShoppingCart.fromJson(snap.data);
        if (isAdd)
          await snap.reference.updateData(
              {'quantity': _sc.quantity + 1.0, 'updated_at': DateTime.now()});
        else
          await snap.reference.updateData(
              {'quantity': _sc.quantity - 1.0, 'updated_at': DateTime.now()});
      }
    } catch (err) {
      throw err;
    }
  }

  Future<void> removeItem(bool isWL, String storeId, String productID) async {
    try {
      QuerySnapshot snap = await getCollectionRef()
          .where('in_wishlist', isEqualTo: isWL)
          .where('store_uuid', isEqualTo: storeID)
          .where('product_uuid', isEqualTo: productID)
          .getDocuments();

      if (snap.documents.isNotEmpty)
        await snap.documents.first.reference.delete();
    } catch (err) {
      throw err;
    }
  }

  Future<void> clearCart() async {
    try {
      QuerySnapshot snap = await getCollectionRef()
          .where('in_wishlist', isEqualTo: false)
          .getDocuments();

      if (snap.documents.isNotEmpty) {
        for (var i = 0; i < snap.documents.length; i++) {
          await snap.documents[i].reference.delete();
        }
      }
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

  Stream<QuerySnapshot> streamCartsForStore(String storeID) {
    try {
      return getCollectionRef()
          .where('in_wishlist', isEqualTo: false)
          .where('store_uuid', isEqualTo: storeID)
          .snapshots();
    } catch (err) {
      throw err;
    }
  }

  Future<List<ShoppingCart>> fetchForStore(String storeID) async {
    try {
      QuerySnapshot snap = await getCollectionRef()
          .where('in_wishlist', isEqualTo: false)
          .where('store_uuid', isEqualTo: storeID)
          .getDocuments();

      List<ShoppingCart> cart = [];

      for (var item in snap.documents) {
        cart.add(ShoppingCart.fromJson(item.data));
      }

      return cart;
    } catch (err) {
      throw err;
    }
  }

  Future<ShoppingCart> checkWishlist(String storeID, String productID) async {
    try {
      QuerySnapshot snap = await getCollectionRef()
          .where('in_wishlist', isEqualTo: true)
          .where('store_uuid', isEqualTo: storeID)
          .where('product_uuid', isEqualTo: productID)
          .getDocuments();

      if (snap.documents.isEmpty)
        return null;
      else
        return ShoppingCart.fromJson(snap.documents.first.data);
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
