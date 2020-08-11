import 'package:chipchop_buyer/db/models/model.dart';
import 'package:chipchop_buyer/db/models/address.dart';
import 'package:chipchop_buyer/db/models/user_preferences.dart';
import 'package:chipchop_buyer/services/utils/DateUtils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class User extends Model {
  static CollectionReference _userCollRef = Model.db.collection("buyers");

  @JsonKey(name: 'guid', nullable: false)
  String guid;
  @JsonKey(name: 'first_name', defaultValue: "")
  String firstName;
  @JsonKey(name: 'last_name', defaultValue: "")
  String lastName;
  @JsonKey(name: 'mobile_number', nullable: false)
  int mobileNumber;
  @JsonKey(name: 'country_code', nullable: false)
  String countryCode;
  @JsonKey(name: 'emailID', defaultValue: "")
  String emailID;
  @JsonKey(name: 'password', nullable: false)
  String password;
  @JsonKey(name: 'gender', defaultValue: "")
  String gender;
  @JsonKey(name: 'profile_path_org', defaultValue: "")
  String profilePathOrg;
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
  @JsonKey(name: 'preferences')
  UserPreferences preferences;
  @JsonKey(name: 'created_at', nullable: true)
  DateTime createdAt;
  @JsonKey(name: 'updated_at', nullable: true)
  DateTime updatedAt;

  User();

  setGuid(String uid) {
    this.guid = uid;
  }

  setPassword(String password) {
    this.password = password;
  }

  setGender(String gender) {
    this.gender = gender;
  }

  setEmailID(String emailID) {
    this.emailID = emailID;
  }

  setFirstName(String fname) {
    this.firstName = fname;
  }

  setLastName(String lname) {
    this.lastName = lname;
  }

  setDOB(DateTime date) {
    this.dateOfBirth = DateUtils.getUTCDateEpoch(date);
  }

  setLastSignInTime(DateTime dateTime) {
    this.lastSignInTime = dateTime;
  }

  setProfilePathOrg(String displayPath) {
    this.profilePathOrg = displayPath;
  }

  setAddress(Address address) {
    this.address = address;
  }

  String getProfilePicPath() {
    if (this.profilePath != null && this.profilePath != "")
      return this.profilePath;
    else if (this.profilePathOrg != null && this.profilePathOrg != "")
      return this.profilePathOrg;
    else
      return "";
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  CollectionReference getCollectionRef() {
    return _userCollRef;
  }

  DocumentReference getDocumentReference() {
    return _userCollRef.document(getID());
  }

  String getID() {
    return this.countryCode+this.mobileNumber.toString();
  }

  Stream<DocumentSnapshot> streamUserData() {
    return getDocumentReference().snapshots();
  }

  Future<User> create() async {
    this.createdAt = DateTime.now();
    this.updatedAt = DateTime.now();
    this.isActive = true;

    await super.add(this.toJson());

    return this;
  }

  Future updatePlatformDetails(Map<String, dynamic> data) async {
    this.update(data);
  }
}
