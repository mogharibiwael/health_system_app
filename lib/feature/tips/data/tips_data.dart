import 'package:dartz/dartz.dart';
import 'package:nutri_guide/core/constant/api_link.dart';
import '../../../core/class/status_request.dart';
import '../../../core/class/crud.dart';

class TipsData {
  final Crud crud;
  TipsData(this.crud);

  Future<Either<StatusRequest, Map<String, dynamic>>> fetchTips({
    required int page,
    String? token,
  }) async {

    final url = "${ApiLinks.baseUrl}/public/tips?page=$page"; // adjust to your links file
    return await crud.getData(url, token: token);

  }
}
