import 'package:chipchop_buyer/db/models/store.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
part 'store_faqs.g.dart';

@JsonSerializable(explicitToJson: true)
class StoreFaqs {

  @JsonKey(name: 'uuid', nullable: false)
  String uuid;
  @JsonKey(name: 'question', defaultValue: "")
  String question;
  @JsonKey(name: 'questioned_at')
  int questionedAt;
  @JsonKey(name: 'answer', defaultValue: 1)
  String answer;
  @JsonKey(name: 'answered_at')
  int answeredAt;
  @JsonKey(name: 'user_number')
  int userNumber;
  @JsonKey(name: 'user_name', defaultValue: "")
  String userName;
  @JsonKey(name: 'helpful', defaultValue: 1)
  int helpful;
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  StoreFaqs();

  factory StoreFaqs.fromJson(Map<String, dynamic> json) => _$StoreFaqsFromJson(json);
  Map<String, dynamic> toJson() => _$StoreFaqsToJson(this);

  CollectionReference getCollectionRef(String uuid) {
    return Store().getDocumentReference(uuid).collection("store_faqs");
  }

  String getID() {
    return this.uuid;
  }
}
