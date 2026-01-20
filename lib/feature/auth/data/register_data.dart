import 'package:nutri_guide/core/constant/api_link.dart';

import '../../../core/class/crud.dart';

class SignupData {
  final Crud crud;
  SignupData(this.crud);

  Future<dynamic> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? type,
    String? role,
  }) async {
    final body = {
      "name": name,
      "email": email,
      "password": password,
      "password_confirmation": passwordConfirmation,
      if (phone != null) "phone": phone,
      if (type != null) "type": type,
      if (role != null) "role": role,
    };

    final response = await crud.postData(ApiLinks.register, body);
    return response.fold((l) => l, (r) => r);
  }
}
