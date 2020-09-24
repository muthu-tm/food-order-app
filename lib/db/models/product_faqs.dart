import 'package:chipchop_buyer/db/models/products.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
part 'product_faqs.g.dart';

@JsonSerializable(explicitToJson: true)
class ProductFaqs {

  @JsonKey(name: 'uuid', nullable: false)
  String uuid;
  @JsonKey(name: 'question', defaultValue: "")
  String question;
  @JsonKey(name: 'questioned_at')
  int questionedAt;
  @JsonKey(name: 'answer', defaultValue: "")
  String answer;
  @JsonKey(name: 'answered_at')
  int answeredAt;
  @JsonKey(name: 'user_number')
  int userNumber;
  @JsonKey(name: 'helpful', defaultValue: 1)
  int helpful;
  @JsonKey(name: 'user_name', defaultValue: "")
  String userName;
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  ProductFaqs();

  factory ProductFaqs.fromJson(Map<String, dynamic> json) => _$ProductFaqsFromJson(json);
  Map<String, dynamic> toJson() => _$ProductFaqsToJson(this);

  CollectionReference getCollectionRef(String uuid) {
    return Products().getDocumentReference(uuid).collection("product_faqs");
  }

  String getID() {
    return this.uuid;
  }
}
