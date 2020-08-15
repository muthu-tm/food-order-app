import 'package:chipchop_buyer/db/models/user.dart';
import 'package:chipchop_buyer/services/analytics/analytics.dart';
import 'package:chipchop_buyer/services/controllers/user/user_service.dart';
import 'package:chipchop_buyer/services/utils/hash_generator.dart';
import 'package:chipchop_buyer/services/utils/response_utils.dart';

class UserController {
  String getCurrentUserID() {
    return cachedLocalUser.countryCode.toString() +
        cachedLocalUser.mobileNumber.toString();
  }

  bool authCheck(String secretKey) {
    try {
      String hashKey =
          HashGenerator.hmacGenerator(secretKey, getCurrentUserID());
      if (hashKey != cachedLocalUser.password) {
        return false;
      }

      return true;
    } catch (err) {
      throw err;
    }
  }

  Future updateUser(Map<String, dynamic> userJson) async {
    try {
      User user = User();
      user.countryCode = cachedLocalUser.countryCode;
      user.mobileNumber = cachedLocalUser.mobileNumber;
      var result = await user.update(userJson);

      cachedLocalUser = (User.fromJson(await user.getByID(getCurrentUserID())));

      return CustomResponse.getSuccesReponse(result);
    } catch (err) {
      Analytics.reportError({
        "type": 'user_update_error',
        "user_id": userJson['mobile_number'],
        'error': err.toString()
      }, 'user');
      return CustomResponse.getFailureReponse(err.toString());
    }
  }

  Future updateSecretKey(String key) async {
    try {
      String hashKey =
          HashGenerator.hmacGenerator(key, getCurrentUserID().toString());

      await cachedLocalUser
          .update({'password': hashKey, 'updated_at': DateTime.now()});

      cachedLocalUser.password = hashKey;

      return CustomResponse.getSuccesReponse("Successfully updated Secret KEY");
    } catch (err) {
      Analytics.reportError({
        "type": 'secret_update_error',
        'user_id': getCurrentUserID(),
        'error': err.toString()
      }, 'user');
      return CustomResponse.getFailureReponse(err.toString());
    }
  }
}
