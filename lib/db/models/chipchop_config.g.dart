part of 'chipchop_config.dart';

ChipChopConfig _$ChipChopConfigFromJson(Map<String, dynamic> json) {
  return ChipChopConfig()
    ..cVersion = json['current_version'] as String
    ..minVersion = json['min_version'] as String
    ..platform = json['platform'] as String
    ..appURL = json['app_url'] as String
    ..referralBonus = json['referral_bonus'] as int
    ..registrationBonus = json['registration_bonus'] as int;
}

Map<String, dynamic> _$ChipChopConfigToJson(ChipChopConfig instance) =>
    <String, dynamic>{
      'current_version': instance.cVersion,
      'min_version': instance.minVersion,
      'platform': instance.platform,
      'app_url': instance.appURL,
      'referral_bonus': instance.referralBonus,
      'registration_bonus': instance.registrationBonus,
    };
