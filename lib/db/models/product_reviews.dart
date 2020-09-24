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
  int userNumber;
  @JsonKey(name: 'user_name', defaultValue: "")
  String userName;
  @JsonKey(name: 'user_location', defaultValue: "")
  String location;
  @JsonKey(name: 'images', defaultValue: [""])
  List<String> images;
  @JsonKey(name: 'created_time', nullable: true)
  int createdTime;
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  ProductReviews();

  factory ProductReviews.fromJson(Map<String, dynamic> json) => _$ProductReviewsFromJson(json);
  Map<String, dynamic> toJson() => _$ProductReviewsToJson(this);

  CollectionReference getCollectionRef(String uuid) {
    return Products().getDocumentReference(uuid).collection("product_reviews");
  }

  String getID() {
    return this.uuid;
  }
}
