part of 'product_description.dart';

ProductDescription _$ProductDescriptionFromJson(Map<String, dynamic> json) {
  return ProductDescription()
    ..title = json['title'] as String ?? ''
    ..description = json['description'] as String ?? ''
    ..images = (json['images'] as List)
            ?.map((e) => e == null ? null : e as String)
            ?.toList() ??
        [];
}

Map<String, dynamic> _$ProductDescriptionToJson(ProductDescription instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'images': instance.images ?? [],
    };
