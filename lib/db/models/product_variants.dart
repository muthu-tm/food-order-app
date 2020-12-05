import 'package:json_annotation/json_annotation.dart';

part 'product_variants.g.dart';

@JsonSerializable(explicitToJson: true)
class ProductVariants {
  @JsonKey(name: 'id')
  String id;
  @JsonKey(name: 'org_price')
  double originalPrice;
  @JsonKey(name: 'offer', defaultValue: 0.00)
  double offer;
  @JsonKey(name: 'current_price')
  double currentPrice;
  @JsonKey(name: 'weight')
  double weight;
  @JsonKey(name: 'unit')
  int unit;
  @JsonKey(name: 'available_unit')
  int availableUnit;
  @JsonKey(name: 'quantity')
  int quantity;
  @JsonKey(name: 'is_available')
  bool isAvailable;

  ProductVariants();

  factory ProductVariants.fromJson(Map<String, dynamic> json) =>
      _$ProductVarientsFromJson(json);
  Map<String, dynamic> toJson() => _$ProductVarientsToJson(this);

  String getUnit() {
    if (this.unit == null) return "";

    if (this.unit == 0) {
      return "Count";
    } else if (this.unit == 1) {
      return "Kg";
    } else if (this.unit == 2) {
      return "gram";
    } else if (this.unit == 3) {
      return "milli gram";
    } else if (this.unit == 4) {
      return "litre";
    } else if (this.unit == 5) {
      return "milli litre";
    } else {
      return "Count";
    }
  }
}
