import 'package:chipchop_buyer/db/models/products.dart';
import 'package:chipchop_buyer/services/analytics/analytics.dart';
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
  String userNumber;
  @JsonKey(name: 'helpful', defaultValue: 1)
  int helpful;
  @JsonKey(name: 'user_name', defaultValue: "")
  String userName;
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  ProductFaqs();

  factory ProductFaqs.fromJson(Map<String, dynamic> json) =>
      _$ProductFaqsFromJson(json);
  Map<String, dynamic> toJson() => _$ProductFaqsToJson(this);

  CollectionReference getCollectionRef(String uuid) {
    return Products().getDocumentReference(uuid).collection("product_faqs");
  }

  String getID() {
    return this.uuid;
  }

  Future<void> create(String productID) async {
    try {
      DocumentReference docRef = getCollectionRef(productID).document();
      this.uuid = docRef.documentID;
      this.createdAt = DateTime.now();
      this.updatedAt = DateTime.now();

      await docRef.setData(this.toJson());
      Analytics.sendAnalyticsEvent({
        'type': 'product_faq_create',
        'product_id': productID,
        'faq_id': this.uuid,
      }, 'product_faq');
    } catch (err) {
      Analytics.reportError({
        'type': 'product_faq_create_error',
        'faq_id': this.uuid,
        'error': err.toString()
      }, 'product_faq');
      throw err;
    }
  }

  Future<void> update(String productID, String id) async {
    try {
      DocumentReference docRef = getCollectionRef(productID).document(id);
      this.updatedAt = DateTime.now();

      await docRef.updateData(this.toJson());
    } catch (err) {
      Analytics.reportError({
        'type': 'product_faq_update_error',
        'product_id': productID,
        'faq_id': id,
        'error': err.toString()
      }, 'product_faq');
      throw err;
    }
  }

  Future<List<ProductFaqs>> getAllFAQs(String productID) async {
    try {
      QuerySnapshot qSnap = await getCollectionRef(productID).getDocuments();
      List<ProductFaqs> faqs = [];

      for (var i = 0; i < qSnap.documents.length; i++) {
        ProductFaqs faq = ProductFaqs.fromJson(qSnap.documents[i].data);
        faqs.add(faq);
      }

      return faqs;
    } catch (err) {
      print(err);
      throw err;
    }
  }

  Stream<QuerySnapshot> streamAllFAQs(String productID) {
    try {
      return getCollectionRef(productID).snapshots();
    } catch (err) {
      print(err);
      throw err;
    }
  }
}
