import 'package:json_annotation/json_annotation.dart';

part 'order_written_details.g.dart';

@JsonSerializable(explicitToJson: true)
class WrittenOrders {
  @JsonKey(name: 'quantity', defaultValue: 0)
  int quantity;
  @JsonKey(name: 'weight')
  double weight;
  @JsonKey(name: 'unit')
  int unit;
  @JsonKey(name: 'name')
  String name;
  @JsonKey(name: 'price')
  double price;

  WrittenOrders();

  factory WrittenOrders.fromJson(Map<String, dynamic> json) =>
      _$WrittenOrdersFromJson(json);
  Map<String, dynamic> toJson() => _$WrittenOrdersToJson(this);

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
