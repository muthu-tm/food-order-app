import 'package:json_annotation/json_annotation.dart';

part 'product_avail_time.g.dart';

@JsonSerializable(explicitToJson: true)
class ProductAvailTime {
  @JsonKey(name: 'id')
  String id;
  @JsonKey(name: 'active_from')
  String activeFrom;
  @JsonKey(name: 'active_till')
  String activeTill;

  ProductAvailTime();

  factory ProductAvailTime.fromJson(Map<String, dynamic> json) =>
      _$ProductAvailTimeFromJson(json);
  Map<String, dynamic> toJson() => _$ProductAvailTimeToJson(this);
}