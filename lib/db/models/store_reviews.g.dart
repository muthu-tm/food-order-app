part of 'store_reviews.dart';

StoreReviews _$StoreReviewsFromJson(Map<String, dynamic> json) {
  return StoreReviews()
    ..uuid = json['uuid'] as String
    ..title = json['title'] as String ?? ''
    ..review = json['review'] as String ?? ''
    ..rating = json['rating'] as int ?? 1
    ..userNumber = json['user_number'] as int
    ..userName = json['user_name'] as String ?? ""
    ..location = json['user_location'] as String ?? ""
    ..images = (json['images'] as List)
            ?.map((e) => e == null ? null : e as String)
            ?.toList() ??
        []
    ..createdTime = json['created_time'] as int
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

Map<String, dynamic> _$StoreReviewsToJson(StoreReviews instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'title': instance.title,
      'review': instance.review,
      'rating': instance.rating ?? 1,
      'user_number': instance.userNumber,
      'user_name': instance.userName ?? "",
      'user_location': instance.location ?? "",
      'images': instance.images == null ? [] : instance.images,
      'created_time': instance.createdTime,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
