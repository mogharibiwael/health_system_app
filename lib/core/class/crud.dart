import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nutri_guide/core/class/status_request.dart';
import 'package:nutri_guide/core/function/check_internet.dart';

import '../service/serviecs.dart';

class Crud {
  final MyServices myServices = Get.find();

  Future<Either<StatusRequest, Map<String, dynamic>>> postData(
      String url,
      Map<String, dynamic> data,
      ) async {
    try {
      if (!await checkInternet()) {
        return const Left(StatusRequest.offlineFailure);
      }

      final token = myServices.sharedPreferences.getString("token");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(jsonDecode(response.body));
      }

      return const Left(StatusRequest.serverFailure);
    } catch (_) {
      return const Left(StatusRequest.serverFailure);
    }
  }
}
