import 'package:json_annotation/json_annotation.dart';
import 'package:chipchop_buyer/db/models/product_avail_time.dart';

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
  @JsonKey(name: 'available_times', defaultValue: [""])
  List<ProductAvailTime> availableTimes;

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
      return "m.gram";
    } else if (this.unit == 4) {
      return "Litre";
    } else if (this.unit == 5) {
      return "m.litre";
    } else {
      return "Count";
    }
  }
}
