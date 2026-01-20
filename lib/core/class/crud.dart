import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:nutri_guide/core/constant/api_header.dart';
import 'status_request.dart';
import '../function/check_internet.dart';

class Crud {
  Future<Either<StatusRequest, Map<String, dynamic>>> postData(
      String url,
      Map<String, dynamic> data, {
        String? token,
      }) async {
    try {
      final hasInternet = await checkInternet();
      if (!hasInternet) return const Left(StatusRequest.offlineFailure);

     

      final res = await http.post(
        Uri.parse(url),
        headers: getHeader(token),
        body: jsonEncode(data),
      );

      final body = res.body.isEmpty ? "{}" : res.body;
      final Map<String, dynamic> json = jsonDecode(body);

      print("res---------===");
      print(res.body);
      print(json);
      print("res---------===");
      // success
      if (res.statusCode == 200 || res.statusCode == 201) {
        return Right(json);
      }

      // validation errors (Laravel)
      if (res.statusCode == 422) {
        return Right(json);
      }

      // unauthorized
      if (res.statusCode == 401) {
        return const Left(StatusRequest.failure);
      }

      return const Left(StatusRequest.serverFailure);
    } catch (e,track) {
      print("error from cache crud-------");
      print(e);
      print(track);
      print("error from cache crud-----");

      return const Left(StatusRequest.serverFailure);
    }
  }
}
