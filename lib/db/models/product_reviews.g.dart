part of 'product_reviews.dart';

ProductReviews _$ProductReviewsFromJson(Map<String, dynamic> json) {
  return ProductReviews()
    ..uuid = json['uuid'] as String
    ..title = json['title'] as String ?? ''
    ..review = json['review'] as String ?? ''
    ..rating = json['rating'] as int ?? 1
    ..userNumber = json['user_number'] as String
    ..userName = json['user_name'] as String ?? ""
    ..location = json['user_location'] as String ?? ""
    ..images = (json['images'] as List)
            ?.map((e) => e == null ? null : e as String)
            ?.toList() ??
        []
    ..createdTime = json['created_time'] as int
    ..updatedAt = json['updated_at'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            _getMillisecondsSinceEpoch(json['updated_at'] as Timestamp));
}

int _getMillisecondsSinceEpoch(Timestamp ts) {
  return ts.millisecondsSinceEpoch;
}

Map<String, dynamic> _$ProductReviewsToJson(ProductReviews instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'title': instance.title,
      'review': instance.review,
      'rating': instance.rating ?? 1,
      'user_number': instance.userNumber,
      'user_name': instance.userName ?? "",
      'user_location': instance.location ?? "",
      'images': instance.images == null ? [] : instance.images,
      'created_time': instance.createdTime,
      'updated_at': instance.updatedAt,
    };
