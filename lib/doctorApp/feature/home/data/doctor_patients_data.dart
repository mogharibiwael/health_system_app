import 'package:dartz/dartz.dart';
import '../../../../core/class/crud.dart';
import '../../../../core/class/status_request.dart';
import '../../../../core/constant/api_link.dart';

class DoctorPatientsData {
  final Crud crud;
  DoctorPatientsData(this.crud);

  Future<dynamic> getPatients({int page = 1, String? token}) async {
    final url = "${ApiLinks.doctorPatients}?page=$page";
    return await crud.getData(url, token: token);
  }

  /// GET /doctor/patients/{id}/macros - fetch patient macros (carbs, fats, protein)
  Future<Either<StatusRequest, Map<String, dynamic>>> getPatientMacros({
    required int patientId,
    String? token,
  }) async {
    final url = ApiLinks.doctorPatientMacros(patientId);
    return await crud.getData(url, token: token);
  }

  /// PUT /doctor/patients/{id}/macros - update patient macros
  Future<Either<StatusRequest, Map<String, dynamic>>> updatePatientMacros({
    required int patientId,
    required double carbohydrates,
    required double fats,
    required double protein,
    String? token,
  }) async {
    final url = ApiLinks.doctorPatientMacros(patientId);
    final body = {
      "carbohydrates": carbohydrates,
      "fats": fats,
      "protein": protein,
    };
    return await crud.putData(url, body, token: token);
  }
}
