import 'package:json_annotation/json_annotation.dart';
part 'order_product.g.dart';

@JsonSerializable(explicitToJson: true)
class OrderProduct {
  @JsonKey(name: 'product_uuid', nullable: false)
  String productID;
  @JsonKey(name: 'variant_id', nullable: false)
  String variantID;
  @JsonKey(name: 'product_name', nullable: false)
  String productName;
  @JsonKey(name: 'quantity', nullable: false)
  double quantity;
  @JsonKey(name: 'amount')
  double amount;
  @JsonKey(name: 'is_returnable')
  bool isReturnable;

  OrderProduct();

  factory OrderProduct.fromJson(Map<String, dynamic> json) =>
      _$OrderProductFromJson(json);
  Map<String, dynamic> toJson() => _$OrderProductToJson(this);
}
