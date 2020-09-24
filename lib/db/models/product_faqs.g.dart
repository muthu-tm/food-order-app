part of 'product_faqs.dart';

ProductFaqs _$ProductFaqsFromJson(Map<String, dynamic> json) {
  return ProductFaqs()
    ..uuid = json['uuid'] as String
    ..question = json['question'] as String ?? ''
    ..questionedAt = json['questioned_at'] as int
    ..answer = json['answer'] as String ?? ''
    ..answeredAt = json['answered_at'] as int
    ..userNumber = json['user_number'] as int
    ..userName = json['user_name'] as String ?? ""
    ..helpful = json['helpful'] as int ?? 1
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

Map<String, dynamic> _$ProductFaqsToJson(ProductFaqs instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'question': instance.question,
      'questioned_at': instance.questionedAt,
      'answer': instance.answer ?? "",
      'answered_at': instance.answeredAt,
      'user_number': instance.userNumber,
      'user_name': instance.userName ?? "",
      'helpful': instance.helpful ?? 1,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
