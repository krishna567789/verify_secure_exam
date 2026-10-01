import 'dart:convert';
import 'package:get/get.dart';
import '../models/verifier_models.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'base_controller.dart';

/// Holds the logged-in verifier's session (identity + assigned exam/center).
/// Loaded from `/mobile/me` on cold start and after login. The exam/center
/// are fixed by the backend — the app must never let the verifier switch them.
class SessionController extends BaseController {
  static SessionController get to => Get.find<SessionController>();

  final _session = Rxn<VerifierSession>();
  VerifierSession? get session => _session.value;

  bool get profileCompleted => _session.value?.profileCompleted ?? false;
  String get examName => _session.value?.examName ?? '';
  String get centerName => _session.value?.centerName ?? '';
  String get centerCode => _session.value?.centerCode ?? '';
  String get verifierName => _session.value?.profile.name ?? '';
  String get verifierId =>
      _session.value?.verifierId ?? StorageService.to.getVerifierId() ?? '';

  void cacheFromSession(VerifierSession s) {
    _session.value = s;
    persist(s);
  }

  /// Loads /mobile/me. Returns the parsed session, or null on failure.
  Future<VerifierSession?> loadMe() async {
    try {
      final res = await ApiService.to.get(ApiService.urlMe);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body is Map<String, dynamic>) {
          final data = body['data'];
          if (data is Map<String, dynamic>) {
            final s = VerifierSession.fromJson(data);
            _session.value = s;
            persist(s);
            return s;
          }
        }
      }
    } catch (e) {
      print("SessionController.loadMe error: $e");
    }
    return null;
  }

  void persist(VerifierSession s) {
    final st = StorageService.to;
    if (s.verifierId.isNotEmpty) st.saveVerifierId(s.verifierId);
    st.setString(StorageService.keyVerifierDbId, s.id);
    st.setString(StorageService.keyExamId, s.examId);
    st.setString(StorageService.keyExamName, s.examName);
    st.setString(StorageService.keyExamCode, s.examCode);
    st.setString(StorageService.keyCenterId, s.centerId);
    st.setString(StorageService.keyCenterCode, s.centerCode);
    st.setString(StorageService.keyCenterName, s.centerName);
    st.setString(StorageService.keyCenterDistrict, s.centerDistrict);
    st.setString(StorageService.keyCenterState, s.centerState);
    st.setBool(StorageService.keyIsProfileCompleted, s.profileCompleted);
    final p = s.profile;
    if (p.name.isNotEmpty) st.setString(StorageService.keyVerifierName, p.name);
    if (p.fatherName.isNotEmpty) {
      st.setString(StorageService.keyVerifierFatherName, p.fatherName);
    }
    if (p.mobileNumber.isNotEmpty) {
      st.setString(StorageService.keyVerifierPhone, p.mobileNumber);
    }
    if (p.email.isNotEmpty) st.setString(StorageService.keyVerifierEmail, p.email);
    if (p.address.isNotEmpty) st.setString(StorageService.keyVerifierAddress, p.address);
    if (p.city.isNotEmpty || p.state.isNotEmpty) {
      st.setString(StorageService.keyVerifierCityState, "${p.city}, ${p.state}");
    }
    if (p.photo.isNotEmpty) st.setString(StorageService.keyVerifierPhoto, p.photo);
    if (p.aadharFront.isNotEmpty) {
      st.setString(StorageService.keyVerifierAadharFront, p.aadharFront);
    }
    if (p.aadharBack.isNotEmpty) {
      st.setString(StorageService.keyVerifierAadharBack, p.aadharBack);
    }
  }
}
