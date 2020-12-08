import 'package:json_annotation/json_annotation.dart';

part 'product_categories_map.g.dart';

@JsonSerializable(explicitToJson: true)
class ProductCategoriesMap {
  @JsonKey(name: 'name', defaultValue: "")
  String name;
  @JsonKey(name: 'uuid')
  String uuid;

  ProductCategoriesMap();

  factory ProductCategoriesMap.fromJson(Map<String, dynamic> json) =>
      _$ProductCategoriesMapFromJson(json);
  Map<String, dynamic> toJson() => _$ProductCategoriesMapToJson(this);
}
