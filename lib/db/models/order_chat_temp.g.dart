part of 'order_chat_temp.dart';

OrderChatTemplate _$OrderChatTemplateFromJson(Map<String, dynamic> json) {
  return OrderChatTemplate()
    ..orderUUID = json['order_uuid'] as String
    ..from = json['from'] as String
    ..content = json['content'] as String
    ..type = json['type'] as int
    ..createdAt = json['created_at'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            _getMillisecondsSinceEpoch(json['created_at'] as Timestamp))
    ..updatedAt = json['updated_at'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            _getMillisecondsSinceEpoch(json['updated_at'] as Timestamp));
}

int _getMillisecondsSinceEpoch(Timestamp ts) {
  return ts.millisecondsSinceEpoch;
}

Map<String, dynamic> _$OrderChatTemplateToJson(OrderChatTemplate instance) =>
    <String, dynamic>{
      'order_uuid': instance.orderUUID,
      'from': instance.from,
      'content': instance.content,
      'type': instance.type,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
