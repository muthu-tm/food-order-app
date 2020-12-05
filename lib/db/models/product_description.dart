import 'package:json_annotation/json_annotation.dart';

part 'product_description.g.dart';

@JsonSerializable(explicitToJson: true)
class ProductDescription {
  @JsonKey(name: 'title', defaultValue: "")
  String title;
  @JsonKey(name: 'description')
  String description;
  @JsonKey(name: 'images', defaultValue: "")
  List<String> images;

  ProductDescription();

  factory ProductDescription.fromJson(Map<String, dynamic> json) =>
      _$ProductDescriptionFromJson(json);
  Map<String, dynamic> toJson() => _$ProductDescriptionToJson(this);
}
