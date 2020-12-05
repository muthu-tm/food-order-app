import 'package:chipchop_buyer/db/models/model.dart';
import 'package:chipchop_buyer/db/models/address.dart';
import 'package:chipchop_buyer/db/models/user_locations.dart';
import 'package:chipchop_buyer/db/models/user_preferences.dart';
import 'package:chipchop_buyer/services/analytics/analytics.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:chipchop_buyer/services/utils/constants.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_locations.dart';
part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class User extends Model {
  static CollectionReference _userCollRef = Model.db.collection("buyers");

  @JsonKey(name: 'guid', nullable: false)
  String guid;
  @JsonKey(name: 'first_name', nullable: false)
  String firstName;
  @JsonKey(name: 'last_name', defaultValue: "")
  String lastName;
  @JsonKey(name: 'mobile_number', nullable: false)
  int mobileNumber;
  @JsonKey(name: 'country_code', nullable: false)
  int countryCode;
  @JsonKey(name: 'emailID', defaultValue: "")
  String emailID;
  @JsonKey(name: 'password', nullable: false)
  String password;
  @JsonKey(name: 'gender', defaultValue: "")
  String gender;
  @JsonKey(name: 'profile_path', defaultValue: "")
  String profilePath;
  @JsonKey(name: 'date_of_birth', defaultValue: "")
  int dateOfBirth;
  @JsonKey(name: 'address', nullable: true)
  Address address;
  @JsonKey(name: 'last_signed_in_at', nullable: true)
  DateTime lastSignInTime;
  @JsonKey(name: 'is_active', defaultValue: true)
  bool isActive;
  @JsonKey(name: 'deactivated_at', nullable: true)
  int deactivatedAt;
  @JsonKey(name: 'favourite_stores')
  List<String> favStores;
  @JsonKey(name: 'preferences')
  UserPreferences preferences;
  @JsonKey(name: 'primary_location')
  UserLocations primaryLocation;
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  User();

  String getProfilePicPath() {
    if (this.profilePath != null && this.profilePath != "")
      return this.profilePath;
    return "";
  }

  String getSmallProfilePicPath() {
    if (this.profilePath != null && this.profilePath != "")
      return this
          .profilePath
          .replaceFirst(firebase_storage_path, image_kit_path + ik_small_size);
    else
      return "";
  }

  String getMediumProfilePicPath() {
    if (this.profilePath != null && this.profilePath != "")
      return this
          .profilePath
          .replaceFirst(firebase_storage_path, image_kit_path + ik_medium_size);
    else
      return "";
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  CollectionReference getCollectionRef() {
    return _userCollRef;
  }

  CollectionReference getLocationCollectionRef() {
    return _userCollRef.document(getID()).collection("user_locations");
  }

  DocumentReference getDocumentReference(String id) {
    return _userCollRef.document(id);
  }

  String getID() {
    return this.countryCode.toString() + this.mobileNumber.toString();
  }

  String getFullName() {
    return this.firstName + " " + this.lastName ?? "";
  }

  int getIntID() {
    return int.parse(
        this.countryCode.toString() + this.mobileNumber.toString());
  }

  Future<User> create() async {
    this.createdAt = DateTime.now();
    this.updatedAt = DateTime.now();
    this.isActive = true;

    await super.add(this.toJson());

    return this;
  }

  Future<List<UserLocations>> getLocations() async {
    QuerySnapshot snap = await getLocationCollectionRef().getDocuments();

    List<UserLocations> locations = [];

    if (snap.documents.isEmpty) return [];

    for (var loc in snap.documents) {
      locations.add(UserLocations.fromJson(loc.data));
    }

    return locations;
  }

  Stream<QuerySnapshot> streamLocations() {
    return getLocationCollectionRef().snapshots();
  }

  Future addLocations(UserLocations loc) async {
    DocumentReference docRef = getLocationCollectionRef().document();
    loc.uuid = docRef.documentID;
    await docRef.setData(loc.toJson());

    return loc;
  }

  Future updatePrimaryLocation(UserLocations loc) async {
    try {
      DocumentReference docRef =
          cachedLocalUser.getDocumentReference(cachedLocalUser.getID());
      await docRef.updateData(
          {'primary_location': loc.toJson(), 'updated_at': DateTime.now()});
      cachedLocalUser.primaryLocation = loc;
    } catch (err) {
      Analytics.reportError(
          {'type': 'user_primary_loc_error', 'error': err.toString()}, 'store');
      throw err;
    }
  }

  Future removeLocation(UserLocations loc) async {
    try {
      await getLocationCollectionRef().document(loc.uuid).delete();
    } catch (err) {
      Analytics.reportError(
          {'type': 'user_primary_loc_error', 'error': err.toString()}, 'store');
      throw err;
    }
  }

  Future updateLocations(String uuid, Map<String, dynamic> loc) async {
    DocumentReference docRef = getLocationCollectionRef().document(uuid);
    await docRef.updateData(loc);
  }

  Future updatePlatformDetails(Map<String, dynamic> data) async {
    this.update(data);
  }
}
