part of 'user_preferences.dart';

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) {
  return UserPreferences()
    ..prefLanguage = json['language'] as String ?? 'English'
    ..isfingerAuthEnabled = json['enable_fingerprint_auth'] as bool ?? false;
}

Map<String, dynamic> _$UserPreferencesToJson(UserPreferences instance) =>
    <String, dynamic>{
      'language': instance.prefLanguage ?? 'English',
      'enable_fingerprint_auth': instance.isfingerAuthEnabled ?? false,
    };
