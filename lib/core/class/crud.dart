import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import 'package:nutri_guide/core/constant/api_header.dart';
import 'status_request.dart';
import '../function/check_internet.dart';

class Crud {
  /// Change this one value and it affects all requests.
  static const Duration requestTimeout = Duration(seconds: 20);

  Future<Either<StatusRequest, Map<String, dynamic>>> postData(String url,
      Map<String, dynamic> data, {
        String? token,
      }) async {
    try {
      final hasInternet = await checkInternet();
      if (!hasInternet) return const Left(StatusRequest.offlineFailure);

      final uri = Uri.parse(url);

      final res = await http
          .post(
        uri,
        headers: getHeader(token),
        body: jsonEncode(data),
      )
          .timeout(requestTimeout);

      final body = res.body.isEmpty ? "{}" : res.body;

      print(body);
      print(res);

      Map<String, dynamic> json;
      try {
        json = jsonDecode(body) as Map<String, dynamic>;
      } catch (_) {
        // Not JSON? Still return something consistent
        json = {"message": body};
      }

      // ✅ success
      if (res.statusCode == 200 || res.statusCode == 201) {
        return Right(json);
      }

      // ✅ Laravel validation errors
      if (res.statusCode == 422) {
        return Right(json);
      }

      // ✅ unauthorized
      if (res.statusCode == 401 || res.statusCode == 403) {
        return Right(json); // ⬅️ نُرجع الرسالة القادمة من السيرفر
      }

      // ✅ other server errors
      return const Left(StatusRequest.serverFailure);
    } on TimeoutException catch (e) {
      print("CRUD timeout: $e");
      // choose one: serverFailure or failure
      return const Left(StatusRequest.serverFailure);
    } on SocketException catch (e) {
      print("CRUD socket: $e");
      return const Left(StatusRequest.offlineFailure);
    } on http.ClientException catch (e) {
      print("CRUD client exception: $e");
      return const Left(StatusRequest.serverFailure);
    } catch (e, track) {
      print("error from cache crud-------");
      print(e);
      print(track);
      print("error from cache crud-----");
      return const Left(StatusRequest.serverFailure);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> getData(
      String url, {
        String? token,
        Map<String, dynamic>? query,
      }) async {
    try {
      final hasInternet = await checkInternet();
      if (!hasInternet) return const Left(StatusRequest.offlineFailure);

      Uri uri = Uri.parse(url);
      if (query != null && query.isNotEmpty) {
        uri = uri.replace(queryParameters: {
          ...uri.queryParameters,
          ...query.map((k, v) => MapEntry(k, v.toString())),
        });
      }

      print("GET => $uri");

      final res = await http
          .get(uri, headers: getHeader(token))
          .timeout(requestTimeout);

      print("GET status: ${res.statusCode}");

      final body = res.body.isEmpty ? "{}" : res.body;

      // Handle both JSON objects and arrays from backend
      Map<String, dynamic> json;
      try {
        final decoded = jsonDecode(body);
        json = (decoded is Map)
            ? Map<String, dynamic>.from(decoded)
            : {"data": decoded}; // wrap arrays in a "data" key
      } catch (_) {
        // Response is not valid JSON (e.g. HTML error page)
        print("GET JSON parse failed, body: ${body.length > 300 ? body.substring(0, 300) : body}");
        json = {"message": body};
      }

      if (res.statusCode == 200 || res.statusCode == 201) {
        return Right(json);
      }

      // Laravel validation errors
      if (res.statusCode == 422) {
        return Right(json);
      }

      // unauthorized / forbidden (Laravel 403)
      if (res.statusCode == 401 || res.statusCode == 403) {
        return Right(json);
      }

      print("GET server error ${res.statusCode}: ${body.length > 300 ? body.substring(0, 300) : body}");
      return const Left(StatusRequest.serverFailure);
    } on TimeoutException catch (e) {
      print("GET timeout: $e");
      return const Left(StatusRequest.serverFailure);
    } on SocketException catch (e) {
      print("GET socket: $e");
      return const Left(StatusRequest.offlineFailure);
    } on http.ClientException catch (e) {
      print("GET client exception: $e");
      return const Left(StatusRequest.serverFailure);
    } catch (e, stack) {
      print("GET error -------");
      print(e);
      print(stack);
      print("GET error -------");
      return const Left(StatusRequest.serverFailure);
    }
  }

  Future<Either<StatusRequest, Map<String, dynamic>>> putData(
      String url,
      Map<String, dynamic> data, {
        String? token,
      }) async {
    try {
      final hasInternet = await checkInternet();
      if (!hasInternet) return const Left(StatusRequest.offlineFailure);

      final res = await http.put(
        Uri.parse(url),
        headers: getHeader(token),
        body: jsonEncode(data),
      );

      final body = res.body.isEmpty ? "{}" : res.body;
      final Map<String, dynamic> json = jsonDecode(body);

      // غالباً Laravel يرجع 200
      if (res.statusCode == 200 || res.statusCode == 201) return Right(json);
      if (res.statusCode == 422) return Right(json);
      if (res.statusCode == 401) return const Left(StatusRequest.failure);

      // ✅ لو السيرفر رجع message مفيد مع 403/405... خلّه يوصل للكنترولر
      if (json.isNotEmpty) return Right(json);

      return const Left(StatusRequest.serverFailure);
    } catch (_) {
      return const Left(StatusRequest.serverFailure);
    }
  }

}