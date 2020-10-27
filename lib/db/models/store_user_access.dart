import 'package:json_annotation/json_annotation.dart';

part 'store_user_access.g.dart';

@JsonSerializable(explicitToJson: true)
class StoreUserAccess {
  @JsonKey(name: 'position_name', defaultValue: "")
  String positionName;
  @JsonKey(name: 'user_number')
  String userNumber;
  @JsonKey(name: 'access_level')
  List<int> accessLevel;

  StoreUserAccess();

  factory StoreUserAccess.fromJson(Map<String, dynamic> json) =>
      _$StoreUserAccessFromJson(json);
  Map<String, dynamic> toJson() => _$StoreUserAccessToJson(this);
}
