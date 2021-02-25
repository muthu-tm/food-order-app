import 'package:chipchop_buyer/db/models/user.dart';
import 'package:chipchop_buyer/services/analytics/analytics.dart';
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
  @JsonKey(name: 'store_name', nullable: false)
  String storeName;
  @JsonKey(name: 'product_uuid', defaultValue: "")
  String productID;
  @JsonKey(name: 'product_name', nullable: false)
  String productName;
  @JsonKey(name: 'variant_id', nullable: false)
  String variantID;
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
    return getCollectionRef().doc(uuid);
  }

  String getID() {
    return this.uuid;
  }

  Stream<DocumentSnapshot> streamStoreData() {
    return getDocumentReference(getID()).snapshots();
  }

  Future<void> create() async {
    try {
      DocumentReference docRef = getCollectionRef().doc();
      this.createdAt = DateTime.now();
      this.updatedAt = DateTime.now();
      this.uuid = docRef.id;

      await docRef.set(this.toJson());
    } catch (err) {
      Analytics.reportError({
        'type': 'cart_create_error',
        'store_id': this.storeID,
        'product_id': productID,
        'cart_id': this.uuid,
        'error': err.toString()
      }, 'cart');
      throw err;
    }
  }

  Future<void> updateCartQuantity(
      bool isAdd, String storeId, String productID, String varient) async {
    try {
      QuerySnapshot snap = await getCollectionRef()
          .where('in_wishlist', isEqualTo: false)
          .where('store_uuid', isEqualTo: storeID)
          .where('product_uuid', isEqualTo: productID)
          .where('variant_id', isEqualTo: varient)
          .get();

      if (snap.docs.isNotEmpty) {
        ShoppingCart _sc = ShoppingCart.fromJson(snap.docs.first.data());
        if (isAdd)
          await snap.docs.first.reference.update(
              {'quantity': _sc.quantity + 1.0, 'updated_at': DateTime.now()});
        else
          await snap.docs.first.reference.update(
              {'quantity': _sc.quantity - 1.0, 'updated_at': DateTime.now()});
      }
    } catch (err) {
      Analytics.reportError({
        'type': 'cart_update_error',
        'store_id': storeId,
        'product_id': productID,
        'error': err.toString()
      }, 'cart');
      throw err;
    }
  }

  Future<void> updateCartQuantityByID(bool isAdd, String id) async {
    try {
      DocumentSnapshot snap = await getCollectionRef().doc(id).get();

      if (snap.exists) {
        ShoppingCart _sc = ShoppingCart.fromJson(snap.data());
        if (isAdd)
          await snap.reference.update(
              {'quantity': _sc.quantity + 1.0, 'updated_at': DateTime.now()});
        else
          await snap.reference.update(
              {'quantity': _sc.quantity - 1.0, 'updated_at': DateTime.now()});
      }
    } catch (err) {
      Analytics.reportError(
          {'type': 'cart_update_error', 'cart_id': id, 'error': err.toString()},
          'cart');
      throw err;
    }
  }

  Future<bool> moveToCart(
      String id, String storeId, String productID, String varient) async {
    try {
      QuerySnapshot existSnap = await getCollectionRef()
          .where('in_wishlist', isEqualTo: false)
          .where('store_uuid', isEqualTo: storeID)
          .where('product_uuid', isEqualTo: productID)
          .where('variant_id', isEqualTo: varient)
          .get();

      if (existSnap.docs.isNotEmpty) return false;

      DocumentSnapshot snap = await getCollectionRef().doc(id).get();

      if (snap.exists)
        await snap.reference
            .update({'in_wishlist': false, 'updated_at': DateTime.now()});
      return true;
    } catch (err) {
      Analytics.reportError(
          {'type': 'cart_update_error', 'cart_id': id, 'error': err.toString()},
          'cart');
      throw err;
    }
  }

  Future<bool> moveToWishlist(
      String id, String storeId, String productID, String varient) async {
    try {
      QuerySnapshot existSnap = await getCollectionRef()
          .where('in_wishlist', isEqualTo: true)
          .where('store_uuid', isEqualTo: storeID)
          .where('product_uuid', isEqualTo: productID)
          .where('variant_id', isEqualTo: varient)
          .get();

      if (existSnap.docs.isNotEmpty) return false;

      DocumentSnapshot snap = await getCollectionRef().doc(id).get();

      if (snap.exists)
        await snap.reference
            .update({'in_wishlist': true, 'updated_at': DateTime.now()});

      return true;
    } catch (err) {
      Analytics.reportError(
          {'type': 'cart_update_error', 'cart_id': id, 'error': err.toString()},
          'cart');
      throw err;
    }
  }

  Future<void> removeItem(
      bool isWL, String storeId, String productID, String varient) async {
    try {
      QuerySnapshot snap = await getCollectionRef()
          .where('in_wishlist', isEqualTo: isWL)
          .where('store_uuid', isEqualTo: storeID)
          .where('product_uuid', isEqualTo: productID)
          .where('variant_id', isEqualTo: varient)
          .get();

      if (snap.docs.isNotEmpty) await snap.docs.first.reference.delete();
    } catch (err) {
      Analytics.reportError({
        'type': 'cart_update_error',
        'store_id': storeId,
        'product_id': productID,
        'error': err.toString()
      }, 'cart');
      throw err;
    }
  }

  Future<void> clearCart() async {
    try {
      QuerySnapshot snap =
          await getCollectionRef().where('in_wishlist', isEqualTo: false).get();

      if (snap.docs.isNotEmpty) {
        for (var i = 0; i < snap.docs.length; i++) {
          await snap.docs[i].reference.delete();
        }
      }
    } catch (err) {
      throw err;
    }
  }

  Future<void> clearCartForStore(String storeID) async {
    try {
      QuerySnapshot snap = await getCollectionRef()
          .where('store_uuid', isEqualTo: storeID)
          .where('in_wishlist', isEqualTo: false)
          .get();

      if (snap.docs.isNotEmpty) {
        for (var i = 0; i < snap.docs.length; i++) {
          await snap.docs[i].reference.delete();
        }
      }
    } catch (err) {
      throw err;
    }
  }

  Future<void> clearCartForProduct(String storeID, String productID) async {
    try {
      QuerySnapshot snap = await getCollectionRef()
          .where('store_uuid', isEqualTo: storeID)
          .where('product_uuid', isEqualTo: productID)
          .where('in_wishlist', isEqualTo: false)
          .get();

      if (snap.docs.isNotEmpty) {
        for (var i = 0; i < snap.docs.length; i++) {
          await snap.docs[i].reference.delete();
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

  Stream<QuerySnapshot> streamWishlistForStore(String storeID) {
    try {
      return getCollectionRef()
          .where('in_wishlist', isEqualTo: true)
          .where('store_uuid', isEqualTo: storeID)
          .snapshots();
    } catch (err) {
      throw err;
    }
  }

  Future<List<ShoppingCart>> fetchForStore(String storeID) async {
    try {
      QuerySnapshot snap = await getCollectionRef()
          .where('store_uuid', isEqualTo: storeID)
          .get();

      List<ShoppingCart> cart = [];

      for (var item in snap.docs) {
        cart.add(ShoppingCart.fromJson(item.data()));
      }

      return cart;
    } catch (err) {
      throw err;
    }
  }

  Future<List<ShoppingCart>> fetchForUser() async {
    try {
      QuerySnapshot snap = await getCollectionRef().get();

      List<ShoppingCart> cart = [];

      for (var item in snap.docs) {
        cart.add(ShoppingCart.fromJson(item.data()));
      }

      return cart;
    } catch (err) {
      throw err;
    }
  }

  Future<ShoppingCart> checkWishlist(
      String storeID, String productID, String varient) async {
    try {
      QuerySnapshot snap = await getCollectionRef()
          .where('in_wishlist', isEqualTo: true)
          .where('store_uuid', isEqualTo: storeID)
          .where('product_uuid', isEqualTo: productID)
          .where('variant_id', isEqualTo: varient)
          .get();

      if (snap.docs.isEmpty)
        return null;
      else
        return ShoppingCart.fromJson(snap.docs.first.data());
    } catch (err) {
      throw err;
    }
  }

  Stream<QuerySnapshot> streamCartForProduct(String storeID, String productID) {
    try {
      return getCollectionRef()
          .where('in_wishlist', isEqualTo: false)
          .where('store_uuid', isEqualTo: storeID)
          .where('product_uuid', isEqualTo: productID)
          .snapshots();
    } catch (err) {
      throw err;
    }
  }

  Future<List<ShoppingCart>> getCartForProduct(
      String storeID, String productID, String varient) async {
    try {
      QuerySnapshot snap = await getCollectionRef()
          .where('in_wishlist', isEqualTo: false)
          .where('store_uuid', isEqualTo: storeID)
          .where('product_uuid', isEqualTo: productID)
          .where('variant_id', isEqualTo: varient)
          .get();

      List<ShoppingCart> _sc = [];

      snap.docs.forEach((element) {
        _sc.add(ShoppingCart.fromJson(element.data()));
      });
      return _sc;
    } catch (err) {
      throw err;
    }
  }

  Stream<QuerySnapshot> streamForProduct(String storeID, String productID) {
    try {
      return getCollectionRef()
          .where('store_uuid', isEqualTo: storeID)
          .where('product_uuid', isEqualTo: productID)
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
