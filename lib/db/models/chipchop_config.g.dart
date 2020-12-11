part of 'chipchop_config.dart';

ChipChopConfig _$ChipChopConfigFromJson(Map<String, dynamic> json) {
  return ChipChopConfig()
    ..cVersion = json['current_version'] as String
    ..minVersion = json['min_version'] as String
    ..platform = json['platform'] as String
    ..appURL = json['app_url'] as String
    ..defaultImage = json['default_image'] as String;
}

Map<String, dynamic> _$ChipChopConfigToJson(ChipChopConfig instance) =>
    <String, dynamic>{
      'current_version': instance.cVersion,
      'min_version': instance.minVersion,
      'platform': instance.platform,
      'app_url': instance.appURL,
      'default_image': instance.defaultImage,
    };
