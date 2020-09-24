import 'package:chipchop_buyer/db/models/store.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
part 'store_reviews.g.dart';

@JsonSerializable(explicitToJson: true)
class StoreReviews {

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

  StoreReviews();

  factory StoreReviews.fromJson(Map<String, dynamic> json) => _$StoreReviewsFromJson(json);
  Map<String, dynamic> toJson() => _$StoreReviewsToJson(this);

  CollectionReference getCollectionRef(String uuid) {
    return Store().getDocumentReference(uuid).collection("store_reviews");
  }

  String getID() {
    return this.uuid;
  }
}
