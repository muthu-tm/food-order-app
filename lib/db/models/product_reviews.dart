import 'package:chipchop_buyer/db/models/products.dart';
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
  int rating;
  @JsonKey(name: 'user_number')
  String userNumber;
  @JsonKey(name: 'user_name', defaultValue: "")
  String userName;
  @JsonKey(name: 'user_location', defaultValue: "")
  String location;
  @JsonKey(name: 'images', defaultValue: [""])
  List<String> images;
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
      DocumentReference docRef = getCollectionRef(productID).document();
      this.uuid = docRef.documentID;
      this.createdTime = DateTime.now().millisecondsSinceEpoch;
      this.updatedAt = DateTime.now();

      await docRef.setData(this.toJson());
    } catch (err) {
      print(err);
      throw err;
    }
  }

  Future<void> update(String productID, String id) async {
    try {
      DocumentReference docRef = getCollectionRef(productID).document(id);
      this.updatedAt = DateTime.now();

      await docRef.updateData(this.toJson());
    } catch (err) {
      print(err);
      throw err;
    }
  }

  Future<List<ProductReviews>> getAllReviews(String productID) async {
    try {
      QuerySnapshot qSnap = await getCollectionRef(productID).getDocuments();
      List<ProductReviews> reviews = [];

      for (var i = 0; i < qSnap.documents.length; i++) {
        ProductReviews _review =
            ProductReviews.fromJson(qSnap.documents[i].data);
        reviews.add(_review);
      }

      return reviews;
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
