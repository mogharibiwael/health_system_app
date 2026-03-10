import 'package:nutri_guide/core/constant/api_link.dart';

import '../../../core/class/crud.dart';

class SubscriptionData {
  final Crud crud;
  SubscriptionData(this.crud);

  /// GET /api/subscriptions - fetch current user's subscriptions (returns doctor_ids)
  Future<dynamic> getMySubscriptions({String? token}) async {
    return await crud.getData(ApiLinks.subscriptions, token: token);
  }

  Future<dynamic> createSubscription(Map<String, dynamic> body, {String? token}) async {
    return await crud.postData(ApiLinks.subscriptions, body, token: token);
  }
}
