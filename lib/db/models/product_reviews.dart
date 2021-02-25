import 'package:chipchop_buyer/db/models/model.dart';
import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/services/analytics/analytics.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
part 'product_reviews.g.dart';

@JsonSerializable(explicitToJson: true)
class ProductReviews {
  @JsonKey(name: 'uuid', nullable: false)
  String uuid;
  @JsonKey(name: 'title', defaultValue: "")
  String title;
  @JsonKey(name: 'review', defaultValue: "")
  String review;
  @JsonKey(name: 'rating', defaultValue: 1)
  double rating;
  @JsonKey(name: 'user_number')
  String userNumber;
  @JsonKey(name: 'user_name', defaultValue: "")
  String userName;
  @JsonKey(name: 'user_location', defaultValue: "")
  String location;
  @JsonKey(name: 'images', defaultValue: [""])
  List<String> images;
  @JsonKey(name: 'helpful', defaultValue: 1)
  int helpful;
  @JsonKey(name: 'created_time', nullable: true)
  int createdTime;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  ProductReviews();

  factory ProductReviews.fromJson(Map<String, dynamic> json) =>
      _$ProductReviewsFromJson(json);
  Map<String, dynamic> toJson() => _$ProductReviewsToJson(this);

  CollectionReference getCollectionRef(String uuid) {
    return Products().getDocumentReference(uuid).collection("product_reviews");
  }

  String getID() {
    return this.uuid;
  }

  Future<void> create(String productID) async {
    try {
      DocumentReference docRef = getCollectionRef(productID).doc();
      this.uuid = docRef.id;
      this.createdTime = DateTime.now().millisecondsSinceEpoch;
      this.updatedAt = DateTime.now();
      this.userName = cachedLocalUser.firstName;
      this.userNumber = cachedLocalUser.getID();
      this.location = cachedLocalUser.primaryLocation.address.city;

      WriteBatch _batch = Model.db.batch();

      _batch.set(docRef, this.toJson());
      DocumentReference _productDocRef = Products().getDocumentRef(productID);
      DocumentSnapshot docSnap = await _productDocRef.get();
      Products _p = Products.fromJson(docSnap.data());
      double newTotalRating = _p.totalRatings + this.rating;
      double newRating = (newTotalRating / (_p.totalReviews + 1));
      _batch.update(Products().getDocumentRef(productID), {
        'rating': newRating,
        'total_ratings': newTotalRating,
        'total_reviews': _p.totalReviews + 1,
        'updated_at': DateTime.now()
      });
      _batch.commit();
      Analytics.sendAnalyticsEvent({
        'type': 'product_review_create',
        'product_id': productID,
        'review_id': this.uuid,
      }, 'product_review');
    } catch (err) {
      Analytics.reportError({
        'type': 'product_review_create_error',
        'product_id': productID,
        'review_id': this.uuid,
        'error': err.toString()
      }, 'product_review');
      throw err;
    }
  }

  Future<void> update(String productID, String id) async {
    try {
      DocumentReference docRef = getCollectionRef(productID).doc(id);
      this.updatedAt = DateTime.now();

      await docRef.update(this.toJson());
    } catch (err) {
      Analytics.reportError({
        'type': 'product_review_update_error',
        'product_id': productID,
        'review_id': id,
        'error': err.toString()
      }, 'product_review');
      throw err;
    }
  }

  Future<List<ProductReviews>> getAllReviews(String productID) async {
    try {
      QuerySnapshot qSnap = await getCollectionRef(productID)
          .orderBy('created_time', descending: true)
          .get();
      List<ProductReviews> reviews = [];

      for (var i = 0; i < qSnap.docs.length; i++) {
        ProductReviews _review = ProductReviews.fromJson(qSnap.docs[i].data());
        reviews.add(_review);
      }

      return reviews;
    } catch (err) {
      print(err);
      throw err;
    }
  }

  Future<bool> reviewedProduct(String productID) async {
    try {
      QuerySnapshot qSnap = await getCollectionRef(productID)
          .where('user_number', isEqualTo: cachedLocalUser.getID())
          .get();
      if (qSnap.docs.isNotEmpty)
        return true;
      else
        return false;
    } catch (err) {
      print(err);
      throw err;
    }
  }

  Stream<QuerySnapshot> streamAllReviews(String productID) {
    try {
      return getCollectionRef(productID).snapshots();
    } catch (err) {
      print(err);
      throw err;
    }
  }
}
