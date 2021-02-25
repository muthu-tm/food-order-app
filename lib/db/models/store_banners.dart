import 'package:chipchop_buyer/db/models/model.dart';
import 'package:chipchop_buyer/db/models/user_locations.dart';
import 'package:chipchop_buyer/services/analytics/analytics.dart';
import 'package:chipchop_buyer/services/utils/constants.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chipchop_buyer/db/models/geopoint_data.dart';
part 'store_banners.g.dart';

@JsonSerializable(explicitToJson: true)
class StoreBanners {
  @JsonKey(name: 'uuid', nullable: false)
  String uuid;
  @JsonKey(name: 'image', defaultValue: "")
  String image;
  @JsonKey(name: 'is_active')
  bool isActive;
  @JsonKey(name: 'is_default')
  bool isDefault;
  @JsonKey(name: 'product_uuid', defaultValue: 1)
  String productID;
  @JsonKey(name: 'store_uuid')
  String storeID;
  @JsonKey(name: 'geo_point', defaultValue: "")
  GeoPointData geoPoint;
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  StoreBanners();

  factory StoreBanners.fromJson(Map<String, dynamic> json) =>
      _$StoreBannersFromJson(json);
  Map<String, dynamic> toJson() => _$StoreBannersToJson(this);

  CollectionReference getCollectionRef() {
    return Model.db.collection("store_banners");
  }

  String getID() {
    return this.uuid;
  }

  Future<List<StoreBanners>> getAllBanners() async {
    List<StoreBanners> banners = [];

    try {
        QuerySnapshot snap = await getCollectionRef()
            .where('is_active', isEqualTo: true)
            // .where('is_default', isEqualTo: true)
            .get();
        snap.docs.forEach((element) {
          StoreBanners _s = StoreBanners.fromJson(element.data());
          banners.add(_s);
        });

      return banners;
    } catch (err) {
      Analytics.reportError(
          {'type': 'store_search_error', 'error': err.toString()}, 'store');
      throw err;
    }
  }
}
