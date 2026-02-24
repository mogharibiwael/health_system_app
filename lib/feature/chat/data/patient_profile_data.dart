import '../../../core/class/crud.dart';
import '../../../core/constant/api_link.dart';

class PatientProfileData {
  final  Crud crud;
  PatientProfileData(this.crud);

  Future<dynamic> updateProfile(Map<String, dynamic> body, {required String? token}) async {
    return await crud.putData(ApiLinks.patientProfile, body, token: token);
  }

  Future<dynamic> getProfile({required String? token}) async {
    // لو عندك getData في Crud ممتاز، وإلا نضيفه
    return await crud.postData(ApiLinks.patientProfile, {}, token: token); // ❌ لا
  }
}
