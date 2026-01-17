import 'package:dartz/dartz.dart';
import 'package:nutri_guide/core/class/crud.dart';

import '../../../core/class/status_request.dart';
import '../../../core/constant/api_link.dart';

class LoginData {
  final Crud crud;
  LoginData(this.crud);

  Future<Either<StatusRequest, Map<String, dynamic>>> getData(
      String email, String password) async {
    return await crud.postData(ApiLinks.login, {
      "email": email,
      "password": password,
    });
  }
}

