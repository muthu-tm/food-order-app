import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../services/controllers/user/user_service.dart';
import '../../services/controllers/user/user_service.dart';
import 'model.dart';
import 'order.dart';

part 'order_chat_temp.g.dart';

@JsonSerializable(explicitToJson: true)
class OrderChatTemplate {
  @JsonKey(name: 'order_uuid', nullable: false)
  String orderUUID;
  @JsonKey(name: 'from', nullable: false)
  String from;
  @JsonKey(name: 'content', nullable: false)
  String content;
  @JsonKey(name: 'type', nullable: false)
  int type;
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  OrderChatTemplate();

  factory OrderChatTemplate.fromJson(Map<String, dynamic> json) =>
      _$OrderChatTemplateFromJson(json);
  Map<String, dynamic> toJson() => _$OrderChatTemplateToJson(this);

  CollectionReference getCollectionRef(String orderID) {
    return Model.db
        .collection("buyers")
        .document(cachedLocalUser.getID())
        .collection("orders")
        .document(orderID)
        .collection("order_chats");
  }

  Future<void> create() async {
    this.createdAt = DateTime.now();
    this.updatedAt = DateTime.now();
    this.from = cachedLocalUser.getID();

    await getCollectionRef(this.orderUUID)
        .document(this.createdAt.millisecondsSinceEpoch.toString())
        .setData(this.toJson());
  }

  Stream<QuerySnapshot> streamOrderChats(String orderID, int limit) {
    return getCollectionRef(orderID)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots();
  }
}
