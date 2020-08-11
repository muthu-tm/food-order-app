import 'package:json_annotation/json_annotation.dart';

part 'user_preferences.g.dart';

@JsonSerializable(explicitToJson: true)
class UserPreferences {
  
  @JsonKey(name: 'language', defaultValue: "English")
  String prefLanguage;
  @JsonKey(name: 'enable_fingerprint_auth', defaultValue: false)
  bool isfingerAuthEnabled;

  factory UserPreferences.fromJson(Map<String, dynamic> json) => _$UserPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);

  UserPreferences();

}