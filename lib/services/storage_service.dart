import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';

/// Persists the verifier session (token + assigned exam/center) and profile
/// details. Keys are namespaced `verifier_*` / `exam_*` / `center_*` so this
/// app never collides with the operator console's storage on the same device.
class StorageService extends GetxService {
  static StorageService get to {
    try {
      return Get.find<StorageService>();
    } catch (e) {
      print("CRITICAL: StorageService not found in GetX context!");
      rethrow;
    }
  }

  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // --- Session ---
  static const String keyToken = 'token';
  static const String keyIsLoggedIn = 'is_logged_in';

  // --- Verifier identity ---
  static const String keyVerifierId = 'verifier_id';
  static const String keyVerifierDbId = 'verifier_db_id';
  static const String keyVerifierName = 'verifier_name';
  static const String keyVerifierFatherName = 'verifier_father_name';
  static const String keyVerifierPhone = 'verifier_phone';
  static const String keyVerifierEmail = 'verifier_email';
  static const String keyVerifierAddress = 'verifier_address';
  static const String keyVerifierCityState = 'verifier_city_state';
  static const String keyVerifierPhoto = 'verifier_photo';
  static const String keyVerifierAadharFront = 'verifier_aadhar_front';
  static const String keyVerifierAadharBack = 'verifier_aadhar_back';

  // --- Assignment (fixed by backend, app must not switch center) ---
  static const String keyExamId = 'exam_id';
  static const String keyExamName = 'exam_name';
  static const String keyExamCode = 'exam_code';
  static const String keyCenterId = 'center_id';
  static const String keyCenterCode = 'center_code';
  static const String keyCenterName = 'center_name';
  static const String keyCenterDistrict = 'center_district';
  static const String keyCenterState = 'center_state';

  static const String keyIsProfileCompleted = 'is_profile_completed';

  // --- TOKEN ---
  String? getToken() => _prefs.getString(keyToken);
  Future<bool> saveToken(String token) => _prefs.setString(keyToken, token);

  // --- LOGIN STATE ---
  bool isLoggedIn() => _prefs.getBool(keyIsLoggedIn) ?? false;
  Future<bool> setLoggedIn(bool value) => _prefs.setBool(keyIsLoggedIn, value);

  // --- GENERIC ---
  String? getString(String key) => _prefs.getString(key);
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);
  int? getInt(String key) => _prefs.getInt(key);
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);
  bool? getBool(String key) => _prefs.getBool(key);
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  // --- VERIFIER ---
  String? getVerifierId() => _prefs.getString(keyVerifierId);
  Future<bool> saveVerifierId(String id) => _prefs.setString(keyVerifierId, id);
  String? getVerifierName() => _prefs.getString(keyVerifierName);

  Future<void> clearAll() async {
    await _prefs.clear();
    await Hive.box('candidates_box').clear();
    await Hive.box('pending_sync_box').clear();
  }
}
