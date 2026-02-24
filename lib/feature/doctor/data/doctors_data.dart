import 'package:dartz/dartz.dart';
import 'package:nutri_guide/core/constant/api_link.dart';
import '../../../core/class/crud.dart';
import '../../../core/class/status_request.dart';

class DoctorsData {
  final Crud crud;
  DoctorsData(this.crud);

  /// GET public/doctors - no auth required (avoids 401)
  Future<Either<StatusRequest, Map<String, dynamic>>> fetchDoctors({
    String? token,
  }) async {
    final url = ApiLinks.publicDoctors;
    return await crud.getData(url); // no token for public endpoint
  }
}
