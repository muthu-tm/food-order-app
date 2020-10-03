part of 'chat_temp.dart';

ChatTemplate _$ChatTemplateFromJson(Map<String, dynamic> json) {
  return ChatTemplate()
    ..from = json['from'] as String
    ..content = json['content'] as String
    ..messageType = json['msg_type'] as int
    ..senderType = json['sender_type'] as int
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

Map<String, dynamic> _$ChatTemplateToJson(ChatTemplate instance) =>
    <String, dynamic>{
      'from': instance.from,
      'content': instance.content,
      'msg_type': instance.messageType,
      'sender_type': instance.senderType,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
