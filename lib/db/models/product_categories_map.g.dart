part of 'product_categories_map.dart';

ProductCategoriesMap _$ProductCategoriesMapFromJson(Map<String, dynamic> json) {
  return ProductCategoriesMap()
    ..name = json['name'] as String ?? ''
    ..uuid = json['uuid'] as String;
}

Map<String, dynamic> _$ProductCategoriesMapToJson(
        ProductCategoriesMap instance) =>
    <String, dynamic>{
      'name': instance.name,
      'uuid': instance.uuid,
    };
