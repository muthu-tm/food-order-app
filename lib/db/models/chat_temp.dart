import 'package:chipchop_buyer/db/models/store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../services/controllers/user/user_service.dart';
import 'model.dart';

part 'chat_temp.g.dart';

@JsonSerializable(explicitToJson: true)
class ChatTemplate {
  @JsonKey(name: 'from', nullable: false)
  String from;
  @JsonKey(name: 'content', nullable: false)
  String content;
  @JsonKey(name: 'msg_type', nullable: false)
  int messageType;
  @JsonKey(name: 'sender_type', nullable: false)
  int senderType;
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  ChatTemplate();

  factory ChatTemplate.fromJson(Map<String, dynamic> json) =>
      _$ChatTemplateFromJson(json);
  Map<String, dynamic> toJson() => _$ChatTemplateToJson(this);

  CollectionReference getOrderCollectionRef(String custID, String orderID) {
    return Model.db
        .collection("buyers")
        .document(custID)
        .collection("orders")
        .document(orderID)
        .collection("order_chats");
  }

  CollectionReference getStoreCollectionRef(String storeID, String custID) {
    return Model.db
        .collection("stores")
        .document(storeID)
        .collection("customers")
        .document(custID)
        .collection("chats");
  }

  Future<void> orderChatCreate(String orderUUID) async {
    this.createdAt = DateTime.now();
    this.updatedAt = DateTime.now();
    this.from = cachedLocalUser.getID();

    await getOrderCollectionRef(cachedLocalUser.getID(), orderUUID)
        .document(this.createdAt.millisecondsSinceEpoch.toString())
        .setData(this.toJson());
  }

  Stream<QuerySnapshot> streamOrderChats(String orderID, int limit) {
    return getOrderCollectionRef(cachedLocalUser.getID(), orderID)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<void> storeChatCreate(String storeID) async {
    this.createdAt = DateTime.now();
    this.updatedAt = DateTime.now();
    this.from = cachedLocalUser.getID();

    await getStoreCollectionRef(
      storeID,
      cachedLocalUser.getID(),
    )
        .document(this.createdAt.millisecondsSinceEpoch.toString())
        .setData(this.toJson());
  }

  Future<void> storeCreateCustomer(String storeID) async {
    await Model.db
        .collection("stores")
        .document(storeID)
        .collection("customers")
        .document(cachedLocalUser.getID())
        .setData({
      'contact_number': cachedLocalUser.getID(),
      'first_name': cachedLocalUser.firstName,
      'last_name': cachedLocalUser.lastName,
      'store_uuid': storeID,
      'created_at': DateTime.now()
    });
  }

  Stream<QuerySnapshot> streamStoreCustomers(String storeID) {
    return Model.db
        .collection("stores")
        .document(storeID)
        .collection("customers")
        .snapshots();
  }

  Stream<QuerySnapshot> streamStoreChats(String storeID, int limit) {
    return getStoreCollectionRef(
      storeID,
      cachedLocalUser.getID(),
    ).orderBy('created_at', descending: true).limit(limit).snapshots();
  }

  Future<List<Store>> getStoreChatsList() async {
    try {
      QuerySnapshot snap = await Model.db
          .collectionGroup('customers')
          .where('contact_number', isEqualTo: cachedLocalUser.getID())
          .orderBy('created_at', descending: true)
          .getDocuments();

      if (snap.documents.isEmpty) return [];

      List<Store> _stores = [];

      for (var i = 0; i < snap.documents.length; i++) {
        DocumentSnapshot storeSnap =
            await snap.documents[i].reference.parent().parent().get();

        if (storeSnap.exists) {
          Store _s = Store.fromJson(storeSnap.data);
          _stores.add(_s);
        }
      }

      return _stores;
    } catch (err) {
      print(err);
    }
  }
}
