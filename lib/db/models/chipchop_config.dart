import 'package:chipchop_buyer/db/models/model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chipchop_config.g.dart';

class ChipChopConfig {
  static CollectionReference _configCollRef =
      Model.db.collection("chipchop_buyer_config");

  @JsonKey(name: 'current_version')
  String cVersion;
  @JsonKey(name: 'min_version')
  String minVersion;
  @JsonKey(name: 'platform')
  String platform;
  @JsonKey(name: 'app_url', nullable: true)
  String appURL;
  @JsonKey(name: 'default_image', defaultValue: 0)
  String defaultImage;

  ChipChopConfig();

  factory ChipChopConfig.fromJson(Map<String, dynamic> json) =>
      _$ChipChopConfigFromJson(json);
  Map<String, dynamic> toJson() => _$ChipChopConfigToJson(this);

  CollectionReference getCollectionRef() {
    return _configCollRef;
  }

  Future<ChipChopConfig> getConfigByPlatform(String platform) async {
    List<DocumentSnapshot> docSnapshot =
        (await getCollectionRef().where('platform', isEqualTo: platform).get())
            .docs;

    if (docSnapshot.isEmpty) {
      return null;
    }
    ChipChopConfig conf = ChipChopConfig.fromJson(docSnapshot.first.data());

    return conf;
  }
}
