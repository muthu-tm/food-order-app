import 'package:json_annotation/json_annotation.dart';

part 'store_contacts.g.dart';

@JsonSerializable(explicitToJson: true)
class StoreContacts {
  @JsonKey(name: 'contact_name', defaultValue: "")
  String contactName;
  @JsonKey(name: 'contact_number')
  int contactNumber;
  @JsonKey(name: 'country_code', defaultValue: 91)
  int countryCode;
  @JsonKey(name: 'email', defaultValue: "")
  String emailId;
  @JsonKey(name: 'is_verified', defaultValue: false)
  bool isVerfied;
  @JsonKey(name: 'is_active', defaultValue: true)
  bool isActive;

  StoreContacts();

  factory StoreContacts.fromJson(Map<String, dynamic> json) =>
      _$StoreContactsFromJson(json);
  Map<String, dynamic> toJson() => _$StoreContactsToJson(this);
}
